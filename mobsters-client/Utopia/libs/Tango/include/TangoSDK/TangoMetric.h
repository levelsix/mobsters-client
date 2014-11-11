//
//  TangoMetric.h
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

/** The TangoMetric class is used when you want to fetch or send Metrics. In addition to
    the metric name (aka MetricId) and value, it encapsulates RollUps (called functions here).
    */
@interface TangoMetric : NSObject

/// The name of the metric (aka MetricId). You choose this according to your needs.
@property (nonatomic, strong) NSString *name;

/// The value of the metric as a native integer.
@property (nonatomic, assign) NSInteger value;

// The date that the metric was last updated at.
@property (nonatomic, strong) NSDate *lastModified;

/// An array of strings naming the RollUps you want Tango to calculate for the metric.
/// Currently supported values are: "MAX_LAST_HOUR", "MAX_THIS_HOUR",
/// "MAX_LAST_DAY", "MAX_THIS_DAY", "MAX_LAST_WEEK", "MAX_THIS_WEEK",
/// "MAX", "AVE", "SUM", "COUNT", "MIN"
@property (nonatomic, strong) NSArray *functions;

/// Use this property instead of "functions" when only a single RollUp is appropriate.
@property (nonatomic, strong) NSString *function;

/**
 * Initialize a new metric.
 *
 * @param  name          The metric's name, known as the MetricId internally.
 * @param  value         The metric's value.
 * @param  lastModified  The date that the metric was last updated at.
 * @param  function      The metric's function type (RollUp).
 */
+ (TangoMetric *)metricWithName:(NSString *)name value:(NSInteger)value
                   lastModified:(NSDate *)lastModified function:(NSString *)function;

/**
 * Initialize a new metric.
 *
 * @param  name          The metric's name, known as the MetricId internally.
 * @param  value         The metric's value.
 * @param  lastModified  The date that the metric was last updated at.
 * @param  function      The metric's function type (RollUp).
 */
- (TangoMetric *)initWithName:(NSString *)name value:(NSInteger)value
                 lastModified:(NSDate *)lastModified function:(NSString *)function;

@end
