//
//  TangoMetrics.h
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
#import "TangoMetricsGetRequest.h"
#import "TangoMetricsSetRequest.h"

/**
 * The handler used once the metrics have been fetched or saved. The handler will run
 * on the global queue.
 *
 * @param  results  For a fetch request, results is an array of NSDictionary objects with two
 *                  keys. "id" contains a Tango Account ID. "metrics" contains an array of
 *                  TangoMetric objects that represent the information you requested. For a
 *                  send request, "results" is an array of TangoMetric objects that provide the
 *                  latest server state of the metrics requested for the current user.
 *
 * @param  error    The error object, with an error code of 0 on success.
 */
typedef void (^MetricsHandler)(NSArray *results, NSError *error);


/** TangoMetrics is the interface for the Metrics API in the Objective-C binding. Use this class
    if you need to send or retrieve statistical information about your users. This also forms the
    basis for the TangoLeaderboards API.
 
    See the TangoMetric, TangoMetricGetRequest, and TangoMetricSetRequest classes for more
    information.
    */
@interface TangoMetrics : NSObject

/**
 * Send new metrics for the current account.
 *
 * @param  request   Specifies the new metrics that should be saved.
 * @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)send:(TangoMetricsSetRequest *)request withHandler:(MetricsHandler)handler;

/**
 * Fetch the metrics for the specified accounts.
 *
 * @param  request   Specifies the metrics and accounts that should be fetched for the request.
 * @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)fetch:(TangoMetricsGetRequest *)request withHandler:(MetricsHandler)handler;

@end
