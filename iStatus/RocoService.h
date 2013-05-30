//
//  RocoService.h
//  iStatus
//
//  Created by Tu Melvin on 5/27/13.
//  Copyright (c) 2013 Tu Melvin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocoEvent.h"

@interface RocoService : NSObject

@property (nonatomic, copy) NSString *serviceID;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, retain) RocoEvent *event;

@end
