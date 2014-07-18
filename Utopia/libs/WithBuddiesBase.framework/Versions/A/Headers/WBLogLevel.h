//
//  WBLogLevel.h
//  WithBuddiesBase
//
//  Created by odyth on 10/5/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#ifndef WithBuddiesBase_WBLogLevel_h
#define WithBuddiesBase_WBLogLevel_h

typedef NS_OPTIONS(NSUInteger, WBLogLevel)
{
    WBLogLevelNone      = 0,
    WBLogLevelTrace     = 1 << 0,
    WBLogLevelDebug     = 1 << 1,
    WBLogLevelInfo      = 1 << 2,
    WBLogLevelWarn      = 1 << 3,
    WBLogLevelError     = 1 << 4,
    WBLogLevelFatal     = 1 << 5,
    WBLogLevelAll       = 0xFFFFFFFF
};

#endif
