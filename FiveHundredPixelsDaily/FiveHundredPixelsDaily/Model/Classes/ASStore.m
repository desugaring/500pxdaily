//
//  ASStore.m
//  
//
//  Created by Alex Semenikhine on 2015-04-11.
//
//

#import "ASStore.h"
#import "ASCategory.h"
#import "ASBaseOperation.h"
#import "ASPhotosOperation.h"
#import "ASFHPOperation.h"


@implementation ASStore

@dynamic categories;
@dynamic type;

- (void)updateCategories {
//    [self.operation fetchDataWithObject:self userInfo:@{@"name": @"Alex"} completion: ^(NSString *someThing){
//        NSLog(@"jesus christ, %@", someThing);
//    }];
    [self.operation fetchDataWithObject:self userInfo:nil completion:^(NSString *someString) {
        NSLog(@"someString is: %@", someString);
    }];
}

- (ASBaseOperation *)operation {
    if ([self.type isEqualToString:@"photos"]) {
        NSLog(@"photos");
        return [[ASPhotosOperation alloc] init];
    } else if ([self.type isEqualToString:@"fhp"]) {
        NSLog(@"fhp");
        return [[ASFHPOperation alloc] init];
    }

    return [[ASBaseOperation alloc] init];
}

@end