//
//  ASCategory.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ASImage, Store;

@interface ASCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Store *store;
@end

@interface ASCategory (CoreDataGeneratedAccessors)

- (void)addImagesObject:(ASImage *)value;
- (void)removeImagesObject:(ASImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
