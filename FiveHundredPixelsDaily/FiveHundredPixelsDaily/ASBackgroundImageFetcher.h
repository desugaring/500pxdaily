//
//  ASBackgroundImageFetcher.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASCategory.h"
#import "ASPhotosManager.h"

@interface ASBackgroundImageFetcher : NSObject

@property ASPhotosManager *photosManager;

- (void)fetchImagesWithCategories:(NSArray *)categories completion:(void (^)(UIBackgroundFetchResult))completion;

@end
