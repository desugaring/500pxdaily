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
#import "ASBaseOperation.h"

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic categories;

- (void)requestFull {
    [((ASCategory *)self.categories.allObjects[0]).store.operation fetchDataWithObject:self userInfo:@{ @"size": @"full" } completion:^(NSArray *results, NSError *error) {
        if (error == nil) {
            // add image
        } else {
            // handle error
        }
    }];
}

- (void)requestThumbnail {
    [((ASCategory *)self.categories.allObjects[0]).store.operation fetchDataWithObject:self userInfo:@{ @"size": @"thumbnail" } completion:^(NSArray *results, NSError *error) {
        if (error == nil) {
            // add image
        } else {
            // handle error
        }
    }];
}

@end
