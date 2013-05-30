//
//  RocoStatus.h
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NORMAL=1,
    WARNING=2,
    ERROR=3,
    UNKNOWN=4
} STATUS_ID;

@interface RocoStatus : NSObject

@property (nonatomic, copy) NSString *statusID;

- (STATUS_ID) getStatus;

@end
