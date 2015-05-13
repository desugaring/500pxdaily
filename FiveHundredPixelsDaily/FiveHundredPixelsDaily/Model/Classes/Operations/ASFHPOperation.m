//
//  ASFHPOperation.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-11.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASFHPOperation.h"
#import "ASStore.h"
#import "ASCategory.h"
#import "ASImage.h"

@implementation ASFHPOperation

//NSString * const FIVE_HUNDRED_PX_URL = @"https://api.500px.com/v1/photos";
//NSString * const CONSUMER_KEY = @"8bFolgsX5BfAiMMH7GUDLLYDgQm4pjcTcDDAAHJY";

- (void)main {
    if ([self.object isKindOfClass: ASCategory.class]) {
//        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:FIVE_HUNDRED_PX_URL];
//        urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"consumer_key" value:CONSUMER_KEY],
//                                     [NSURLQueryItem queryItemWithName:@"only" value:((ASCategory *)self.object).name],
//                                     [NSURLQueryItem queryItemWithName:@"rpp" value:self.userInfo[@"perPage"]],
//                                     [NSURLQueryItem queryItemWithName:@"feature" value:@"upcoming"],
//                                     [NSURLQueryItem queryItemWithName:@"sort" value:@"times_viewed"],
//                                     [NSURLQueryItem queryItemWithName:@"image_size[0]" value:@"2"],
//                                     [NSURLQueryItem queryItemWithName:@"image_size[1]" value:@"4"],
//                                     [NSURLQueryItem queryItemWithName:@"page" value:self.userInfo[@"page"]]];
//
//        if (self.userInfo[@"backgroundMode"]) {
//            [self sendBackgroundCategoryRequestWithURL:urlComponents.URL];
//        } else {
//            [self sendRequestWithURL:urlComponents.URL];
//        }
//        NSLog(@"request url: %@", urlComponents.string);

    } else if ([self.object isKindOfClass: ASImage.class]) {
        ASImage *image = (ASImage *)self.object;
        NSString *size = self.userInfo[@"size"];

        // Get image
        NSURL *url = [size isEqualToString:@"thumbnail"] ? [NSURL URLWithString:image.thumbnailURL] : [NSURL URLWithString:image.fullURL];
        [self sendRequestWithURL:url];
    }
}

- (void)sendRequestWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(NSTimeInterval)20];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil || responseData == nil) {
        NSLog(@"error not nil: %@", error);
        self.completion(@[], error);
    } else {
        self.completion(@[responseData], error);
    }
}

- (void)sendBackgroundCategoryRequestWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(NSTimeInterval)5];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil || responseData == nil) {
        NSLog(@"error getting background category data: %@", error);
        self.completion(@[], error);
    } else {
        // Get Image
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if (error != nil) {
            NSLog(@"background fetch json parsing error: %@", error);
            self.completion(@[], error);
        } else {
            // Parse image data
            NSArray *photos = jsonDict[@"photos"];
            NSDictionary *firstPhoto = (NSDictionary *)photos.firstObject;
            // Get image name and full URL only
            NSString *fullImageURL = (NSString *)firstPhoto[@"image_url"][1];
            // Request full image
            [self sendBackgroundImageRequestWithURL:[NSURL URLWithString:fullImageURL]];
        }
    }
}

- (void)sendBackgroundImageRequestWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(NSTimeInterval)20];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil || responseData == nil) {
        NSLog(@"error not nil: %@", error);
        self.completion(@[], error);
    } else {
        UIImage *image = [UIImage imageWithData:responseData];
        self.completion(@[image], error);
    }
}

- (void)cancel {
    [super cancel];
    NSLog(@"tried to cancel request for object %@", self.object);
}

@end
