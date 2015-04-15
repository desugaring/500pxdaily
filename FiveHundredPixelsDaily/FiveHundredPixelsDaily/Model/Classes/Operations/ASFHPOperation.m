//
//  ASFHPOperation.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASFHPOperation.h"
#import "ASStore.h"
#import "ASCategory.h"
#import "ASImage.h"

@implementation ASFHPOperation

- (void)fetchDataWithObject:(NSManagedObject *)object userInfo:(NSDictionary *)userInfo completion:(CompletionBlock)completion {
    //    if ([userInfo[@"name"] isKindOfClass: NSString.class]) {
    //        completion(userInfo[@"name"]);
    //    } else {
    //        completion(@"fuck");
    //    }
    if ([object isKindOfClass: ASStore.class]) {

    } else if ([object isKindOfClass: ASCategory.class]) {

    } else if ([object isKindOfClass: ASImage.class]) {

    }
}

- (NSArray *)categories {
    return @[@"Abstract", @"Animals", @"Black and White", @"Celebrities", @"City & Architecture", @"Commercial", @"Concert", @"Family", @"Fashion", @"Film", @"Fine Art", @"Food", @"Journalism", @"Landscapes", @"Macro", @"Nature", @"People", @"Performing Arts", @"Sport", @"Still Life", @"Street", @"Transportation", @"Travel", @"Underwater", @"Urban Exploration", @"Wedding"];
}

@end
