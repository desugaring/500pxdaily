//
//  ASButtonView.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-03.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASButtonView.h"

@implementation ASButtonView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.buttonIsEnabled = false;
}

- (void)setEnabled:(BOOL)enabled {
    self.buttonIsEnabled = enabled;
    if (self.buttonIsEnabled == false) {
        self.iconImageView.hidden = true;
        ((UIGestureRecognizer *)self.gestureRecognizers.firstObject).enabled = false;
    } else {
        self.iconImageView.hidden = false;
        ((UIGestureRecognizer *)self.gestureRecognizers.firstObject).enabled = true;
    }
}

@end
