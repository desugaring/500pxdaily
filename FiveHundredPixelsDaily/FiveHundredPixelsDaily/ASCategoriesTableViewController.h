//
//  ASCategoriesTableViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASStore.h"
#import "ASCategoryTableViewCell.h"

@interface ASCategoriesTableViewController : UITableViewController <ASCategoryTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak) ASStore *store;

@end
