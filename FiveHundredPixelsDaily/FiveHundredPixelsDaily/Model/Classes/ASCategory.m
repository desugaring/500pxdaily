
//  ASCategory.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategory.h"
#import "ASImage.h"
#import "ASStore.h"
#import "ASDownloadManager.h"

NSString * const PHOTOS_PER_REQUEST = @"30";
NSString * const FIVE_HUNDRED_PX_URL = @"https://api.500px.com/v1/photos";
NSString * const CONSUMER_KEY = @"8bFolgsX5BfAiMMH7GUDLLYDgQm4pjcTcDDAAHJY";

@interface ASCategory()

@property BOOL gettingImages;
@property NSLock *gettingImagesLock;

@end

@implementation ASCategory

@dynamic images;
@dynamic store;
@dynamic lastUpdated;
@dynamic isActive;
@dynamic isDaily;

@synthesize maxNumberOfImages;
@synthesize delegate;

@synthesize gettingImages;
@synthesize gettingImagesLock;
@synthesize thumbnailDownloadTasks;

+ (NSURL *)urlForCategoryName:(NSString *)name forPage:(NSUInteger)page {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:FIVE_HUNDRED_PX_URL];
    urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"consumer_key" value:CONSUMER_KEY],
                                 [NSURLQueryItem queryItemWithName:@"only" value:name],
                                 [NSURLQueryItem queryItemWithName:@"rpp" value:PHOTOS_PER_REQUEST],
                                 [NSURLQueryItem queryItemWithName:@"feature" value:@"upcoming"],
                                 [NSURLQueryItem queryItemWithName:@"sort" value:@"times_viewed"],
                                 [NSURLQueryItem queryItemWithName:@"image_size[0]" value:@"2"],
                                 [NSURLQueryItem queryItemWithName:@"image_size[1]" value:@"4"],
                                 [NSURLQueryItem queryItemWithName:@"page" value:@(page).stringValue]];
    return urlComponents.URL;
}

- (void)awakeCommon {
    [super awakeCommon];

    if (self.lastUpdated == nil) self.lastUpdated = [NSDate distantPast];
    self.maxNumberOfImages = -1;
    self.gettingImages = false;
    self.gettingImagesLock = [NSLock new];
    self.thumbnailDownloadTasks = [NSMutableArray new];
}

- (void)resetImages {
    self.maxNumberOfImages = -1;
    [self numberOfImagesUpdatedTo:0];
    [self.managedObjectContext performBlock:^{
        for (ASImage *image in self.images) {
            [self.managedObjectContext deleteObject:image];
        }
        self.images = [NSOrderedSet new];
        NSLog(@"done resetting images to empty set");
    }];
    [self requestImageDataForPage:1];
}

- (void)cancelThumbnailDownloads {
    NSArray *downloadTasks = self.thumbnailDownloadTasks.copy;
    for (NSURLSessionDownloadTask *task in downloadTasks) {
        [[ASDownloadManager sharedManager] cancelDownloadTask:task];
    }
    [self.thumbnailDownloadTasks removeAllObjects];
}

- (void)requestImageData {
    [self.gettingImagesLock lock];
    BOOL getImages = (self.gettingImages == false && self.images.count != self.maxNumberOfImages);
    if (getImages == true) self.gettingImages = true;
    [self.gettingImagesLock unlock];
    if (getImages) {
        NSUInteger page = self.images.count == 0 ? 1 : (self.images.count / PHOTOS_PER_REQUEST.integerValue)+1;
        [self requestImageDataForPage:page];
    }
}

- (void)requestImageDataForPage:(NSUInteger)page {
    [self.gettingImagesLock lock];
    self.gettingImages = true;
    [self.gettingImagesLock unlock];
    NSLog(@"requesting image data for category %@, page %@", self.name, @(page));
    NSURL *url = [ASCategory urlForCategoryName:self.name forPage:page];
    [[ASDownloadManager sharedManager] downloadDataWithURL:url withCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        [ASDownloadManager decrementTasks];
        if (data != nil) {
            NSError *jsonParsingError;
            NSDictionary *imageDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
            if (jsonParsingError == nil) {
                [self parseImageData:imageDictionary];
                return;
            } else {
                NSLog(@"json parsing error: %@", jsonParsingError);
            }
        } else {
            NSLog(@"image data request response: %@, error: %@", response, error);
        }
        // Lock unlocks because of error OR in parseImageData if all goes well
        [self.gettingImagesLock lock];
        self.gettingImages = false;
        [self.gettingImagesLock unlock];
    }];
}

- (void)parseImageData:(NSDictionary *)imageData {
    if (self.maxNumberOfImages == -1) {
        self.maxNumberOfImages = ((NSNumber *)imageData[@"total_items"]).unsignedIntegerValue;
        NSLog(@"max number for category %@ is %lu", self.name, (long)self.maxNumberOfImages);
    }
    NSArray *photos = imageData[@"photos"];

    [self.managedObjectContext performBlock:^{
        NSLog(@"starting to perform");
        NSMutableOrderedSet *newImages = [NSMutableOrderedSet new];
        for (NSDictionary *photoData in photos) {
            ASImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
            image.name = photoData[@"name"];
            image.thumbnailURL = (NSString *)photoData[@"image_url"][0];
            image.fullURL = (NSString *)photoData[@"image_url"][1];
            [newImages addObject:image];
        }
        NSLog(@"setting current images");
        NSMutableOrderedSet *currentImages = self.images.mutableCopy;
        [currentImages addObjectsFromArray:newImages.array];
        self.images = (NSOrderedSet *)currentImages.copy;
        NSLog(@"set current images");
        [self.gettingImagesLock lock];
        self.gettingImages = false;
        NSLog(@"changed getting images to false");
        [self.gettingImagesLock unlock];
        NSLog(@"going to send async msg");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self numberOfImagesUpdatedTo:self.images.count];
        });
    }];
}

#pragma mark - Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageThumbnailUpdated:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageThumbnailUpdated:image];
        });
    }
}

- (void)imageFullUpdated:(ASImage *)image {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageFullUpdated:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageFullUpdated:image];
        });
    }
}

- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages {
    self.lastUpdated = [NSDate date];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImagesUpdatedTo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate numberOfImagesUpdatedTo:numberOfImages];
        });
    }
}

@end
