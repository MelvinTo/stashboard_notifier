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

@end

@interface RocoStatusMonitoring : NSObject {
    NSTimer *_timer;
}

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) id<RocoStatusMonitoringDelegate> delegate;

- (void) startMonitoring;

@end
