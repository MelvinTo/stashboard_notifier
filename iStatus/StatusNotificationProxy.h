//
//  StatusNotificationProxy.h
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocoService.h"

@interface StatusNotificationProxy : NSObject

+ (StatusNotificationProxy*) getInstance;

- (void) onNotReachable;
- (void) onNewServiceStatuses: (NSArray*) services;

@property (nonatomic, retain) NSUserNotification* lastNotification;

@end
