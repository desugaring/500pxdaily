//
//  ASImageTransformer.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-19.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImageTransformer.h"

@implementation ASImageTransformer

+ (Class)transformedValueClass {
    return [UIImage class];
}

+ (BOOL)allowsReverseTransformation {
    return true;
}

- (id)transformedValue:(id)value {
    NSData *data = (NSData *)value;
    return [UIImage imageWithData:data];
}

- (id)reverseTransformedValue:(id)value {
    UIImage *image = (UIImage *)value;
    return [NSData dataWithData:UIImagePNGRepresentation(image)];
}

@end
