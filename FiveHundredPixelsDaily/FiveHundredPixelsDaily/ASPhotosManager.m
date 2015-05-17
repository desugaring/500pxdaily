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

+ (ASPhotosManager *)sharedManager {
    static dispatch_once_t onceToken;
    static ASPhotosManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[ASPhotosManager alloc] init];
    });
    return manager;
}

- (BOOL)saveImage:(UIImage *)image {
    NSString *albumIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbumIdentifier"];
    if (albumIdentifier == nil) return false;
    
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
    PHAssetCollection *collection = (PHAssetCollection *)result.firstObject;

    NSError *error;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

        if (collection != nil) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } error:&error];
    return (error == nil);
}

@end
