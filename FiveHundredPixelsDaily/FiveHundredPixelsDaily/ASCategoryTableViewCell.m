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
    self.nameLabel.text = category.name;
    self.stateLabel.text = category.status.stringValue;
    self.category = category;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stateChange:(UIButton *)sender {
    self.stateLabel.text = @"clicked!";
    NSLog(@"category: %@", self.category.name);
}

- (IBAction)categorySelected:(UIButton *)sender {
    NSLog(@"seleced");
}
@end
