//
//  RocoStatusMonitoring.h
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#import "RocoService.h"
#import "RocoEvent.h"
#import "RocoStatus.h"

@protocol RocoSystemTrayDelegate;

@protocol RocoStatusMonitoringDelegate <NSObject>

- (void) updateServices: (NSArray*) services;
- (void) setBaseURL: (NSString*)baseURLString;
- (void) onNotReachable;

@end

@interface RocoStatusMonitoring : NSObject<NSUserNotificationCenterDelegate> {
    NSTimer *_timer;
    NSArray *_prevServiceStatuses;
}

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) id<RocoStatusMonitoringDelegate> delegate;

- (void) startMonitoring;
- (void) stopMonitoring;

@end
