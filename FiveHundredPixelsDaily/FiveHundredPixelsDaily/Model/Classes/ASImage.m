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

@property BOOL gettingThumbnail;
@property BOOL gettingFull;
@property NSLock *thumbnailLock;
@property NSLock *fullLock;
@property (weak) NSURLSessionDownloadTask *thumbnailTask;
@property (weak) NSURLSessionDownloadTask *fullTask;

@end

@implementation ASImage

@dynamic thumbnailURL;
@dynamic fullURL;
@dynamic thumbnail;
@dynamic full;
@dynamic category;

@synthesize delegate;
@synthesize thumbnailLock;
@synthesize fullLock;
@synthesize gettingThumbnail;
@synthesize gettingFull;
@synthesize thumbnailTask;
@synthesize fullTask;

- (void)awakeCommon {
    self.thumbnailLock = [NSLock new];
    self.fullLock = [NSLock new];
    self.gettingThumbnail = false;
    self.gettingFull = false;
    self.thumbnailTask = nil;
    self.fullTask = nil;
}

- (void)requestThumbnailImageIfNeeded {
    [self.thumbnailLock lock];
    BOOL getImage = (self.gettingThumbnail == false && self.thumbnail == nil);
    if (getImage == true) self.gettingThumbnail = true;
    [self.thumbnailLock unlock];
    if (getImage) {
//        NSLog(@"requesting thumbnail for image named %@", self.name);
        self.thumbnailTask = [[ASDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:self.thumbnailURL] withCompletionBlock:^(NSURL *location, NSURLResponse *response, NSError *error) {
            BOOL retryDownload = false;
            if (location != nil) {
                [self.managedObjectContext performBlockAndWait:^{
                    self.thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.category imageThumbnailUpdated:self];
                    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageThumbnailUpdated:)]) [self.delegate imageThumbnailUpdated:self];
                });
            } else {
                NSLog(@"response for thumbnail request is %@, error is %@", response, error);
                if (error != nil && error.code == NSURLErrorTimedOut) retryDownload = true;
            }
            [self.thumbnailLock lock];
            self.gettingThumbnail = false;
            [self.category.thumbnailDownloadTasks removeObject:self.thumbnailTask];
            [self.thumbnailLock unlock];
            if (retryDownload == true) [self requestThumbnailImageIfNeeded];
        }];
        [self.category.thumbnailDownloadTasks addObject:self.thumbnailTask];
    }
}

- (void)requestFullImageIfNeeded {
    [self.fullLock lock];
    BOOL getImage = (self.gettingFull == false && self.full == nil);
    if (getImage == true) self.gettingFull = true;
    [self.fullLock unlock];
    if (getImage) {
        //        NSLog(@"requesting thumbnail for image named %@", self.name);
        self.fullTask = [[ASDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:self.fullURL] withCompletionBlock:^(NSURL *location, NSURLResponse *response, NSError *error) {
            BOOL retryDownload = false;
            if (location != nil) {
                [self.managedObjectContext performBlockAndWait:^{
                    self.full = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.category imageFullUpdated:self];
                    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageFullUpdated:)]) [self.delegate imageFullUpdated:self];
                });
            } else {
                NSLog(@"response for full image request is %@, error is %@", response, error);
                if (error != nil && error.code == NSURLErrorTimedOut) retryDownload = true;
            }
            [self.fullLock lock];
            self.gettingFull = false;
            [self.fullLock unlock];
            if (retryDownload == true) [self requestFullImageIfNeeded];
        }];
    }
}

- (void)cancelThumbnailRequestIfNeeded {
    if (self.thumbnailTask != nil) [[ASDownloadManager sharedManager] cancelDownloadTask:self.thumbnailTask];
}

- (void)cancelFullRequestIfNeeded {
    if (self.fullTask != nil) [[ASDownloadManager sharedManager] cancelDownloadTask:self.fullTask];
}

@end
