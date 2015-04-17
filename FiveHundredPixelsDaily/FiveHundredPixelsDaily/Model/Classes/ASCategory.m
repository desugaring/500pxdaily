
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

@dynamic isVisible;
@dynamic images;
@dynamic store;
@synthesize maxNumberOfImages;
@synthesize imagesDataQueue;
@synthesize imageThumbnailQueue;
@synthesize imageFullQueue;

- (ASBaseOperation *)operation {
    return self.store.operation;
}

- (void)awakeCommon {
    [super awakeCommon];

    self.maxNumberOfImages = -1;

    self.imagesDataQueue = [[NSOperationQueue alloc] init];
    self.imagesDataQueue.maxConcurrentOperationCount = 1;

    self.imageThumbnailQueue = [[NSOperationQueue alloc] init];
    self.imageThumbnailQueue.maxConcurrentOperationCount = 1;

    self.imageFullQueue = [[NSOperationQueue alloc] init];
    self.imageFullQueue.maxConcurrentOperationCount = 1;

    [self addObserver:self forKeyPath:@"isVisible" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isVisible"];
}

- (void)resetImages {
    for (ASImage *image in self.images.allObjects) {
        [self.managedObjectContext deleteObject:image];
    }
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
    if (self.maxNumberOfImages == 0) {
        self.maxNumberOfImages = ((NSNumber *)imageData[@"total_items"]).unsignedIntegerValue;
    }
    NSArray *photos = imageData[@"photos"];
    for (NSDictionary *photoData in photos) {
        ASImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
//        image.identifier = photoData[@"id"];
        image.name = photoData[@"name"];
        image.thumbnailURL = (NSString *)photoData[@"image_url"][0];
        image.fullURL = (NSString *)photoData[@"image_url"][1];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"isVisible"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == true) {
            if (self.images.count == 0) {
                [self requestImageData];
            }
        } else if ((BOOL)change[NSKeyValueChangeNewKey] == false) {
            [self.imagesDataQueue cancelAllOperations];
            [self.imageThumbnailQueue cancelAllOperations];
            [self.imageFullQueue cancelAllOperations];
        }
    }
}

@end
