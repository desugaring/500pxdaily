//
//  ASBaseObject.h
//  
//
//  Created by Alex Semenikhine on 2015-04-14.
//
//

@import Foundation;
@import CoreData;
#import "ASBaseOperation.h"

@interface ASBaseObject : NSManagedObject

@property (nonatomic, retain) NSString *name;

- (void)awakeCommon;

@end