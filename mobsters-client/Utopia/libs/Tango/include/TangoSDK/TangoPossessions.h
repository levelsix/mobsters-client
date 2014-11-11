//
//  TangoPossessions.h
//  TangoSDK
//
// -*- ObjC -*-
// Copyright 2012-2013, TangoMe Inc ("Tango").  The SDK provided herein includes
// software and other technology provided by Tango that is subject to copyright and
// other intellectual property protections. All rights reserved.  Use only in
// accordance with the Evaluation License Agreement provided to you by Tango.
//
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx

#import <Foundation/Foundation.h>

@class TangoPossessionResult; // See TangoPossessionResult.h

/**
 * The handler used once possessions have been saved. The handler will
 * run on the global queue.
 *
 * @param  result  The result of attempting to save the possessions.
 */
typedef void (^PossessionsSaveHandler)(TangoPossessionResult *result);

/**
 * The handler used once the possessions have been fetched. The handler will run
 * on the global queue.
 *
 * @param  possessions  An array of the TangoPossession results.
 * @param  error        The error object, with an error code of 0 on success.
 */
typedef void (^PossessionsFetchHandler)(NSArray *possessions, NSError *error);


/** This is the interface for the Possessions API in the Objective-C binding. Use it to store
    key-value data related to a Tango user, like a player inventory in a game, in-app
    currency, or features that they might have unlocked. This API provides a key-value
    store tied to the user's Tango account, and provides for conflict resolution using
    per-entry version numbers.
    */
@interface TangoPossessions : NSObject

/**
 * Send updated possessions for the current account.
 *
 * @param  possessions   Specifies the TangoPossessions that should be saved.
 * @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)save:(NSArray *)possessions withHandler:(PossessionsSaveHandler)handler;

/**
 * Send updated possessions for the current account with an option to ignore versions.
 * This will attempt to save the possessions up to two times: once without forcing, and
 * a second time with the latest version numbers from the server. If both these attempts
 * fail, the handler will be executed with an error.
 *
 * @param  possessions  Specifies the TangoPossessions that should be saved.
 * @param  ignore   Pass YES to attempt to ignore versions, or NO to do a regular save.
 * @param  handler  The handler that gets executed once the asynchronous request is completed.
 */
+ (void)save:(NSArray *)possessions ignoringVersions:(BOOL)ignore withHandler:(PossessionsSaveHandler)handler;

/**
 * Get all of the possessions for the current account.
 *
 * @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)fetchWithHandler:(PossessionsFetchHandler)handler;

@end
