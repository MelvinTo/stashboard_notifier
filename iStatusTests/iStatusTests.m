//
//  iStatusTests.m
//  iStatusTests
//
//  Created by Tu Melvin on 5/23/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "iStatusTests.h"
#import "RocoStatus.h"
#import "RocoEvent.h"
#import "RocoService.h"

@implementation iStatusTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEqual 
{
    RocoStatus* status1 = [[RocoStatus alloc] init];
    status1.statusID = @"normal";
    
    RocoStatus* status2 = [[RocoStatus alloc] init];
    status2.statusID = @"normal";
    
    STAssertEqualObjects(status1, status2, @"these two statuses are the same");
    
    RocoStatus* status3 = [[RocoStatus alloc] init];
    STAssertFalse([status1 isEqual:status3], @"these two statues should be differnet");
    
    RocoEvent* event1 = [[RocoEvent alloc] init];
    event1.message = @"event message";
    event1.eventID = @"eventID";
    event1.status = status1;
    
    RocoEvent* event2 = [[RocoEvent alloc] init];
    event2.message = @"event message";
    event2.eventID = @"eventID";
    event2.status = status1;
    
    STAssertEqualObjects(event1, event2, @"these two events are the same");

    RocoService* service1 = [[RocoService alloc]init];
    service1.serviceID = @"serviceID";
    service1.serviceName = @"serviceName";
    service1.event = event1;
    
    RocoService* service2 = [[RocoService alloc]init];
    service2.serviceID = @"serviceID";
    service2.serviceName = @"serviceName";
    service2.event = event2;

    STAssertEqualObjects(service1.serviceID, service2.serviceID, @"these two service IDs should be the same");
    STAssertEqualObjects(service1.serviceName, service2.serviceName, @"these two service names should be the same");
    STAssertEqualObjects(service1.event, service2.event, @"these two events should be the same");
    
    STAssertEqualObjects(service1, service2, @"these two services are the same");
}

@end
