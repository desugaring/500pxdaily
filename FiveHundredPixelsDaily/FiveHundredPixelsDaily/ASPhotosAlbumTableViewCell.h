//
//  ASPhotosAlbumTableViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
@import Photos;

@interface ASPhotosAlbumTableViewCell : UITableViewCell

@property PHCollection *collection;

- (void)configureCellWithCollection:(PHCollection *)collection;

@end
