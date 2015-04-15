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

@class ASImage, ASStore;

@interface ASCategory : ASBaseObject

@property (nonatomic) BOOL isActive;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) ASStore *store;

- (void)resetImages;
- (void)requestImages;

@end

@interface ASCategory (CoreDataGeneratedAccessors)

- (void)addImagesObject:(ASImage *)value;
- (void)removeImagesObject:(ASImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
