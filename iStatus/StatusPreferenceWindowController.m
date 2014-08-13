//
//  StatusPreferenceWindowController.m
//  iStatus
//
//  Created by Melvin Tu on 14-8-11.
//  Copyright (c) 2014年 Tu Melvin. All rights reserved.
//

#import "StatusPreferenceWindowController.h"

@interface StatusPreferenceWindowController ()

@end

@implementation StatusPreferenceWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.window makeKeyAndOrderFront:self];
}

@end
