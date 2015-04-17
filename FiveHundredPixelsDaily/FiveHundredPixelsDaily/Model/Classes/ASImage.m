//
//  ASImage.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImage.h"
#import "ASCategory.h"
#import "ASStore.h"

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic category;
@synthesize isVisible;
@synthesize isFullsizeMode;

-(ASBaseOperation *)operation {
    return self.category.operation;
}

-(void)awakeCommon {
    [super awakeCommon];

    self.isFullsizeMode = false;
    self.isVisible = false;

    [self addObserver:self forKeyPath:@"isVisible" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isFullsizeMode" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isVisible"];
    [self removeObserver:self forKeyPath:@"isFullsizeMode"];
}

- (void)requestThumbnail {

}

- (void)requestFullsize {

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"isVisible"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == true) {
            [self requestThumbnail];
        }
    } else if (object == self && [keyPath isEqualToString:@"isFullsizeMode"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == true) {
            [self requestFullsize];
        }
    }
}

@end
