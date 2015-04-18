//
//  ASImage.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
@import CoreData;
#import "ASBaseObject.h"
#import "ASBaseOperation.h"

@class ASCategory;

@interface ASImage : ASBaseObject

@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSString *fullURL;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *full;
@property (nonatomic, retain) ASCategory *category;

- (void)requestThumbnailImageIfNeeded;
- (void)requestFullImageIfNeeded;

- (void)cancelThumbnailRequestIfNeeded;
- (void)cancelFullImageRequestIfNeeded;

@end
