//
//  ASCategoryTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryTableViewCell.h"

@implementation ASCategoryTableViewCell

- (void)configureCellWithCategory:(ASCategory *)category {
    self.category = category;

    self.nameLabel.text = category.name;
    [self changeState:self.category.isActive.boolValue];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse {
    self.viewButton.titleLabel.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.category.isActive = @(selected);
    [self changeState:selected];
}

- (void)changeState:(BOOL)isActive {
    self.category.isActive = @(isActive);

    self.viewButton.enabled = isActive;
    self.viewButton.hidden = !isActive;
//    self.nameLabel.textColor = isActive ? [UIColor whiteColor] : [UIColor colorWithWhite:0.8 alpha:1];
    self.accessoryType = isActive ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.backgroundColor = isActive ? [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1] : [UIColor blackColor];
}

- (IBAction)viewButtonClicked:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(goToCategory:)]) {
        [self.delegate goToCategory:self.category];
    }
}

@end
