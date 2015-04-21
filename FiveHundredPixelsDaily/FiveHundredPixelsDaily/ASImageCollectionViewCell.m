//
//  ASImageCollectionViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-16.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImageCollectionViewCell.h"

@implementation ASImageCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    [self.spinner startAnimating];
}

@end
