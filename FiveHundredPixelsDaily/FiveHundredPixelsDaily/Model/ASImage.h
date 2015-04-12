//
//  ASImage.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ASCategory;

@interface ASImage : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * fullURL;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) id full;
@property (nonatomic, retain) NSSet *categories;
@end

@interface ASImage (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(ASCategory *)value;
- (void)removeCategoriesObject:(ASCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
