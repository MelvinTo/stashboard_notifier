//
//  StatusPreferenceWindow.m
//  iStatus
//
//  Created by Melvin Tu on 14-8-11.
//  Copyright (c) 2014年 Tu Melvin. All rights reserved.
//

#import "StatusPreferenceWindow.h"

@implementation StatusPreferenceWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    
    if (self) {
        // initialization code here
        [self setLevel:NSStatusWindowLevel];
        [self makeKeyAndOrderFront:self];
    }
    NSLog(@"init ......");
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    
    if (self) {
        // initialization code here
        [self setLevel:NSStatusWindowLevel];
        [self makeKeyAndOrderFront:self];
    }
    NSLog(@"init ...");
    return self;

}
@end
