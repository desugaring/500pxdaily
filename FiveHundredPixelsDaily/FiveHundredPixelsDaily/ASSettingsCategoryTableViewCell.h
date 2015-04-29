//
//  ASSettingsCategoryTableViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCategory.h"

@interface ASSettingsCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak) ASCategory *category;

- (void)configureCellWithCategory:(ASCategory *)category;

@end
