//
//  RocoAppDelegate.m
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoAppDelegate.h"
#import "StatusConfiguration.h"
#import "RocoStatusMonitoring.h"

@implementation RocoAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [StatusConfiguration registerDefaults];
    [[StatusScheduler getInstance] start];
}

@end
