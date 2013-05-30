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
    
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
//    return [menuItem isEnabled];
    return YES;
}

- (IBAction)actionAddToLoginItem:(id)sender {
    [self addAppAsLoginItem];
    [_openAtLoginItem setState: NSOnState];
    [_openAtLoginItem setAction:@selector(actionDeleteFromLoginItem:)];
}

- (IBAction)actionDeleteFromLoginItem:(id)sender {
    [self deleteAppFromLoginItem];
    [_openAtLoginItem setState: NSOffState];
    [_openAtLoginItem setAction:@selector(actionAddToLoginItem:)];

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
    
    _openAtLoginItem = [[NSMenuItem alloc] initWithTitle:@"Open iStatus at login" action:@selector(testAction:) keyEquivalent:@""];
    [_openAtLoginItem setTarget:self];
    [_openAtLoginItem setEnabled:YES];
    
    if([self hasAppInLoginItem]) {
        [_openAtLoginItem setState:NSOnState];
        [_openAtLoginItem setAction:@selector(actionDeleteFromLoginItem:)];
    } else {
        [_openAtLoginItem setState:NSOffState];
        [_openAtLoginItem setAction:@selector(actionAddToLoginItem:)];
    }
    
    [_statusMenu addItem:_openAtLoginItem];
    [_statusMenu addItem:_quitItem];
    
    [_statusItem setMenu:_statusMenu];
    [_statusItem setTitle:@""];
    
    [_statusMenu setAutoenablesItems:NO];

    [self updateSystemIcon:NORMAL]; // default normal

}

- (void) removeMenuItems {
    // remove all component status related items until the first item is the "open at login"
    while ([_statusMenu numberOfItems] > 0) {
        if (![[_statusMenu itemAtIndex:0] isEqualTo:_openAtLoginItem]) {
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
    
    [self removeMenuItems];
    [self updateMenuInfo: services];
}

- (void) openURL:(id)sender {
    RocoService *service = [sender representedObject];
    NSString *urlString = [self getServiceURL:service];
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

-(void) addAppAsLoginItem {
    NSLog(@"Add app into login item");
    
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

- (BOOL) hasAppInLoginItem {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
                    return YES;
				}
			}
		}
	}
    
    return NO;
}

-(void) deleteAppFromLoginItem{
    NSLog(@"Remove app from login item");
    
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

- (NSString*)getServiceURL:(RocoService *)service {
    return [NSString stringWithFormat:@"%@services/%@", _baseURLString, [service serviceID]];
}

- (void)setBaseURL:(NSString *)baseURLString {
    _baseURLString = baseURLString;
}

@end
