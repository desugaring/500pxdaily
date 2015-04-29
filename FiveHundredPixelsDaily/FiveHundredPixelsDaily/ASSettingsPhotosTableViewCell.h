//
//  ASSettingsPhotosTableViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASSettingsPhotosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *photosAlbumLabel;

- (IBAction)editAlbum:(UIButton *)sender;

@end
