//
//  ASDownloadManager.h
//  URLSessionTest
//
//  Created by Alex Semenikhine on 2015-05-12.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;

typedef void(^URLDataDownloadCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^URLFileDownloadCompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@interface ASDownloadManager : NSObject

+ (ASDownloadManager *)sharedManager;

+ (void)incrementTasks;
+ (void)decrementTasks;

- (NSURLSessionDataTask *)downloadDataWithURL:(NSURL *)url withCompletionBlock:(URLDataDownloadCompletionBlock)completionBlock;
- (NSURLSessionDownloadTask *)downloadFileWithURL:(NSURL *)url withCompletionBlock:(URLFileDownloadCompletionBlock)completionBlock ;
- (void)cancelAllDownloads;

@end
