//
//  ASBackgroundImageFetcher.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASBackgroundImageFetcher.h"
#import "ASBaseOperation.h"
@import Photos;

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
                [self saveImageToPhotos:(UIImage *)result.firstObject];
                if (i == categories.count-1) completion(UIBackgroundFetchResultNewData);
            } else {
                completion(UIBackgroundFetchResultFailed);
            }
        };

        [self.queue addOperation:operation];
    }
}

- (void)saveImageToPhotos:(UIImage *)image {
    NSString *albumIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbumIdentifier"];

    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
    PHAssetCollection *collection = (PHAssetCollection *)result.firstObject;

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

        if (collection != nil) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];
}

@end
