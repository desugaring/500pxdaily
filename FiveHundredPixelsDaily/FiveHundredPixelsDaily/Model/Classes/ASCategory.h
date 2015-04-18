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
- (void)thumbnailImageUpdated:(ASImage *)image;
- (void)fullImageUpdated:(ASImage *)image;
- (void)numberOfImagesUpdated;

@end

@interface ASCategory : ASBaseObject <ASCategoryImageDelegate>

@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) ASStore *store;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSNumber *status;

@property NSOperationQueue *imageQueue;
@property (weak) id<ASCategoryImageDelegate> delegate;

- (void)thumbnailImageUpdated:(ASImage *)image;
- (void)fullImageUpdated:(ASImage *)image;
- (void)numberOfImagesUpdated;

- (void)setVisibleImages:(NSArray *)images ofSize:(ASImageSize)size;
- (void)resetImages;

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

