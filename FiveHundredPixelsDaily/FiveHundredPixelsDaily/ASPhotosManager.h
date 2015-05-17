//
//  ASPhotosManager.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;

@interface ASPhotosManager : NSObject

+ (ASPhotosManager *)sharedManager;

- (BOOL)saveImage:(UIImage *)image;

@end
