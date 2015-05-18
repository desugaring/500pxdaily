
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
#import "ASPhotosManager.h"

NSString * const PHOTOS_PER_REQUEST = @"30";
NSString * const FIVE_HUNDRED_PX_URL = @"https://api.500px.com/v1/photos";
NSString * const CONSUMER_KEY = @"8bFolgsX5BfAiMMH7GUDLLYDgQm4pjcTcDDAAHJY";

@interface ASCategory()

@property NSLock *stateLock;

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
@synthesize stateLock;
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

+ (void)downloadImageInTheBackgroundForCategory:(NSString *)categoryName {
    NSURL *url = [ASCategory urlForCategoryName:categoryName forPage:1];
    NSLog(@"requesting background image data for category %@, url %@", categoryName, url.absoluteString);

    // Get category's first page
    [[ASDownloadManager sharedManager] downloadDataWithURL:url withCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSError *jsonParsingError;
            NSDictionary *imageDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
            if (jsonParsingError == nil) {
                NSArray *photos = imageDictionary[@"photos"];
                // Get first photo info
                NSDictionary *photoData = (NSDictionary *)photos.firstObject;
                NSString *fullURL = (NSString *)photoData[@"image_url"][1];
                NSLog(@"requesting background full image from url: %@", fullURL);
                // Get image
                [[ASDownloadManager sharedManager] downloadFileWithURL:[NSURL URLWithString:fullURL] withCompletionBlock:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    if (location != nil) {
                        UIImage *fullImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                        BOOL success = [[ASPhotosManager sharedManager] saveImage:fullImage];
                        [ASCategory signalBackgroundFetchSuccess:success];
                    } else {
                        NSLog(@"background image fetch error: %@", error);
                        [ASCategory signalBackgroundFetchSuccess:false];
                    }
                }];
            } else {
                NSLog(@"background json parsing error: %@", jsonParsingError);
                [ASCategory signalBackgroundFetchSuccess:false];
            }
        } else {
            NSLog(@"background image data request response: %@, error: %@", response, error);
            [ASCategory signalBackgroundFetchSuccess:false];
        }
    }];
}

+ (void)signalBackgroundFetchSuccess:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackgroundFetchResult" object:nil userInfo:@{ @"success": @(success) }];
}

- (void)awakeCommon {
    [super awakeCommon];
    if (self.lastUpdated == nil) self.lastUpdated = [NSDate distantPast];
    self.stateLock = [NSLock new];
    self.thumbnailDownloadTasks = [NSMutableArray new];
}

- (void)refreshState {
    if (self.state.integerValue != ASCategoryStateUpToDate) {
        NSInteger minutesSinceLastUpdate = [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self.lastUpdated toDate:[NSDate date] options:0] minute];
        if (minutesSinceLastUpdate >= 60*12) {
            if (self.state.integerValue != ASCategoryStateRefreshImmediately) self.state = @(ASCategoryStateRefreshImmediately);
        } else if ((minutesSinceLastUpdate >= 60*6)) {
            if (self.state.integerValue != ASCategoryStateStale) self.state = @(ASCategoryStateStale);
        }
    }
}

- (void)refreshImages {
    self.maxNumberOfImages = @(-1);
    [self.stateLock lock];
    self.state = @(ASCategoryStateBusyRefreshing);
    [self.stateLock unlock];
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

- (BOOL)requestImageData {
    [self.stateLock lock];
    BOOL requestImages = (self.state.integerValue == ASCategoryStateBusyRefreshing || self.state.integerValue == ASCategoryStateFree);
    if (self.state.integerValue == ASCategoryStateFree) self.state = @(ASCategoryStateBusyGettingImages);
    [self.stateLock unlock];
    if (requestImages) {
        NSUInteger page = self.images.count == 0 ? 1 : (self.images.count / PHOTOS_PER_REQUEST.integerValue)+1;
        [self requestImageDataForPage:page];
    }
    return requestImages;
}

- (void)requestImageDataForPage:(NSUInteger)page {
    NSURL *url = [ASCategory urlForCategoryName:self.name forPage:page];
    NSLog(@"requesting image data for category %@, page %@, url %@", self.name, @(page), url.absoluteString);
    [[ASDownloadManager sharedManager] downloadDataWithURL:url withCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
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
        [self.stateLock lock];
        self.state = (self.images.count != 0) ? @(ASCategoryStateFree) : @(ASCategoryStateRefreshImmediately);
        [self.stateLock unlock];
    }];
}

- (void)parseImageData:(NSDictionary *)imageData {
    if (self.state.integerValue == ASCategoryStateBusyRefreshing) {
        self.maxNumberOfImages = (NSNumber *)imageData[@"total_items"];
        NSLog(@"max number for category %@ is %@", self.name, self.maxNumberOfImages);
    }
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
    [self.stateLock lock];
    self.state = (self.maxNumberOfImages.unsignedIntegerValue == self.images.count) ? @(ASCategoryStateUpToDate) : @(ASCategoryStateFree);
    [self.stateLock unlock];
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

@end
