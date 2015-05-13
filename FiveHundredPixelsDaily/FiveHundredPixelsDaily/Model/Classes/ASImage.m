//
//  ASImage.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASImage.h"
#import "ASCategory.h"
#import "ASStore.h"
#import "ASDownloadManager.h"

@interface ASImage()

@property BOOL gettingImage;
@property NSLock *gettingImageLock;

@end

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic category;

@synthesize delegate;
@synthesize gettingImageLock;
@synthesize gettingImage;

- (void)awakeCommon {
    self.gettingImageLock = [[NSLock alloc] init];
    self.gettingImage = false;
}

- (void)requestThumbnailImageIfNeeded {
    [self.gettingImageLock lock];
    BOOL getImage = (self.gettingImage == false && self.thumbnail == nil);
    if (getImage == true) self.gettingImage = true;
    [self.gettingImageLock unlock];
    if (getImage) {
        NSLog(@"requesting thumbnail for image named %@", self.name);
        [[ASDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:self.thumbnailURL] withCompletionBlock:^(NSURL *location, NSURLResponse *response, NSError *error) {
            [ASDownloadManager decrementTasks];
            if (location != nil) {
                [self.managedObjectContext performBlockAndWait:^{
                    self.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.category imageThumbnailUpdated:self];
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageThumbnailUpdated:)]) [self.delegate imageThumbnailUpdated:self];
                    });
                }];
            } else {
                NSLog(@"response for thumbnail request is %@, error is %@", response, error);
            }
            [self.gettingImageLock lock];
            self.gettingImage = false;
            NSLog(@"setting getting image to false for %@", self.name);
            [self.gettingImageLock unlock];
        }];
    }
}

- (void)requestFullImageIfNeeded {
    [self.gettingImageLock lock];
    BOOL getImage = (self.gettingImage == false && self.thumbnail == nil);
    if (getImage == true) self.gettingImage = true;
    [self.gettingImageLock unlock];
    if (getImage) {
        //        NSLog(@"requesting thumbnail for image named %@", self.name);
        [[ASDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:self.thumbnailURL] withCompletionBlock:^(NSURL *location, NSURLResponse *response, NSError *error) {
            [ASDownloadManager decrementTasks];
            if (location != nil) {
                [self.managedObjectContext performBlockAndWait:^{
                    self.full = [UIImage imageWithContentsOfFile:location.absoluteString];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.category imageFullUpdated:self];
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageFullUpdated:)]) [self.delegate imageFullUpdated:self];
                    });
                }];
            } else {
                NSLog(@"response for full image request is %@, error is %@", response, error);
            }
            [self.gettingImageLock lock];
            self.gettingImage = false;
            [self.gettingImageLock unlock];
        }];
    }
}

@end
