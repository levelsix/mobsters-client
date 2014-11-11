//
//  WBAnalyticAdEventType.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 7/14/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#ifndef WithBuddiesAnalytics_WBAnalyticAdEventType_h
#define WithBuddiesAnalytics_WBAnalyticAdEventType_h

typedef NS_ENUM(NSInteger, WBAnalyticAdEventType)
{
    WBAnalyticAdEventTypeRequest,
    WBAnalyticAdEventTypeLoaded,
    WBAnalyticAdEventTypeShow,
    WBAnalyticAdEventTypeClick,
    WBAnalyticAdEventTypeImpression,
    WBAnalyticAdEventTypeFailure,
    WBAnalyticAdEventTypeLeaveApp
};

#endif
