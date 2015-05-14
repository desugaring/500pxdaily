//
//  ASCategoryCollectionViewController.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASCategory.h"
#import "ASImage.h"

@protocol ASCategoryCollectionViewControllerDelegate <NSObject>

- (void)categoryImageWasSelected:(ASImage *)image;

@end

@interface ASCategoryCollectionViewController : UICollectionViewController <ASCategoryDelegate>

@property (weak) ASCategory *category;
@property (weak) id<ASCategoryCollectionViewControllerDelegate> delegate;

@end
