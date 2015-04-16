
//  ASCategory.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategory.h"
#import "ASImage.h"
#import "ASStore.h"
#import "ASBaseOperation.h"

@implementation ASCategory

@dynamic isVisible;
@dynamic images;
@dynamic store;
@synthesize maxNumberOfImages;
@synthesize isFullsizeMode;

- (ASBaseOperation *)operation {
    return self.store.operation;
}

- (void)resetImages {
    for (ASImage *image in self.images.allObjects) {
        [self.managedObjectContext deleteObject:image];
    }
}

- (void)requestImageData {
    NSLog(@"requesting image data for category %@", self.name);
    ASBaseOperation *operation = [self operation];
    operation.object = self;
    operation.completion = ^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"url response error: %@", error);
        } else if ([results[0] isKindOfClass:NSData.class]){
            NSData *data = (NSData *)results[0];
            //            NSDictionary *jsonDict = [[NSDictionary alloc] init]
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil) {
                NSLog(@"json parsing error: %@", error);
            } else {
                // parse json
                NSLog(@"json dict: %@", jsonDict);
            }
        }
    };

    
}

- (void)awakeCommon {
    [super awakeCommon];

    self.isFullsizeMode = false;
    [self addObserver:self forKeyPath:@"isVisible" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"isVisible"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"isVisible"]) {
        if ((BOOL)change[NSKeyValueChangeNewKey] == TRUE) {
            if (self.images.count == 0) {
                [self requestImageData];
            }
        }
    }
}

@end
