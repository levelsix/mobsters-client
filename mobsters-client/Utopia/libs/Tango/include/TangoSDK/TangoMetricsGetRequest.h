//
//  TangoMetricsGetRequest.h
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
#import "TangoJSONSerialization.h"
#import "TangoProfileResult.h"
#import "TangoProfileEntry.h"


/** Structure to use when fetching Metrics from Tango. See TangoMetrics for more
    information about how this is used.
    */
@interface TangoMetricsGetRequest : NSObject <TangoJSONSerialization>

/**
 * Add multiple TangoEntry in the form of TangoProfileResult.
 *
 * @param  result  An Enumerator containing the TangoProfileEntry objects.
 */
- (void)addProfilesFromResult:(TangoProfileResult *)result;

/**
 * Add another profile to search for the metrics.
 *
 * @param  profile  The entry of the profile.
 */
- (void)addProfile:(TangoProfileEntry *)profile;

/**
 * Remove a profile from the request.
 *
 * @param  profile  The profile that will be removed.
 */
- (void)removeProfile:(TangoProfileEntry *)profile;

/**
* Add multiple accounts to search for the metrics.
 *
 * @param  accountIds  A set of account IDs.
 */
- (void)addAccountIds:(NSSet *)accountIds;

/**
 * Add another account to search for the metrics.
 *
 * @param  accountId  The ID of the account.
 */
- (void)addAccountId:(NSString *)accountId;

/**
 * Remove a profile from the request.
 *
 * @param  accountId  The ID of the account.
 */
- (void)removeAccountId:(NSString *)accountId;

/**
 * Remove multiple account IDs from the request.
 *
 * @param  result  The profile's account ID.
 */
- (void)removeAccountIds:(NSSet *)accountIds;

/**
 * Add another metric to search for.
 *
 * @param  metricName     The name of the metric that will be fetched.
 * @param  functionOrNil  The function to be fetched. If nil, the metric will be removed from the search.
 */
- (void)setMetric:(NSString *)metricName withFunction:(NSString *)functionOrNil;

/**
 * Add another metric to search for.
 *
 * @param  metricName      The name of the metric that will be fetched.
 * @param  functionsOrNil  The functions to be fetched. If nil, the metric will be removed from the search.
 */
- (void)setMetric:(NSString *)metricName withFunctions:(NSArray *)functionsOrNil;

/**
 * Remove a metric from the request.
 *
 * @param name  The name of the metric that will be removed.
 */
- (void)removeMetric:(NSString *)name;

@end
