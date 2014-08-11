//
//  StatusNotificationProxy.m
//  iStatus
//
//  Created by Melvin Tu on 8/9/14.
//  Copyright (c) 2014 Tu Melvin. All rights reserved.
//

#import "StatusNotificationProxy.h"

@implementation StatusNotificationProxy

+ (StatusNotificationProxy*) getInstance {
    static StatusNotificationProxy* _instance = nil;
    if (_instance == nil) {
        _instance = [[StatusNotificationProxy alloc] init];
        _instance.lastNotification = nil;
    }
    return _instance;
}

- (void) onNotReachable {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    NSString* notificationTitle = @"Stashboard service is not reachable!";
    notification.title = notificationTitle;
    
    //    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    
    // ignore duplication of such notification.
    if (! [self.lastNotification.title isEqualToString:notificationTitle]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        self.lastNotification = notification;
    }

}

- (void) onNewServiceStatuses: (NSArray*) services {
    for (RocoService* service in services) {
        NSString *serviceName = [service serviceName];
        NSString *status = [[[service event] status] statusID];
        NSString *serviceID = [service serviceID];
        STATUS_ID statusID = [[[service event] status] getStatus];
        NSString *message = [[service event] message];
        
        if (status == NULL) {
            return;
        }
        
        NSDictionary* serviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:serviceID, @"serviceID", nil];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        
        notification.userInfo = serviceInfo;
        
        if(statusID == NORMAL) {
            notification.title = [NSString stringWithFormat:@"%@ is back to normal", serviceName];
        } else {
            notification.title = [NSString stringWithFormat:@"%@ on %@", [status capitalizedString], serviceName];
            notification.informativeText = message;
            notification.soundName = NSUserNotificationDefaultSoundName;
        }
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        self.lastNotification = notification;
    }
}
@end
