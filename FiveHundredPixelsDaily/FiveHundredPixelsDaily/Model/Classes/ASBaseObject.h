//
//  ASBaseObject.h
//  
//
//  Created by Alex Semenikhine on 2015-04-14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ASBaseObject : NSManagedObject

@property (nonatomic, retain) NSString * name;

- (void)awakeCommon;

@end
