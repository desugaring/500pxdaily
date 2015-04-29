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

@property NSManagedObject *object;
@property NSDictionary *userInfo;
@property (copy) CompletionBlock completion;

@end
