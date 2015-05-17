//
//  ASBackgroundImageFetcher.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-05.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASBackgroundImageFetcher.h"
#import "ASPhotosManager.h"
#import "ASDownloadManager.h"


@interface ASBackgroundImageFetcher()

@property NSDate *lastFetched;
@property (copy, nonatomic) BackgroundFetchCompletionHandler backgroundCompletionHandler;

@end

@implementation ASBackgroundImageFetcher

+ (instancetype)sharedFetcher {
    static dispatch_once_t onceToken;
    static ASBackgroundImageFetcher *fetcher;
    dispatch_once(&onceToken, ^{
        fetcher = [[ASBackgroundImageFetcher alloc] init];
    });
    return fetcher;
}

- (instancetype)init {
    if (self = [super init]) {
        _lastFetched = [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTaskResponse:) name:@"BackgroundFetchResult" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BackgroundFetchResult" object:nil];
}

static int numberofSuccessfulBackgroundFetches;
static int numberOfFetches;

- (void)receiveTaskResponse:(NSNotification *)notification {
    BOOL success = ((NSNumber *)notification.userInfo[@"success"]).boolValue;
    if (success == true) {
        numberofSuccessfulBackgroundFetches++;
        if (numberofSuccessfulBackgroundFetches == numberOfFetches) self.backgroundCompletionHandler(UIBackgroundFetchResultNewData);
    } else {
        [[ASDownloadManager sharedManager] cancelAllDownloadTasks];
        self.backgroundCompletionHandler(UIBackgroundFetchResultFailed);
    }
}

- (void)fetchImagesForCategories:(NSArray *)categories completionHandler:(BackgroundFetchCompletionHandler)completionHandler {
    if ([ASDownloadManager sharedManager].reachability.isReachable == false) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    NSInteger hoursSinceLastFetch = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self.lastFetched toDate:[NSDate date] options:0] hour];
    if(hoursSinceLastFetch >= 12) {
        self.lastFetched = [NSDate date];
        self.backgroundCompletionHandler = completionHandler;
        numberOfFetches = (int)categories.count;
        numberofSuccessfulBackgroundFetches = 0;
        for (NSString *categoryName in categories) {
            [ASCategory downloadImageInTheBackgroundForCategory:categoryName];
        }
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
