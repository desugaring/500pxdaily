//
//  ASSettingsCategoryTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASSettingsCategoryTableViewCell.h"

@implementation ASSettingsCategoryTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self changeState:selected];
}

- (void)configureCellWithCategory:(ASCategory *)category {
    self.category = category;
    self.nameLabel.text = category.name;

    [self changeState:self.category.isDaily.boolValue];
}

- (void)changeState:(BOOL)isDaily {
    self.category.isDaily = @(isDaily);

    self.accessoryType = isDaily ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.backgroundColor = isDaily ? [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1] : [UIColor blackColor];
}

@end
