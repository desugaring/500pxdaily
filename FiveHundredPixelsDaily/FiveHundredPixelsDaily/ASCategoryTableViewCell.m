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
    self.stateLabel.text = [category.isActive isEqualToNumber:@(0)] ? @"INACTIVE" : @"ACTIVE";
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stateChange:(UIButton *)sender {
    self.category.isActive = [self.category.isActive isEqualToNumber:@(0)] ? @(1) : @(0);

    self.stateLabel.text = [self.category.isActive isEqualToNumber:@(0)] ? @"INACTIVE" : @"ACTIVE";
}

@end
