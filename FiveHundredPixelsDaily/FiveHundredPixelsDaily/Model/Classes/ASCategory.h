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
#import "ASBaseOperation.h"

typedef NS_ENUM(NSInteger, ASImageSize) {
    ASImageSizeThumbnail,
    ASImageSizeFull,
};

@class ASImage, ASStore;

@protocol ASCategoryImageDelegate <NSObject>

@optional
- (void)imageThumbnailUpdated:(ASImage *)image;
- (void)imageFullUpdated:(ASImage *)image;
- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages;

@end

@interface ASCategory : ASBaseObject <ASCategoryImageDelegate>

@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) ASStore *store;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSNumber *isActive;

@property NSOperationQueue *imageQueue;
@property (weak) id<ASCategoryImageDelegate> delegate;
@property NSInteger maxNumberOfImages;

- (void)imageThumbnailUpdated:(ASImage *)image;
- (void)imageFullUpdated:(ASImage *)image;
- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages;

- (void)resetImages;
- (void)cancelImageRequests;
- (void)requestImageData;

@end

@interface ASCategory (CoreDataGeneratedAccessors)

- (void)insertObject:(ASImage *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImagesAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(ASImage *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray *)values;
- (void)addImagesObject:(ASImage *)value;
- (void)removeImagesObject:(ASImage *)value;
- (void)addImages:(NSOrderedSet *)values;
- (void)removeImages:(NSOrderedSet *)values;

@end

