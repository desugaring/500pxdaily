//
//  ASModel.h
//  
//
//  Created by Alex Semenikhine on 2015-04-18.
//
//

@import Foundation;
@import CoreData;

@class ASStore;

@interface ASModel : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *stores;

@end
