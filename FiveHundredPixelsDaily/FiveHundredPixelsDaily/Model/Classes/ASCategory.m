
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
@property NSTimer *stalenessTimer;

@end

@implementation ASCategory

@dynamic images;
@dynamic store;
@dynamic lastUpdated;
@dynamic isActive;
@dynamic isDaily;
@dynamic state;
@dynamic maxNumberOfImages;

@synthesize delegate;
@synthesize gettingImages;
@synthesize gettingImagesLock;
@synthesize thumbnailDownloadTasks;
@synthesize stalenessTimer;

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
    self.gettingImages = false;
    self.gettingImagesLock = [NSLock new];
    self.thumbnailDownloadTasks = [NSMutableArray new];
    [self refreshState];
    self.stalenessTimer = [NSTimer timerWithTimeInterval:30*60 target:self selector:@selector(refreshState) userInfo:nil repeats:true];
}

- (void)refreshState {
    if (self.state.integerValue != ASCategoryStateUpToDate) {
        NSInteger minutesSinceLastUpdate = [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self.lastUpdated toDate:[NSDate date] options:0] minute];
        if (minutesSinceLastUpdate >= 60*6) {
            self.state = @(ASCategoryStateRefreshImmediately);
        } else if ((minutesSinceLastUpdate >= 30)) {
            self.state = @(ASCategoryStateStale);
        }
    }
}

- (void)willTurnIntoFault {
    [super willTurnIntoFault];
    [self.stalenessTimer invalidate];
}

- (void)refreshImages {
    self.maxNumberOfImages = @(-1);
    [self numberOfImagesUpdatedTo:0];
    [self.managedObjectContext performBlockAndWait:^{
        for (ASImage *image in self.images) {
            [self.managedObjectContext deleteObject:image];
        }
        self.images = [NSOrderedSet new];
        NSLog(@"done resetting images to empty set");
    }];
    [self requestImageData];
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
    BOOL getImages = (self.gettingImages == false && self.state.integerValue == ASCategoryStateNeedsMoreImages);
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
    NSURL *url = [ASCategory urlForCategoryName:self.name forPage:page];
    NSLog(@"requesting image data for category %@, page %@, url %@", self.name, @(page), url.absoluteString);
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
    // If first page, set new max items
    if (self.images.count == 0) self.maxNumberOfImages = (NSNumber *)imageData[@"total_items"];
    NSLog(@"max number for category %@ is %@", self.name, self.maxNumberOfImages);

    // If current max number of items is out of date, the whole category is out of date, so don't let any new images in
    if ([self.maxNumberOfImages isEqualToNumber:(NSNumber *)imageData[@"total_items"]] == false) {
        self.maxNumberOfImages = @(self.images.count);
        self.state = @(ASCategoryStateStale);
        NSLog(@"category number of images out of date!, %@", self.name);
    // Otherwise all is well, add new images to the category
    } else {
        NSArray *photos = imageData[@"photos"];
        [self.managedObjectContext performBlockAndWait:^{
            NSMutableOrderedSet *newImages = [NSMutableOrderedSet new];
            for (NSDictionary *photoData in photos) {
                ASImage *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
                image.name = photoData[@"name"];
                image.thumbnailURL = (NSString *)photoData[@"image_url"][0];
                image.fullURL = (NSString *)photoData[@"image_url"][1];
                [newImages addObject:image];
            }
            NSMutableOrderedSet *currentImages = self.images.mutableCopy;
            [currentImages addObjectsFromArray:newImages.array];
            self.images = (NSOrderedSet *)currentImages.copy;
        }];
        if (self.maxNumberOfImages.unsignedIntegerValue == self.images.count) {
            self.state = @(ASCategoryStateUpToDate);
        } else if (self.state.integerValue != ASCategoryStateNeedsMoreImages) {
            self.state = @(ASCategoryStateNeedsMoreImages);
        }
    }
    [self.gettingImagesLock lock];
    self.gettingImages = false;
    [self.gettingImagesLock unlock];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self numberOfImagesUpdatedTo:self.images.count];
    });
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
