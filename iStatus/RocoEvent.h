//
//  RocoEvent.h
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocoStatus.h"

@interface RocoEvent : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *eventID;
@property (nonatomic, retain) RocoStatus *status;

@end
