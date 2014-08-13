//
//  StatusPreferenceViewController.m
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import "StatusPreferenceViewController.h"
#import "StatusConfiguration.h"
#import "StatusScheduler.h"

@interface StatusPreferenceViewController ()

@end

NSDictionary* tickValueMapping;


@implementation StatusPreferenceViewController

- (void)awakeFromNib {
    NSLog(@"awake from nib...");
    if ([self hasAppInLoginItem]) {
        NSLog(@" Application is on the auto start list");
        [_autoStartButton setState:NSOnState];
    } else {
        NSLog(@" Application is not on the auto start list");
        [_autoStartButton setState:NSOffState];
    }
    [self.stashboardURL setDelegate:self];
    
    // load url from config
    NSString* stashboardURLConfig = [StatusConfiguration getStashboardURL];
    if (stashboardURLConfig == nil) {
        stashboardURLConfig = @"";
    }
    [self.stashboardURL setStringValue:stashboardURLConfig];
    
    
    // init tick mapping
    tickValueMapping = @{
        @0 : @10, // FIXME...
        @1 : @60,
        @2 : @300,
        @3 : @900,
        @4 : @1800,
        @5 : @3600
    };
    
    NSInteger checkInterval = [StatusConfiguration getCheckInterval];
    
    NSInteger tickValue = [self value2Tick:checkInterval];
    
    [self.checkIntervalSlider setIntValue:(int)tickValue];
    
    // register for window close
    [[self.stashboardURL window] setDelegate:self];
    
    // default "is changed" is set to NO
    _isChangedInLastSession = NO;
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"preference window is closing");
    if (_isChangedInLastSession) {
        [[StatusScheduler getInstance] restart];
        _isChangedInLastSession = NO;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        // initialization code here
    }
    
    NSLog(@"init ...");
    
    return self;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    _isChangedInLastSession = YES;
    NSTextField* textField = (NSTextField*) [obj object];

    @synchronized(self) {
        [StatusConfiguration setStashboardURL:[textField stringValue]];
    }
    
}

-(IBAction) onAutoStartCheckbox:(id)sender {
    NSLog(@"AutoStartCheckbox is clicked");
    NSButton* checkbox = (NSButton*) sender;
    if (checkbox.state == NSOnState) {
        NSLog(@"Checkbox is on");
        [self addAppAsLoginItem];
    } else {
        NSLog(@"Checkbox is off");
        [self deleteAppFromLoginItem];
    }
}

-(IBAction) onSliderChange:(id)sender {
    NSLog(@"slider is changed");
    int checkIntervalTickMark = [self.checkIntervalSlider intValue];
    NSInteger intervalValue = [self tick2Value:checkIntervalTickMark];
    NSLog(@"current check interval value is %ld", (long)intervalValue);
    [StatusConfiguration setCheckInterval:intervalValue];
    _isChangedInLastSession = YES;
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

- (NSInteger) tick2Value: (NSInteger) tick {
    NSNumber* num = [tickValueMapping objectForKey:[NSNumber numberWithInteger:tick]];
    return [num integerValue];
}

- (NSInteger) value2Tick: (NSInteger) value {
    NSArray* arrayOfKeys = [tickValueMapping allKeysForObject:[NSNumber numberWithInteger:value]];
    NSNumber* num = [arrayOfKeys objectAtIndex:0];
    return [num integerValue];
}


@end
