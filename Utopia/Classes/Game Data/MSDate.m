//
//  MSDate.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MSDate.h"
#import "Globals.h"

@implementation MSDate

static NSTimeInterval delta = 0;

+ (void) setServerTime:(uint64_t)time {
  NSDate *date = [NSDate date];
  NSDate *server = [NSDate dateWithTimeIntervalSince1970:time/1000.];
  NSTimeInterval newDelta = [server timeIntervalSinceDate:date];
  if (ABS(newDelta-delta) > 180) {
    delta = newDelta;
    NSLog(@"Setting date delta: %.02f", delta);
  }
}

+ (MSDate *) date {
  MSDate *ms = [[MSDate alloc] init];
  ms.underlyingDate = [NSDate dateWithTimeIntervalSinceNow:delta];
  return ms;
}

+ (MSDate *) dateWithTimeInterval:(NSTimeInterval)timeInterval sinceDate:(MSDate *)date {
  MSDate *ms = [[MSDate alloc] init];
  ms.underlyingDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:date.underlyingDate];
  return ms;
}

+ (MSDate *) dateWithTimeIntervalSince1970:(NSTimeInterval)timeInterval {
  MSDate *ms = [[MSDate alloc] init];
  ms.underlyingDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
  return ms;
}

- (NSComparisonResult) compare:(MSDate *)date {
  return [self.underlyingDate compare:date.underlyingDate];
}

- (BOOL) isEqualToDate:(MSDate *)date {
  return [self.underlyingDate isEqualToDate:date.underlyingDate];
}

- (MSDate *) dateByAddingTimeInterval:(NSTimeInterval)timeInterval {
  MSDate *ms = [[MSDate alloc] init];
  ms.underlyingDate = [self.underlyingDate dateByAddingTimeInterval:timeInterval];
  return ms;
}

- (NSTimeInterval) timeIntervalSinceNow {
  return self.underlyingDate.timeIntervalSinceNow-delta;
}

- (NSTimeInterval) timeIntervalSinceDate:(MSDate *)date {
  return [self.underlyingDate timeIntervalSinceDate:date.underlyingDate];
}

- (NSTimeInterval) timeIntervalSince1970 {
  return [self.underlyingDate timeIntervalSince1970];
}

- (NSDate *) relativeNSDate {
  return self.underlyingDate;
}

- (NSDate *) actualNSDate {
  return [self.underlyingDate dateByAddingTimeInterval:-delta];
}

- (id) copy {
  return [MSDate dateWithTimeIntervalSince1970:self.timeIntervalSince1970];
}

- (NSString *) description {
  return self.underlyingDate.description;
}

@end
