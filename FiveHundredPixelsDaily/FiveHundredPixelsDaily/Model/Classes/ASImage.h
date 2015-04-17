//
//  ASImage.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ASBaseObject.h"
#import "ASBaseOperation.h"

@class ASCategory;

@interface ASImage : ASBaseObject

@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * fullURL;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) id full;
@property (nonatomic, retain) ASCategory *category;

@property BOOL isVisible;
@property BOOL isFullsizeMode;

- (ASBaseOperation *)operation;

@end
