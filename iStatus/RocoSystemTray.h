//
//  RocoSystemTray.h
//  TrackMic
//
//  Created by Tu Melvin on 5/16/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocoService.h"
#import "RocoStatusMonitoring.h"


@protocol RocoSystemTrayDelegate <NSObject>

- (NSString*) getServiceURL: (RocoService*) service;

@end

@interface RocoSystemTray : NSObject<RocoStatusMonitoringDelegate> {
    id<RocoSystemTrayDelegate> _delegate;
    
    NSStatusItem * _statusItem;
    IBOutlet NSMenu *_statusMenu;
    IBOutlet NSMenuItem *_quitItem;
    IBOutlet NSMenuItem *_openAtLoginItem;
    
    NSImage* _systemTrayIconImage;
    
    NSString* _baseURLString;
    
}

@property id<RocoSystemTrayDelegate> delegate;

- (void) initializeSystemTray;
- (void) setInformation: (NSString*) name;

- (IBAction)actionAddToLoginItem:(id)sender;
- (IBAction)actionDeleteFromLoginItem:(id)sender;
- (IBAction)quitAction:(id)sender;
- (IBAction) openURL:(id)sender;

@end
