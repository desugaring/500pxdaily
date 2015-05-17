//
//  ASBackgroundImageFetcher.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "ASCategory.h"

typedef void(^BackgroundFetchCompletionHandler)(UIBackgroundFetchResult);

@interface ASBackgroundImageFetcher : NSObject

+ (ASBackgroundImageFetcher *)sharedFetcher;

- (void)fetchImagesForCategories:(NSArray *)categories completionHandler:(BackgroundFetchCompletionHandler)completionHandler;

@end
