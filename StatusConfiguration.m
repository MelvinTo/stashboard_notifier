//
//  StatusConfiguration.m
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import "StatusConfiguration.h"

@implementation StatusConfiguration

+ (void) registerDefaults {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"check_interval"] == nil) {
        [StatusConfiguration setCheckInterval:300]; // default value is check every 5 mins
    }
}

+ (NSString*) getStashboardURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"stashboard_url"];
}

+ (void) setStashboardURL: (NSString*) url {
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"stashboard_url"];
}

+ (NSInteger) getCheckInterval {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"check_interval"];
}

+ (void) setCheckInterval: (NSInteger) interval {
    [[NSUserDefaults standardUserDefaults] setInteger:interval forKey:@"check_interval"];
}

@end
