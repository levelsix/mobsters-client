//
//  WBClock.h
//  WithBuddiesBase
//
//  Created by Clint Stevenson on 7/8/14.
//  Copyright (c) 2014 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBClockDelegate <NSObject>

-(void)clockTick:(NSDate*)now;

@end



@interface WBClock : NSObject

/**
 * @abstract
 * Register observer for NSDate updates at an interval suitable for a clock with seconds-level precision.
 *
 * @discussion
 * Updates will fire more frequently than 1 second to avoid skipping.
 */
+(void)registerForSecondsPrecision:(id<WBClockDelegate>)observer;

/**
 * @abstract
 * Stop observing the clock.  Only needed if you want to stop receiving clockTick: messages.
 *
 * @discussion
 * The clock automatically clears out observers which have been deallocated.
 */
+(void)unregisterForSecondsPrecision:(id<WBClockDelegate>)observer;

@end
