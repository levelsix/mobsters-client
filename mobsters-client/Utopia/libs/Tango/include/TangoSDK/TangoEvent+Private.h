//
//  TangoEvent+Private.h
//  
//
//  Created by Li Geng on 8/27/13.
//
//

/// @cond INTERNAL

#ifndef _TangoEvent_Private_h
#define _TangoEvent_Private_h

#import "TangoEvent.h"

@interface TangoEvent ()

/// @internal
@property (nonatomic, assign) EventCode eventCode;
/// @internal
@property (nonatomic, strong) id jsonContent;

/// @internal
- (TangoEvent *)initWithEventCode:(EventCode)code jsonObject:(id)content;

@end


#endif

/// @endcond

