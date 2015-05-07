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
}

- (void)prepareForReuse {
    self.viewButton.hidden = true;
    self.backgroundColor = [UIColor blackColor];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.category.isActive = @(selected);
//    self.viewButton.enabled = selected;
    self.viewButton.hidden = !selected;
    self.accessoryType = selected ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.backgroundColor = selected ? [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1] : [UIColor blackColor];
}

- (IBAction)viewButtonClicked:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(goToCategory:)]) [self.delegate goToCategory:self.category];
}

@end
