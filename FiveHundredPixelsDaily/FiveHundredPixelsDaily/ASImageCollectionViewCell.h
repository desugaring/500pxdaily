//
//  ASImageCollectionViewCell.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-16.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASImageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end
