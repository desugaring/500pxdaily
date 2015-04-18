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

@property ASBaseOperation *thumbnailOperation;
@property ASBaseOperation *fullOperation;

@end

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic category;

@synthesize thumbnailOperation;
@synthesize fullOperation;

-(ASBaseOperation *)operation {
    return self.category.operation;
}

-(void)awakeCommon {
    [super awakeCommon];
}

- (void)requestThumbnailIfNeeded {
    NSLog(@"requesting image thumbnail for name %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            self.thumbnail = [UIImage imageWithData:data];
            self.thumbnailOperation = nil;

            [self.category thumbnailImageUpdated:self];
        }
    };

    [self.category.imageQueue addOperation:operation];
}

- (void)requestFullsizeIfNeeded {
    NSLog(@"requesting image full for name %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            self.full = [UIImage imageWithData:data];
            self.fullOperation = nil;

            [self.category fullImageUpdated:self];
        }
    };

    [self.category.imageQueue addOperation:operation];
}

- (void)cancelThumbnailRequestIfNeeded {
    if (self.thumbnailOperation != nil) [self.thumbnailOperation cancel];
}

- (void)cancelFullImageRequestIfNeeded {
    if (self.fullOperation != nil) [self.fullOperation cancel];
}

@end
