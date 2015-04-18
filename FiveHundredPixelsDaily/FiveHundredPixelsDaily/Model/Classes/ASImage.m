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
@synthesize thumbnailVisible;
@synthesize fullVisible;
@synthesize thumbnailOperation;
@synthesize fullOperation;

-(ASBaseOperation *)operation {
    return self.category.operation;
}

-(void)awakeCommon {
    [super awakeCommon];

    self.thumbnailVisible = false;
    self.fullVisible = false;

    [self addObserver:self forKeyPath:@"thumbnailVisible" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"fullVisible" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"thumbnailVisible"];
    [self removeObserver:self forKeyPath:@"fullVisible"];
}

- (void)requestThumbnail {
    NSLog(@"requesting image thumbnail for name %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            self.thumbnail = [UIImage imageWithData:data];
            if (self.thumbnailVisible == true) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ThumbnailArrived" object:self];
                self.thumbnailOperation = nil;
            }
        }
    };

    [self.category.imageThumbnailQueue addOperation:operation];
}

- (void)requestFullsize {
    NSLog(@"requesting image full for name %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            self.full = [UIImage imageWithData:data];
            if (self.fullVisible == true) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FullArrived" object:self];
                self.fullOperation = nil;
            }
        }
    };

    [self.category.imageFullQueue addOperation:operation];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"thumbnailVisible"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == true) {
            if (self.thumbnail == nil) [self requestThumbnail];
        } else {
            if (self.thumbnailOperation != nil) [self.thumbnailOperation.cancel];
        }
    } else if (object == self && [keyPath isEqualToString:@"fullVisible"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == true) {
            if (self.full == nil) [self requestFullsize];
        } else {
            if (self.fullOperation != nil) [self.fullOperation cancel];
        }
    }
}

@end
