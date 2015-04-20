
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
@property NSInteger maxNumberOfImages;

@end

@implementation ASCategory

@dynamic images;
@dynamic store;
@dynamic lastUpdated;
@dynamic status;

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

- (void)setVisibleImages:(NSArray *)images ofSize:(ASImageSize)size {
//    NSSet *newVisibleCells = [NSSet setWithArray:[self.collectionView indexPathsForVisibleItems]];
//    if ([newVisibleCells isEqualToSet:self.visibleCells] == false) {
//        // Mark images that are no longer visible, by subtracting new visible cells from the old. Anything left over is no longer visible.
//        NSMutableSet *oldCells = [self.visibleCells mutableCopy];
//        [oldCells minusSet:newVisibleCells];
//        for (NSIndexPath *indexPath in oldCells) {
//            ((ASImage *)self.activeCategory.images[indexPath.row]).thumbnailVisible = false;
//        }
//        // Mark images that are newly visible, by subtracting old visible cells from the new.
//        NSMutableSet *newCells = [newVisibleCells mutableCopy];
//        [newCells minusSet:self.visibleCells];
//        for (NSIndexPath *indexPath in newCells) {
//            ((ASImage *)self.activeCategory.images[indexPath.row]).thumbnailVisible = true;
//        }
//    }

    // Load more images if needed
//    NSInteger distantImageIndex = ((NSIndexPath *)self.visibleIndexPaths.lastObject).item + 50;
//    if (self.category.images.count < distantImageIndex && self.category.images.count != self.category.maxNumberOfImages) {
//        [self.activeCategory requestImageData];
//    }
}

- (void)resetImages {
    [self removeImages:self.images];
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

        [self addImagesObject:image];
    }
    [self numberOfImagesUpdated];
}

#pragma mark - Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageThumbnailUpdated:)]) [self.delegate imageThumbnailUpdated:image];
}

- (void)imageFullUpdated:(ASImage *)image {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageFullUpdated:)]) [self.delegate imageFullUpdated:image];
}

- (void)numberOfImagesUpdated {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImagesUpdated)]) [self.delegate numberOfImagesUpdated];
}

@end
