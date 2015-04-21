//
//  ASImage.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImage.h"
#import "ASBaseOperation.h"
#import "ASCategory.h"
#import "ASStore.h"

@interface ASImage()

@property (weak) ASBaseOperation *requestOperation;

@end

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic category;

@synthesize requestOperation;

- (ASBaseOperation *)operation {
    return self.category.operation;
}

- (void)awakeCommon {
    self.requestOperation = nil;
}

- (void)requestThumbnailImageIfNeeded {
    if (self.thumbnail == nil && self.requestOperation == nil) {
        NSLog(@"requesting image thumbnail for name %@", self.name);
        ASBaseOperation *operation = [self operation];
        operation.object = self;
        operation.completion = ^(NSArray *results, NSError *error) {
            if (error != nil) {
                NSLog(@"url response error: %@", error);
            } else if ([results[0] isKindOfClass:NSData.class]){
                NSData *data = (NSData *)results[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thumbnail = [UIImage imageWithData:data];
                    [self.category imageThumbnailUpdated:self];
                });
            }
        };

        [self.category.imageQueue addOperation:operation];
        self.requestOperation = operation;
    }
}

- (void)requestFullImageIfNeeded {
    if (self.full == nil && self.requestOperation == nil) {
        NSLog(@"requesting image full for name %@", self.name);
        ASBaseOperation *operation = [self operation];
        operation.object = self;
        operation.completion = ^(NSArray *results, NSError *error) {
            if (error != nil) {
                NSLog(@"url response error: %@", error);
            } else if ([results[0] isKindOfClass:NSData.class]){
                NSData *data = (NSData *)results[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.full = [UIImage imageWithData:data];
                    [self.category imageFullUpdated:self];
                });
            }
        };

        [self.category.imageQueue addOperation:operation];
        self.requestOperation = operation;
    }
}

- (void)cancelThumbnailRequestIfNeeded {
    if (self.requestOperation != nil) [self.requestOperation cancel];
}

- (void)cancelFullImageRequestIfNeeded {
    if (self.requestOperation != nil) [self.requestOperation cancel];
}

@end
