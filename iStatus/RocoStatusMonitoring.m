//
//  RocoStatusMonitoring.m
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoStatusMonitoring.h"
#import "StatusNotificationProxy.h"
#import "StatusConfiguration.h"


//NSString *baseURLString = @"http://localhost:4567/";

//NSString *baseURLString = @"http://ipds-status.cisco.com:8080/";

@implementation RocoStatusMonitoring

- (id)init {
//    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    _prevServiceStatuses = nil;
    
    NSURL *baseURL = [NSURL URLWithString:[StatusConfiguration getStashboardURL]];
    
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Setup our object mappings
    RKObjectMapping *serviceMapping = [RKObjectMapping mappingForClass:[RocoService class]];
    [serviceMapping addAttributeMappingsFromDictionary:@{
     @"id" : @"serviceID",
     @"name" : @"serviceName"
     }];
    
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[RocoEvent class]];
    [eventMapping addAttributeMappingsFromDictionary:@{
     @"sid" : @"eventID",
     @"message" : @"message"
     }];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[RocoStatus class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
     @"id" : @"statusID"
     }];
    
    // mapping service-event
    RKRelationshipMapping* service2Event = [RKRelationshipMapping relationshipMappingFromKeyPath:@"current-event"
        toKeyPath:@"event"
        withMapping:eventMapping];
    
    [serviceMapping addPropertyMapping:service2Event];
    
    RKRelationshipMapping* event2Status = [RKRelationshipMapping relationshipMappingFromKeyPath:@"status" toKeyPath:@"status" withMapping:statusMapping];
    
    [eventMapping addPropertyMapping:event2Status];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:serviceMapping
                                                                                       pathPattern:@"admin/api/v1/services"
                                                                                           keyPath:@"services"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return self;
}

- (void) fetchLatestStatus {
    // Load the object model via RestKit
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:@"/admin/api/v1/services"
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray* services = [mappingResult array];
                                
                                // sort it
                                NSArray* sortedServices = [services sortedArrayUsingComparator: ^(id obj1, id obj2) {
                                    
                                    if ([obj1 serviceID] > [obj2 serviceID]) {
                                        return (NSComparisonResult)NSOrderedDescending;
                                    }
                                    
                                    if ([obj1 serviceID] < [obj2 serviceID]) {
                                        return (NSComparisonResult)NSOrderedAscending;
                                    }
                                    return (NSComparisonResult)NSOrderedSame;
                                }];
                                
                                
                                NSArray* newServiceStatuses = [self getNewServiceStatuses:sortedServices];
                                _prevServiceStatuses = sortedServices;
                                
                                [[StatusNotificationProxy getInstance] onNewServiceStatuses:newServiceStatuses];
                                
                                if (_delegate != nil) {
                                    [_delegate updateServices:services];
                                }
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Hit error: %@", error);
                                if (_delegate != nil) {
                                    if ([error.domain isEqualToString:@"NSURLErrorDomain"]
                                        && error.code == -1001) {
                                        NSLog(@"Request timeout, is stashboard not reachable??");
                                        [_delegate onNotReachable];
                                        [[StatusNotificationProxy getInstance] onNotReachable];
                                    }
                                }
                            }];

}

- (void) startMonitoring {
    [_delegate setBaseURL:[StatusConfiguration getStashboardURL]]; // TODO here, fix this strange behavior to pass base url info to systemtray
    
    [self fetchLatestStatus]; // check right away
    // check per configuration.
    
    NSInteger checkInterval = [StatusConfiguration getCheckInterval];
    NSLog(@"check interval is %ld mins", checkInterval);
    _timer = [NSTimer scheduledTimerWithTimeInterval:(60 * [StatusConfiguration getCheckInterval]) target:self selector:@selector(fetchLatestStatus) userInfo:nil repeats:YES];
}

- (void) stopMonitoring {
    [_timer invalidate];
}

- (NSArray*) getNewServiceStatuses: (NSArray*) curServices {
    if(_prevServiceStatuses == nil) {
        // first time, ignore all normal services
        NSMutableArray *array = [NSMutableArray array];
        for (RocoService* service in curServices) {
            if([[[service event] status] getStatus] > NORMAL) {
                [array addObject:service];
            }
        }
        return array;
    }
    
    // assume the array is sorted by service name
    NSMutableArray * newServiceStatusArray = [NSMutableArray array];
    
    for (RocoService* service in curServices) {
        BOOL found = NO;
        
        for (RocoService* service2 in _prevServiceStatuses) {
            if ([service isEqual:service2]) {
                NSLog(@"this service status is old: %@", service);
                found = YES;
            }
        }
        
        if(!found) {
            [newServiceStatusArray addObject:service];
        }
    }
    
    return newServiceStatusArray;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSLog(@"callback from NSNotificationCenter");
    
    NSDictionary* serviceInfo = notification.userInfo;
    
    NSString *serviceID = [serviceInfo objectForKey:@"serviceID"];
    
    for (RocoService* service in _prevServiceStatuses) {
        if ([[service serviceID] isEqual:serviceID]) {
            NSURL *url = [NSURL URLWithString:[service getServiceURL:[StatusConfiguration getStashboardURL]]];
            if( ![[NSWorkspace sharedWorkspace] openURL:url] )
                NSLog(@"Failed to open url: %@",[url description]);
        }
    }
}

@end
