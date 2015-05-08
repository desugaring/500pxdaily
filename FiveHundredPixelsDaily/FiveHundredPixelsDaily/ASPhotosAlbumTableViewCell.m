//
//  ASPhotosAlbumTableViewCell.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASPhotosAlbumTableViewCell.h"

@implementation ASPhotosAlbumTableViewCell

- (void)prepareForReuse {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.backgroundColor = [UIColor blackColor];
}

- (void)configureCellWithCollection:(PHCollection *)collection {
    self.collection = collection;
    self.textLabel.text = collection.localizedTitle;
}

@end
