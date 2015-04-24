//
//  ASLinkedList.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-23.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASLinkedList : NSObject

@property (nonatomic) ASLinkedList *prev;
@property (nonatomic) ASLinkedList *next;
@property (readonly) NSObject *object;

- (instancetype)initWithObject:(NSObject *)object;

@end
