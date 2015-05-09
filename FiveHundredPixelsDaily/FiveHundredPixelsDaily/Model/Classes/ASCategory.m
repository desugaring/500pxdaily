
//  ASCategory.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategory.h"
#import "ASImage.h"
#import "ASStore.h"
#import "ASBaseOperation.h"

NSString * const PHOTOS_PER_REQUEST = @"30";

@interface ASCategory()

@end

@implementation ASCategory

@dynamic images;
@dynamic store;
@dynamic lastUpdated;
@dynamic isActive;
@dynamic isDaily;

@synthesize maxNumberOfImages;
@synthesize imagesDataQueue;
@synthesize thumbnailQueue;
@synthesize fullQueue;
@synthesize delegate;

- (ASBaseOperation *)operation {
    return self.store.operation;
}

- (void)awakeCommon {
    [super awakeCommon];

    self.maxNumberOfImages = -1;

    self.imagesDataQueue = [[NSOperationQueue alloc] init];
    self.imagesDataQueue.maxConcurrentOperationCount = 1;

    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 5;

    self.fullQueue = [[NSOperationQueue alloc] init];
    self.fullQueue.maxConcurrentOperationCount = 3;
}

- (void)resetImages {
    self.maxNumberOfImages = -1;
    [self numberOfImagesUpdatedTo:0];
    [self.managedObjectContext performBlockAndWait:^{
        self.images = [NSOrderedSet new];
    }];
    [self requestImageDataForPage:1];
}

- (void)requestImageData {
    NSUInteger page = self.images.count == 0 ? 1 : (self.images.count / PHOTOS_PER_REQUEST.integerValue)+1;

    [self requestImageDataForPage:page];
}

- (void)requestImageDataForPage:(NSUInteger)page {
    if (self.imagesDataQueue.operationCount != 0 || self.images.count == self.maxNumberOfImages) return;

    NSLog(@"requesting image data for category %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.userInfo = @{@"page": @(page).stringValue, @"perPage": PHOTOS_PER_REQUEST};
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil || results == nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil) {
                NSLog(@"json parsing error: %@", error);
            } else {
                [self parseImageData:jsonDict];
            }
        }
    };

    [self.imagesDataQueue addOperation:operation];
}

- (void)parseImageData:(NSDictionary *)imageData {
    if (self.maxNumberOfImages == -1) self.maxNumberOfImages = ((NSNumber *)imageData[@"total_items"]).unsignedIntegerValue;
    NSLog(@"max number for category %@ is %lu", self.name, self.maxNumberOfImages);
    NSArray *photos = imageData[@"photos"];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSMutableOrderedSet *newImages = [NSMutableOrderedSet new];
        for (NSDictionary *photoData in photos) {
            ASImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
            image.name = photoData[@"name"];
            image.thumbnailURL = (NSString *)photoData[@"image_url"][0];
            image.fullURL = (NSString *)photoData[@"image_url"][1];
            [newImages addObject:image];
        }
        NSMutableOrderedSet *currentImages = self.images.mutableCopy;
        [currentImages addObjectsFromArray:newImages.array];
        self.images = (NSOrderedSet *)currentImages.copy;
    }];
    NSLog(@"image count after parse: %lu", self.images.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self numberOfImagesUpdatedTo:self.images.count];
    });
}

#pragma mark - Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageThumbnailUpdated:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageThumbnailUpdated:image];
        });
    }
}

- (void)imageFullUpdated:(ASImage *)image {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageFullUpdated:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageFullUpdated:image];
        });
    }
}

- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImagesUpdatedTo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate numberOfImagesUpdatedTo:numberOfImages];
        });
    }
}

@end
