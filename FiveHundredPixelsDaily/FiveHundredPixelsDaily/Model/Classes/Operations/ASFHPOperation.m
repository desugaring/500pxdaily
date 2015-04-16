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

NSString * const FIVE_HUNDRED_PX_URL = @"https://api.500px.com/v1/photos";
NSString * const CONSUMER_KEY = @"8bFolgsX5BfAiMMH7GUDLLYDgQm4pjcTcDDAAHJY";
NSString * const PHOTOS_PER_REQUEST = @"20";

- (void)main {
    if ([self.object isKindOfClass: ASCategory.class]) {
        ASCategory *category = (ASCategory *)self.object;
        // Determine page
        NSUInteger page = 1;

        // Get category data
        NSURL *url = [self urlForCategoryPage:page];
        [self sendRequestWithURL:url];

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

    self.completion(@[responseData], error);
}

- (NSURL *)urlForCategoryPage:(NSUInteger)page {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:FIVE_HUNDRED_PX_URL];
    urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:@"consumer_key" value:CONSUMER_KEY],
                                 [NSURLQueryItem queryItemWithName:@"only" value:self.name],
                                 [NSURLQueryItem queryItemWithName:@"rpp" value:PHOTOS_PER_REQUEST],
                                 [NSURLQueryItem queryItemWithName:@"feature" value:@"upcoming"],
                                 [NSURLQueryItem queryItemWithName:@"sort" value:@"times_viewed"],
                                 [NSURLQueryItem queryItemWithName:@"image_size[0]" value:@"2"],
                                 [NSURLQueryItem queryItemWithName:@"image_size[1]" value:@"4"],
                                 [NSURLQueryItem queryItemWithName:@"page" value:[@(page) stringValue]]];
    NSLog(@"request url: %@", urlComponents.string);

    return urlComponents.URL;
}

@end
