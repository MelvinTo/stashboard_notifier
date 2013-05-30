//
//  RocoAppDelegate.m
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoAppDelegate.h"

#import "RocoStatusMonitoring.h"

@implementation RocoAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    systemTray = [[RocoSystemTray alloc] init];
    [systemTray initializeSystemTray];
//    [systemTray setDelegate:self];
    
    
    RocoStatusMonitoring *monitoring = [[RocoStatusMonitoring alloc ] init];
    [monitoring setDelegate:systemTray];
    [monitoring startMonitoring];
}

@end
