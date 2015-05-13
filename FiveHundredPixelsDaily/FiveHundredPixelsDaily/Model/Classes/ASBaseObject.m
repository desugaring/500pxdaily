//
//  BaseObject.m
//  
//
//  Created by Alex Semenikhine on 2015-04-14.
//
//

#import "ASBaseObject.h"

@implementation ASBaseObject

@dynamic name;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self awakeCommon];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self awakeCommon];
}

- (void)awakeCommon {
    // Stub
}

@end
