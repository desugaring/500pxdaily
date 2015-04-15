//
//  ASBaseOperation.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASBaseOperation.h"
#import "ASCategory.h"
#import "ASImage.h"

@implementation ASBaseOperation

- (void)fetchDataWithObject:(NSManagedObject *)object userInfo:(NSDictionary *)userInfo completion:(CompletionBlock)completion {
    if ([object isKindOfClass: ASCategory.class]) {
        NSNumber *page = userInfo[@"page"];
        NSNumber *perPage = userInfo[@"perPage"];
        // get category data
    } else if ([object isKindOfClass: ASImage.class]) {
        NSString *size = userInfo[@"size"];
        // get image
    }

}

@end
