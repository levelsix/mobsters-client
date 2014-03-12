//
//  FullEvent.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface FullEvent : NSObject

@property (nonatomic, retain) PBGeneratedMessage *event;
@property (nonatomic, assign) int tag;

@property (nonatomic, assign) EventProtocolRequest requestType;

+ (id) createWithEvent:(PBGeneratedMessage *)e tag:(int)t;
+ (id) createWithEvent:(PBGeneratedMessage *)e tag:(int)t requestType:(EventProtocolRequest)requestType;

@end
