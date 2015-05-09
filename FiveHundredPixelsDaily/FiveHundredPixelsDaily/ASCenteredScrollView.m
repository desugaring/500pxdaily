//
//  ASCenteredScrollView.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCenteredScrollView.h"

@implementation ASCenteredScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.tileContainerView == nil) return;
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.tileContainerView.frame;

    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;

    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;

    self.tileContainerView.frame = frameToCenter;
}

@end
