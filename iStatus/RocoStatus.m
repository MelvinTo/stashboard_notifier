//
//  RocoStatus.m
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoStatus.h"

@implementation RocoStatus

@synthesize statusID = _statusID;

- (STATUS_ID) getStatus {
    if([_statusID isEqualTo:@"normal"]) {
        return NORMAL;
    } else if ([_statusID isEqualTo:@"warning"]) {
        return WARNING;
    } else if ([_statusID isEqualTo:@"error"]) {
        return ERROR;
    } else {
        return UNKNOWN;
    }
}

@end
