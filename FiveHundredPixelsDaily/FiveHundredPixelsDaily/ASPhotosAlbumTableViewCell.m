//
//  ASPhotosAlbumTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASPhotosAlbumTableViewCell.h"

@implementation ASPhotosAlbumTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.backgroundColor = selected ? [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1] : [UIColor blackColor];
}

- (void)configureCellWithCollection:(PHCollection *)collection {
    self.collection = collection;
    self.textLabel.text = collection.localizedTitle;
}

@end
