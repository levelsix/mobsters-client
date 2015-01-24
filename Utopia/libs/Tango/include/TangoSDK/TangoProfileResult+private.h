//
//  TangoProfileResult+private.h
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

/// @cond INTERNAL

#import "TangoProfileResult.h"

/**
  Initialize the class with the json result from the SDK API call response
*/
@interface TangoProfileResult() 

+ (id)profileResultWithJson:(NSString *)jsonResult;

@property(nonatomic, retain) NSArray* profileArray;
@property(nonatomic, strong) NSArray* profilesWithRecentConversations;

@end

// Private interface that extends NSEnumerator

@interface TangoProfileEntryEnumerator : NSEnumerator

- (id)initWithArray:(NSArray*)array;

@property (nonatomic, retain) NSArray* entries;
@property (nonatomic, retain) NSEnumerator* entriesEnumerator;

@end

/// @endcond

