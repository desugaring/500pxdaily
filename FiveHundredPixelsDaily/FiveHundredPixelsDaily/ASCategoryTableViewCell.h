//
//  ASCategoryTableViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCategory.h"

@protocol ASCategoryTableViewCellDelegate;

@interface ASCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;
@property (weak) ASCategory *category;
@property (weak) id<ASCategoryTableViewCellDelegate> delegate;

- (void)configureCellWithCategory:(ASCategory *)category;
- (IBAction)viewButtonClicked:(id)sender;

@end

@protocol ASCategoryTableViewCellDelegate <NSObject>

- (void)goToCategory:(ASCategory *)category;

@end