//
//  RocoEvent.m
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoEvent.h"

@implementation RocoEvent

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    RocoEvent* target = (RocoEvent*) object;
    
    return [[self message] isEqual:[target message]]
    && [[self eventID] isEqual: [target eventID]]
    && [[self status] isEqual: [target status]];
    
}

@end
