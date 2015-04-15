//
//  ASRemoteStore.h
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ASStore.h"
#import "ASCategory.h"


@interface ASRemoteStore : ASStore

@property (readonly) ASCategory *activeCategory;
-(void)setActiveCategory:(ASCategory *)activeCategory;

@end
