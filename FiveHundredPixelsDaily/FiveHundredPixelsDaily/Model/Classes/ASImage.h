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

@class ASCategory;
@protocol ASImageDelegate;

@interface ASImage : ASBaseObject

@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSString *fullURL;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *full;
@property (nonatomic, retain) ASCategory *category;

@property (weak) id<ASImageDelegate> delegate;

- (void)requestThumbnailImageIfNeeded;
- (void)requestFullImageIfNeeded;

@end

@protocol ASImageDelegate <NSObject>

@optional
- (void)imageThumbnailUpdated:(ASImage *)image;
- (void)imageFullUpdated:(ASImage *)image;

@end
