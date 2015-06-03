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
    self.backgroundColor = [UIColor blackColor];
    self.viewButton.hidden = true;
    self.rightArrow.hidden = true;
}

- (IBAction)viewButtonClicked:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(goToCategory:)]) [self.delegate goToCategory:self.category];
}

@end
