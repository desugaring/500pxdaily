//
//  ASDownloadManager.m
//  URLSessionTest
//
//  Created by Alex Semenikhine on 2015-05-12.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASDownloadManager.h"
#import <libkern/OSAtomic.h>

@interface ASDownloadManager()

@property NSURLSession *session;
@property NSMutableDictionary *resumeData; // NSURL -> NSData

@end

@implementation ASDownloadManager

+ (ASDownloadManager *)sharedManager {
    static dispatch_once_t onceToken;
    static ASDownloadManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[ASDownloadManager alloc] init];
    });
    return manager;
}

static volatile int32_t runningTasks = 0;

+ (void)incrementTasks {
    OSAtomicIncrement32Barrier(&runningTasks);
    if (runningTasks > 0) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
}

+ (void)decrementTasks {
    OSAtomicDecrement32Barrier(&runningTasks);
    if (runningTasks == 0) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPShouldUsePipelining = true;
        config.HTTPMaximumConnectionsPerHost = 4;
        config.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:config];
        _resumeData = [NSMutableDictionary new];
    }
    return self;
}

- (NSURLSessionDataTask *)downloadDataWithURL:(NSURL *)url withCompletionBlock:(URLDataDownloadCompletionBlock)completionBlock {
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:completionBlock];
    [task resume];
    [ASDownloadManager incrementTasks];
    return task;
}

- (NSURLSessionDownloadTask *)downloadFileWithURL:(NSURL *)url withCompletionBlock:(URLFileDownloadCompletionBlock)completionBlock {
    NSData *data = [self.resumeData objectForKey:url];
    NSURLSessionDownloadTask *task;
    if (data != nil) {
        NSLog(@"resuming task for url: %@", url.absoluteString);
        task = [self.session downloadTaskWithResumeData:data completionHandler:completionBlock];
        [self.resumeData removeObjectForKey:url];

    } else {
        NSLog(@"starting new task for url: %@", url.absoluteString);
        task = [self.session downloadTaskWithURL:url completionHandler:completionBlock];
    }
    [task resume];
    [ASDownloadManager incrementTasks];
    return task;
}

- (void)cancelAllDownloadTasks {
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            [self cancelDownloadTask:task];
        }
    }];
}

- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)task {
    NSLog(@"cancelling task %@", task.currentRequest.URL.absoluteString);
    if (task.state == NSURLSessionTaskStateRunning) {
        [task cancelByProducingResumeData:^(NSData *resumeData) {
            if (resumeData != nil) {
                NSLog(@"saving resume data for %@", task.currentRequest.URL.absoluteString);
                self.resumeData[task.originalRequest.URL] = resumeData;
            }
        }];
    }
}

@end
