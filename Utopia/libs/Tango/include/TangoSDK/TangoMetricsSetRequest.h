//
//  TangoMetricsSetRequest.h
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


/** Structure to use when reporting Metrics to Tango via [TangoMetrics send:withHandler:].
    See TangoMetrics for more information about how this is used.
    */
@interface TangoMetricsSetRequest : NSObject <TangoJSONSerialization>

/**
 * Report another metric with all functions (RollUps).
 *
 * @param  name   The name of the metric that will be added.
 * @param  value  The value of the metric that will be added.
 */
- (void)setMetric:(NSString *)name withValue:(NSInteger)value;

/**
 * Report another metric with just one function (RollUp).
 *
 * @param  name           The name of the metric that will be added.
 * @param  value          The value of the metric that will be added.
 * @param  functionOrNil  The functions to be recorded. If nil, the metric will not be included in the request.
 */
- (void)setMetric:(NSString *)name withValue:(NSInteger)value withFunction:(NSString *)functionOrNil;

/**
 * Report another metric with multiple functions (RollUps).
 *
 * @param  name            The name of the metric that will be added.
 * @param  value           The value of the metric that will be added.
 * @param  functionsOrNil  The functions to be computed. If nil, the metric will not be included in the request.
 */
- (void)setMetric:(NSString *)name withValue:(NSInteger)value withFunctions:(NSArray *)functionsOrNil;

/**
 * Remove a metric from the request if it was already added.
 *
 * @param name  The name of the metric to remove.
 */
- (void)removeMetric:(NSString *)name;

@end
