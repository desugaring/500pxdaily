//
//  ASBackgroundImageFetcher.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASCategory.h"

@interface ASBackgroundImageFetcher : NSObject

- (void)fetchImagesWithCategories:(NSArray *)categories completion:(void (^)(UIBackgroundFetchResult))completion;

@end
