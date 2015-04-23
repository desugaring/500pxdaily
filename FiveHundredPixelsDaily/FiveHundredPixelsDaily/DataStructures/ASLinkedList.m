//
//  ASLinkedList.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASLinkedList.h"

@implementation ASLinkedList

-(instancetype)initWithObject:(NSObject *)object {
    if (self = [super init]) {
        self.object = object;
    }

    return self;
}

@end
