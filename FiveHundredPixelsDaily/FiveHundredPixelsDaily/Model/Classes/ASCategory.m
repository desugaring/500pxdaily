
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

@interface ASCategory()

@property NSOperationQueue *imagesDataQueue;

@end

@implementation ASCategory

@dynamic images;
@dynamic store;
@dynamic lastUpdated;
@dynamic isActive;

@synthesize maxNumberOfImages;
@synthesize imagesDataQueue;
@synthesize imageQueue;
@synthesize delegate;

- (ASBaseOperation *)operation {
    return self.store.operation;
}

- (void)awakeCommon {
    [super awakeCommon];

    self.maxNumberOfImages = -1;

    self.imagesDataQueue = [[NSOperationQueue alloc] init];
    self.imagesDataQueue.maxConcurrentOperationCount = 1;

    self.imageQueue = [[NSOperationQueue alloc] init];
    self.imageQueue.maxConcurrentOperationCount = 1;
}

- (void)cancelImageRequests {
    [self.imageQueue cancelAllOperations];
}

- (void)resetImages {
    for (ASImage *image in self.images) {
        [self.managedObjectContext deleteObject:image];
    }
    self.maxNumberOfImages = -1;
    [self requestImageData];
}

- (void)requestImageData {
    if (self.imagesDataQueue.operationCount != 0 || self.images.count == self.maxNumberOfImages) return;

    NSLog(@"requesting image data for category %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            //            NSDictionary *jsonDict = [[NSDictionary alloc] init]
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
        self.maxNumberOfImages = ((NSNumber *)imageData[@"total_items"]).unsignedIntegerValue;

        NSArray *photos = imageData[@"photos"];
        for (NSDictionary *photoData in photos) {
            ASImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
            image.name = photoData[@"name"];
            image.thumbnailURL = (NSString *)photoData[@"image_url"][0];
            image.fullURL = (NSString *)photoData[@"image_url"][1];
            image.category = self;

            [self.managedObjectContext insertObject:image];
        }
//        [self.managedObjectContext save:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"image data parsed for category %@, num of images count: %@", self.name, @(self.images.count));
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
    NSLog(@"number of images updated in category %@", self.name);
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImagesUpdatedTo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate numberOfImagesUpdatedTo:numberOfImages];
        });
    }
}

@end
