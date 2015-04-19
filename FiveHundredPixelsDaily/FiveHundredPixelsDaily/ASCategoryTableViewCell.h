//
//  ASCategoryTableViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCategory.h"

@interface ASCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak) ASCategory *category;

- (IBAction)stateChange:(UIButton *)sender;
- (IBAction)categorySelected:(UIButton *)sender;

@end
