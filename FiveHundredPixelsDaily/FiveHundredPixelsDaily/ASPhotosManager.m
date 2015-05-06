//
//  ASPhotosManager.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASPhotosManager.h"
@import Photos;

@implementation ASPhotosManager

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"SaveImageToPhotos" object:nil queue:[NSOperationQueue currentQueue]  usingBlock:^(NSNotification *note) {
            [self saveImage:(UIImage *)note.userInfo[@"image"]];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SaveImageToPhotos" object:nil];
}

- (void)saveImage:(UIImage *)image {
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
