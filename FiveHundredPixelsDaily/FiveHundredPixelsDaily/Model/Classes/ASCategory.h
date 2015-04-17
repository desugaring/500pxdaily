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

@class ASImage, ASStore;

@interface ASCategory : ASBaseObject

@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) ASStore *store;

@property NSInteger maxNumberOfImages;

@property NSOperationQueue *imageThumbnailQueue;
@property NSOperationQueue *imageFullQueue;

- (void)resetImages;
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

