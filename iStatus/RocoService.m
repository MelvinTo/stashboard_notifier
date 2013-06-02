//
//  RocoService.m
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import "RocoService.h"

@implementation RocoService

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    RocoService* target = (RocoService*) object;

    return [[self serviceName] isEqual:[target serviceName]]
        && [[self serviceID] isEqual: [target serviceID]]
        && [[self event] isEqual: [target event]];

}

- (NSString*)getServiceURL:(NSString*) baseURLString {
    return [NSString stringWithFormat:@"%@services/%@", baseURLString, [self serviceID]];
}

@end
