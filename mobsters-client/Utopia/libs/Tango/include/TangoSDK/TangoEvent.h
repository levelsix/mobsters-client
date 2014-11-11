//
//  TangoEvent.h
//  
//
//  Created by Li Geng on 8/27/13.
//
//

#ifndef ____TangoEvent__
#define ____TangoEvent__

#import <Foundation/Foundation.h>
#import <tango_sdk/event_codes.h>

/** TangoEvent represents an SDK-generated asynchronous event, which is propagated through
    Apple's NSNotificationCenter using the key TangoSessionEventPostedTangoSessionNotification.
    */
@interface TangoEvent : NSObject

/// The SDK event code for the event. See event_codes.h.
@property(nonatomic, readonly) EventCode eventCode;

/// The JSON payload associated with the event.
@property(nonatomic, readonly) id jsonContent;

@end
#endif /* defined(____TangoEvent__) */
