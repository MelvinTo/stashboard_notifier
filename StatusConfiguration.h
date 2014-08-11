//
//  StatusConfiguration.h
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusConfiguration : NSObject

+ (NSString*) getStashboardURL;
+ (void) setStashboardURL: (NSString*) url;

+ (NSInteger) getCheckInterval;
+ (void) setCheckInterval: (NSInteger) interval;

+ (void) registerDefaults;

@end
