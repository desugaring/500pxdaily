//
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

@implementation ASCategory

@dynamic isActive;
@dynamic images;
@dynamic store;

- (void)resetImages {
    for (ASImage *image in self.images.allObjects) {
        [self.managedObjectContext deleteObject:image];
    }
}

- (void)requestImages {
    [self.store.operation fetchDataWithObject:self userInfo:@{ @"numberOfImages": @20 } completion:^(NSArray *results, NSError *error) {
        if (error == nil) {
            // add images
        } else {
            // handle error
        }
    }];
}

- (void)awakeCommon {
    [super awakeCommon];

    [self addObserver:self forKeyPath:@"isActive" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isActive"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"isActive"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == TRUE) {
            
        }
    }
}

@end
