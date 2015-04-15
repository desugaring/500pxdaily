//
//  ASBaseOperation.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;

typedef void(^CompletionBlock)(NSArray *results, NSError *error);

@interface ASBaseOperation : NSOperation

- (void)fetchDataWithObject:(NSManagedObject *)object userInfo:(NSDictionary *)userInfo completion:(CompletionBlock)completion;

// fetchDataForObject(Anyobject, userInfo: Dictionary?, completion: (data, error))

// get categories
// get category metadata
// get category page X
// get image thumbnail
// get image full

@end
