//
//  ASSettingsNumberTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASSettingsNumberTableViewCell.h"

@implementation ASSettingsNumberTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    switch ((int)sender.value) {
        case 0:
            self.numberLabel.text = @"Zero";
            break;
        case 1:
            self.numberLabel.text = @"One";
            break;
        case 2:
            self.numberLabel.text = @"Two";
            break;
        case 3:
            self.numberLabel.text = @"Three";
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)sender.value forKey:@"NumberOfImagesPerCategory"];
}

@end
