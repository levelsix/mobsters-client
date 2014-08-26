//
//  TangoProfileResult.h
//  TangoSDK
//
// -*- ObjC -*-
// Copyright 2012-2013, TangoMe Inc ("Tango").  The SDK provided herein includes 
// software and other technology provided by Tango that is subject to copyright and 
// other intellectual property protections. All rights reserved.  Use only in 
// accordance with the Evaluation License Agreement provided to you by Tango.
// 
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#import <Foundation/Foundation.h>

@class TangoProfileEntry;

/** This interface holds one or more profile entries from calls to fetch My Profile or Get Contacts.
    This class is returned in the block handler defined in the getMyProfile and getMyFriendsProfiles
    API calls.
 
    This class extends the NSEnumerator abstract class to return an enumeration of
    TangoProfileEntry instances. You may also use NSFastEnumeration.
    */
@interface TangoProfileResult : NSObject <NSFastEnumeration>

/** Returns an enumeration of TangoProfileEntry objects.
    Each TangoProfileEntry wraps a profile entry with helper properties to get common fields.
    */
- (NSEnumerator*)profileEnumerator;

/// Retrieve a profile entry at the given index.
- (TangoProfileEntry *)objectAtIndex: (NSUInteger) index;

/// Retrieve the number of profile entries in the result.
@property(readonly) NSUInteger count;

@end

