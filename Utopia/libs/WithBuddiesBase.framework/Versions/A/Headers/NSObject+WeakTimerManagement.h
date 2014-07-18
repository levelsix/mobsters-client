//
//  NSObject+WeakTimerManagement.h
//  WithBuddiesBase
//
//  Created by Clint Stevenson on 7/2/14.
//  Copyright (c) 2014 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBWeakTimer.h>

@interface NSObject (WeakTimerManagement)

/**
 * @abstract
 * Executes a block at the time given, and cleans up if this object goes away.
 *
 * @discussion
 * We create a weak timer for each invocation.  We hold onto those timers and clean up after
 * they fire or if this object gets deallocated.  
 * We DON'T invalidate the timer from the run loop it was scheduled on if this object is deallocated before it fires,
 * but WBWeakTimer will simply invalidate the timer upon firing and refuse to execute the block.
 *
 * @param block A block which will get executed at fireDate.  block MUST NOT hold onto this object strongly, or a retain cycle will be created.
 *
 * @warning If block holds onto this object strongly, a retain cycle will be created.
 */
- (void)scheduleBlock:(void (^)(WBWeakTimer* timer))block atDate:(NSDate*)fireDate;

@end
