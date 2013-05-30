//
//  RocoAppDelegate.h
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RocoSystemTray.h"


@interface RocoAppDelegate : NSObject <NSApplicationDelegate> {
    RocoSystemTray* systemTray;
}

@property (assign) IBOutlet NSWindow *window;

@end
