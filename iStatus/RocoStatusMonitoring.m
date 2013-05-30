//
//  RocoStatusMonitoring.m
//  iStatus
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoStatusMonitoring.h"


//NSString *baseURLString = @"http://localhost:4567/";

NSString *baseURLString = @"http://ipds-status.cisco.com:8080/";

@implementation RocoStatusMonitoring

- (id)init {
//    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
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
                                if (_delegate != nil) {
                                    [_delegate updateServices:services];
                                }
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                NSLog(@"Hit error: %@", error);
                            }];

}

- (void) startMonitoring {
    [_delegate setBaseURL:baseURLString]; // TODO here, fix this strange behavior to pass base url info to systemtray
    
    // check every 1 min
    [self fetchLatestStatus]; // check right away
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(fetchLatestStatus) userInfo:nil repeats:YES];
}

- (void) stopMonitoring {
    [_timer invalidate];
}

@end