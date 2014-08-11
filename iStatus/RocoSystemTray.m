//
//  RocoSystemTray.m
//  TrackMic
//
//  Created by Tu Melvin on 5/16/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoSystemTray.h"
#import "DDHotKeyCenter.h"


@implementation RocoSystemTray

@synthesize delegate = _delegate;

+ (RocoSystemTray*) getSystemTray {
    static RocoSystemTray* _instance = nil;
    if (_instance == nil) {
        _instance = [[RocoSystemTray alloc] init];
        [_instance initializeSystemTray];
    }
    
    return _instance;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
//    return [menuItem isEnabled];
    return YES;
}

- (IBAction)quitAction:(id)sender {
	[NSApp terminate:sender];
}

- (void)initializeSystemTray
{
    NSLog(@"Adding item to system status bar");
    
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusMenu = [[NSMenu alloc] init];
    
    _quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit iStatus" action:@selector(quitAction:) keyEquivalent:@"q"];
    [_quitItem setKeyEquivalentModifierMask:NSCommandKeyMask];

    [_quitItem setTarget:self];
    [_quitItem setEnabled:YES];
    
    _preferenceItem = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(openPreferences:) keyEquivalent:@"p"];
    [_preferenceItem setTarget:self];
    [_preferenceItem setEnabled:YES];

    [_statusMenu addItem:_preferenceItem];
    [_statusMenu addItem:_quitItem];
    
    [_statusItem setMenu:_statusMenu];
    [_statusItem setTitle:@""];
    
    [_statusMenu setAutoenablesItems:NO];

    [self updateSystemIcon:NORMAL]; // default normal

}

- (void) clearMenuItems {
    // remove all component status related items until the first item is the "open at login"
    while ([_statusMenu numberOfItems] > 0) {
        if (![[_statusMenu itemAtIndex:0] isEqualTo:_preferenceItem]) {
            [_statusMenu removeItemAtIndex:0];
        } else {
            break;
        }
    }
}

- (STATUS_ID) getMostCriticalStatus: (NSArray*) services {
    STATUS_ID status = NORMAL;
    for (RocoService* service in services) {
        if ([[[service event] status] getStatus] > status) {
            status = [[[service event] status] getStatus];
        }
    }
    
    return status;
}

- (void)updateServices:(NSArray *)services {
    NSLog(@"current most critical status: %d", [self getMostCriticalStatus:services]);
    [self updateSystemIcon:[self getMostCriticalStatus:services]];
    for (RocoService* service in services) {
        if([[[service event] status] getStatus] != NORMAL) {
            NSLog(@"%d: %@", [[[service event] status] getStatus], [[service event] message]);
        }
    }
    
    [self clearMenuItems];
    [self updateMenuInfo: services];
}

- (void)onNotReachable {
    [self updateSystemIcon:UNKNOWN];
}

- (void) openURL:(id)sender {
    RocoService *service = [sender representedObject];
    NSString *urlString = [service getServiceURL:_baseURLString];
    NSLog(@"Try to open url: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] )
        NSLog(@"Failed to open url: %@",[url description]);
}

- (void)updateMenuInfo:(NSArray *) services {
    NSUInteger i = 0;
    
    for (RocoService* service in services) {
        if ([[[service event] status] getStatus] > NORMAL) {
            NSMenuItem* serviceNameMenuItem = [[NSMenuItem alloc] initWithTitle:[service serviceName] action:nil keyEquivalent:@""];
            [serviceNameMenuItem setEnabled:NO];
            
            NSMenuItem* serviceInfoMenuItem = [[NSMenuItem alloc] initWithTitle:[[service event] message]  action:@selector(openURL:) keyEquivalent:@""];
            [serviceInfoMenuItem setEnabled:YES];
            [serviceInfoMenuItem setTarget:self];
            [serviceInfoMenuItem setRepresentedObject:service];
            
            if([[[service event] status] getStatus] == WARNING) {
                [serviceInfoMenuItem setImage:[NSImage imageNamed:@"warning"]];
            }
            
            if ([[[service event] status] getStatus] == ERROR) {
                [serviceInfoMenuItem setImage:[NSImage imageNamed:@"error"]];
            }
            
            [_statusMenu insertItem:serviceNameMenuItem atIndex:i++];
            [_statusMenu insertItem:serviceInfoMenuItem atIndex:i++];
            [_statusMenu insertItem:[NSMenuItem separatorItem] atIndex:i++];
        }
    }
}

- (void)updateSystemIcon: (STATUS_ID) statusID {
    NSString* icon=@"";
    
    if(statusID == NORMAL) {
        icon=@"normal";
    } else if(statusID == WARNING) {
        icon=@"warning";
    } else if(statusID == ERROR) {
        icon=@"error";
    } else {
        icon=@"unknown";
    }

    _systemTrayIconImage = [NSImage imageNamed:icon];

    [_statusItem setImage:_systemTrayIconImage];

}

- (void) setInformation: (NSString *)name {
    
}

- (void)setBaseURL:(NSString *)baseURLString {
    _baseURLString = baseURLString;
}

- (IBAction)openPreferences:(id)sender {
     _preferenceWindowController =[[NSWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
    [_preferenceWindowController showWindow:self];
}

@end
