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

@property (nonatomic) BOOL isVisible;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) ASStore *store;

@property NSInteger maxNumberOfImages;
@property BOOL isFullsizeMode;
- (ASBaseOperation *)operation;

- (void)resetImages;
- (void)requestImageData;

@end

@interface ASCategory (CoreDataGeneratedAccessors)

- (void)addImagesObject:(ASImage *)value;
- (void)removeImagesObject:(ASImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
