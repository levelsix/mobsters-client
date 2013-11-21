//
//  EventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MobstersEventProtocol.pb.h"
#import "FullEvent.h"

@interface IncomingEventController : NSObject

+ (IncomingEventController *) sharedIncomingEventController;
- (Class) getClassForType: (MobstersEventProtocolResponse) type;

- (void) handleStartupResponseProto:(FullEvent *)fe;

@end
