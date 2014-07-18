//
//  WBObjectType.h
//  WithBuddiesBase
//
//  Created by odyth on 9/21/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#ifndef WithBuddiesBase_WBObjectType_h
#define WithBuddiesBase_WBObjectType_h

typedef NS_ENUM(NSInteger, WBObjectType)
{
    WBObjectTypeNotSet,
    WBObjectTypeUnknown,
    WBObjectTypeInt, //i
    WBObjectTypeFloat, //f
    WBObjectTypeDouble, //d
    WBObjectTypeLong, //l
    WBObjectTypeLongLong, //q
    WBObjectTypeShort, //s
    WBObjectTypeBool, //c
    WBObjectTypeUnsignedInt, //I
    WBObjectTypeUnsignedLong, //L
    WBObjectTypeUnsignedLongLong, //Q
    WBObjectTypeUnsignedShort, // S
    WBObjectTypeUnsignedChar, //C
    WBObjectTypeNSString,
    WBObjectTypeNSDate,
    WBObjectTypeNSNumber,
    WBObjectTypeNSNull,
    WBObjectTypeNSNURL,
    WBObjectTypeNSDictionary,
    WBObjectTypeNSMutableDictionary,
    WBObjectTypeNSArray,
    WBObjectTypeNSMutableArray,
    WBObjectTypeWBTimeSpan
};

#endif
