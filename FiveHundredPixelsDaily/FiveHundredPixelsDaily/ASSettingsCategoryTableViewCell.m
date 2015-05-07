//
//  ASSettingsCategoryTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASSettingsCategoryTableViewCell.h"

@implementation ASSettingsCategoryTableViewCell

- (void)prepareForReuse {
    self.backgroundColor = [UIColor blackColor];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureCellWithCategory:(ASCategory *)category {
    self.category = category;
    self.nameLabel.text = category.name;
}

@end
