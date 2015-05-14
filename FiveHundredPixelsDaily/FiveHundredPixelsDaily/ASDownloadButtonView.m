//
//  ASDownloadButtonView.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-13.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASDownloadButtonView.h"

@implementation ASDownloadButtonView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.buttonIsEnabled = false;
}

- (void)setEnabled:(BOOL)enabled {
    self.buttonIsEnabled = enabled;
    if (self.buttonIsEnabled == false) {
        self.iconImageView.alpha = 0.5;
        self.nameLabel.alpha = 0.5;
        ((UIGestureRecognizer *)self.gestureRecognizers.firstObject).enabled = false;
    } else {
        self.iconImageView.alpha = 1.0;
        self.nameLabel.alpha = 1.0;
        ((UIGestureRecognizer *)self.gestureRecognizers.firstObject).enabled = true;
    }
}

@end