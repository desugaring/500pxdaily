//
//  ASCategory.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ASBaseObject.h"

typedef NS_ENUM(NSInteger, ASImageSize) {
    ASImageSizeThumbnail,
    ASImageSizeFull,
};

typedef NS_ENUM(NSInteger, ASCategoryState) {
    ASCategoryStateRefreshImmediately,
    ASCategoryStateStale,
    ASCategoryStateBusyRefreshing,
    ASCategoryStateBusyGettingImages,
    ASCategoryStateFree,
    ASCategoryStateUpToDate
};

@class ASImage, ASStore;

@protocol ASCategoryDelegate <NSObject>

@optional
- (void)imageThumbnailUpdated:(ASImage *)image withTask:(NSURLSessionDownloadTask *)task;
- (void)imageFullUpdated:(ASImage *)image withTask:(NSURLSessionDownloadTask *)task;

@end

@interface ASCategory : ASBaseObject <ASCategoryDelegate>

@property NSOrderedSet *mildImages;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) ASStore *store;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSNumber *isActive;
@property (nonatomic, retain) NSNumber *isDaily;
@property (nonatomic, retain) NSNumber *state;
@property (nonatomic, retain) NSNumber *maxNumberOfImages;

@property (weak) id<ASCategoryDelegate> delegate;
@property NSMutableArray *thumbnailDownloadTasks;

+ (void)downloadImageNumber:(NSInteger)imageNumber inTheBackgroundForCategory:(NSString *)categoryName;

- (void)imageThumbnailUpdated:(ASImage *)image withTask:(NSURLSessionDownloadTask *)task;
- (void)imageFullUpdated:(ASImage *)image withTask:(NSURLSessionDownloadTask *)task;

- (void)refreshImages;
- (BOOL)requestImageData;
- (void)cancelThumbnailDownloads;
- (void)refreshState;

@end
