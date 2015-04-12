//
//  ASBaseOperation.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;

//typedef void(^CompletionBlock)(NSString *someString, NSString *someOtherString);

@interface ASBaseOperation : NSOperation

//- (instancetype)initWithURL:(NSURL *)url delegate:(NSObject *)delegate
//- (instancetype)initWithExternalDataFetcher:(PDExternalDataFetcher *)externalDataFetcher secondaryDataFetcher:(PDExternalDataFetcher *)secondaryDataFetcher;
- (void)fetchDataWithObject:(NSManagedObject *)object userInfo:(NSDictionary *)userInfo completion:(void(^)())completion;

// fetchDataForObject(Anyobject, userInfo: Dictionary?, completion: (data, error))

// get categories
// get category metadata
// get category page X
// get image thumbnail
// get image full

@end
