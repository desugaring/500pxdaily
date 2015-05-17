//
//  ASDownloadManager.h
//  URLSessionTest
//
//  Created by Alex Semenikhine on 2015-05-12.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

@import UIKit;
#import "Reachability.h"

typedef void(^URLDataDownloadCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^URLFileDownloadCompletionBlock)(NSURL *location, NSURLResponse *response, NSError *error);

@interface ASDownloadManager : NSObject

@property Reachability *reachability;

+ (ASDownloadManager *)sharedManager;

+ (void)incrementTasks;
+ (void)decrementTasks;

- (NSURLSessionDataTask *)downloadDataWithURL:(NSURL *)url withCompletionBlock:(URLDataDownloadCompletionBlock)completionBlock;
- (NSURLSessionDownloadTask *)downloadFileWithURL:(NSURL *)url withCompletionBlock:(URLFileDownloadCompletionBlock)completionBlock ;
- (void)cancelAllDownloadTasks;
- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)task;

@end
