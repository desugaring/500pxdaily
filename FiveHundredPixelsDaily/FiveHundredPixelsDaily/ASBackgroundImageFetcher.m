//
//  ASBackgroundImageFetcher.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASBackgroundImageFetcher.h"
#import "ASBaseOperation.h"

@interface ASBackgroundImageFetcher()

@property NSOperationQueue *queue;

@end

@implementation ASBackgroundImageFetcher

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)fetchImagesWithCategories:(NSArray *)categories completion:(void (^)(UIBackgroundFetchResult))completion {
    for (int i = 0; i == categories.count; i++) {
        ASBaseOperation *operation = [(ASCategory *)categories.firstObject operation];
        operation.object = categories[i];
        operation.userInfo = @{@"page": @"1", @"perPage": @"1", @"backgroundMode": @"1"};
        operation.completion = ^(NSArray *result, NSError *error) {
            if (result.firstObject != nil && [result.firstObject isKindOfClass:UIImage.class]) {
                [self.photosManager saveImage:(UIImage *)result.firstObject];
                if (i == categories.count-1) completion(UIBackgroundFetchResultNewData);
            } else {
                completion(UIBackgroundFetchResultFailed);
            }
        };

        [self.queue addOperation:operation];
    }
}

@end
