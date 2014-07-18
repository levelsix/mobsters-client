//
//  WeakTimer.h
//  Skeeball
//
//  Created by Tim Gostony on 2/13/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBWeakTimer : NSObject

/// selector must be for a void return type; otherwise this will leak
+(instancetype)weakTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats;

/**
 * @abstract
 * Create a weak timer which can execute a block at the specified date.
 *
 * @warning Don't let block hold onto anything strongly unless you like retain cycles.
 */
+(instancetype)weakTimerAtDate:(NSDate*)fireDate block:(void (^)(WBWeakTimer* weakTimer))block;

-(void)invalidate;
-(void)pause;
-(void)resume;

-(NSDate *)fireDate;
-(NSDictionary *)userInfo;

@end
