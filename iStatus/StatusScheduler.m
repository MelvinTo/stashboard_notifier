//
//  StatusScheduler.m
//  iStatus
//
//  Created by Melvin Tu on 14-8-11.
//  Copyright (c) 2014年 Tu Melvin. All rights reserved.
//

#import "StatusScheduler.h"
#import "RocoSystemTray.h"
#import "StatusConfiguration.h"

@implementation StatusScheduler

+ (StatusScheduler*) getInstance {
    static StatusScheduler* _instance = nil;
    if (_instance == nil) {
        _instance = [[StatusScheduler alloc] init];
    }
    return _instance;
}

- (void)start {
    NSLog(@"StatusScheduler is starting job");
    NSLog(@"URL: %@", [StatusConfiguration getStashboardURL]);
    NSLog(@"CheckInterval: %ld", [StatusConfiguration getCheckInterval]);
    self.monitoring = [[RocoStatusMonitoring alloc ] init];
    [self.monitoring setDelegate:[RocoSystemTray getSystemTray]];
    [self.monitoring startMonitoring];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self.monitoring];
}

- (void)stop {
    [self.monitoring stopMonitoring];
    self.monitoring = nil;
}

- (void)restart {
    NSLog(@"StatusScheduler is restarting job");
    [self stop];
    [self start];
}

@end
