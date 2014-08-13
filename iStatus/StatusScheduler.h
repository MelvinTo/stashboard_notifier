//
//  StatusScheduler.h
//  iStatus
//
//  Created by Melvin Tu on 14-8-11.
//  Copyright (c) 2014年 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocoStatusMonitoring.h"

@interface StatusScheduler : NSObject {
    NSWindowController* _preferenceWindowController;
}

@property (nonatomic, retain) RocoStatusMonitoring* monitoring;

+ (StatusScheduler*) getInstance;

- (void) start;
- (void) stop;
- (void) restart;

- (void) openPreferencesWindow;

@end
