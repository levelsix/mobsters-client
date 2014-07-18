//
//  WBAnalyticEventType.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 3/19/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#ifndef WithBuddiesAnalytics_WBAnalyticEventType_h
#define WithBuddiesAnalytics_WBAnalyticEventType_h

typedef NS_ENUM(NSInteger, WBAnalyticEventType)
{
    WBAnalyticEventTypeGame,
    WBAnalyticEventTypeDeviceProperty,
    WBAnalyticEventTypeUnregisterDeviceProperty,
    WBAnalyticEventTypeClearDeviceProperties,
    WBAnalyticEventTypeABTest,
    WBAnalyticEventTypeBusiness,
    WBAnalyticEventTypeAdvertisement,
    WBAnalyticEventTypeError,
    WBAnalyticEventTypeCustomRange = 0x00FF0000
};

#endif
