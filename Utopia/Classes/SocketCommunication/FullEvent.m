//
//  FullEvent.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FullEvent.h"

@implementation FullEvent

@synthesize event;
@synthesize tag;

+ (id) createWithEvent:(PBGeneratedMessage *)e tag:(int)t eventUuid:(NSString *)eventUuid {
  return [[self alloc] initWithEvent:e tag:t eventUuid:eventUuid];
}

- (id) initWithEvent:(PBGeneratedMessage *)e tag:(int)t eventUuid:(NSString *)eventUuid {
  if ((self = [super init])) {
    self.event = e;
    self.tag = t;
    self.eventUuid = eventUuid;
  }
  return self;
}

+ (id) createWithEvent:(PBGeneratedMessage *)e tag:(int)t requestType:(EventProtocolRequest)requestType eventUuid:(NSString *)eventUuid {
  return [[self alloc] initWithEvent:e tag:t requestType:requestType eventUuid:eventUuid];
}

- (id) initWithEvent:(PBGeneratedMessage *)e tag:(int)t requestType:(EventProtocolRequest)requestType eventUuid:(NSString *)eventUuid {
  if ((self = [super init])) {
    self.event = e;
    self.tag = t;
    self.requestType = requestType;
    self.eventUuid = eventUuid;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%d: %@", tag, NSStringFromClass([self.event class])];
}

@end
