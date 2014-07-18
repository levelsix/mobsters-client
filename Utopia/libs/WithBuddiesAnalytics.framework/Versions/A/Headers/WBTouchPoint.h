//
//  WBTouchPoint.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 3/19/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <WithBuddiesBase/WithBuddiesBase.h>

@interface WBTouchPoint : WBPersistedObject

@property (nonatomic, strong, readonly) NSString *area;
@property (nonatomic, strong, readonly) NSNumber *x;
@property (nonatomic, strong, readonly) NSNumber *y;
@property (nonatomic, strong, readonly) NSNumber *z;

-(id)initWithArea:(NSString *)area;
-(id)initWithArea:(NSString *)area point:(CGPoint)point;
-(id)initWithArea:(NSString *)area x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z;

@end
