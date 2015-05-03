//
//  ASCategoryTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryTableViewCell.h"

@interface ASCategoryTableViewCell()


- (IBAction)stateChange:(UIButton *)sender;
//- (IBAction)categorySelected:(UIButton *)sender;

@end

@implementation ASCategoryTableViewCell

- (void)configureCellWithCategory:(ASCategory *)category {
    self.category = category;

    self.nameLabel.text = category.name;
    [self changeState:self.category.isActive.boolValue];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected == true) {
        self.nameLabel.textColor = [UIColor grayColor];
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.nameLabel.textColor = self.category.isActive.boolValue ? [UIColor whiteColor] : [UIColor colorWithWhite:0.8 alpha:1];
        self.backgroundColor = self.category.isActive.boolValue ? [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] : [UIColor clearColor];
    }
}

- (IBAction)stateChange:(UIButton *)sender {
    BOOL oppositeIsActive = [self.category.isActive isEqualToNumber:@(false)];
    [self changeState:oppositeIsActive];
}

- (void)changeState:(BOOL)isActive {
    self.category.isActive = @(isActive);

    self.stateLabel.text = isActive ? @"ACTIVE": @"INACTIVE";
    self.stateLabel.textColor = isActive ? [UIColor whiteColor] : [UIColor grayColor];
    self.nameLabel.textColor = isActive ? [UIColor whiteColor] : [UIColor colorWithWhite:0.8 alpha:1];
    self.accessoryType = isActive ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.backgroundColor = isActive ? [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] : [UIColor clearColor];
}

@end
