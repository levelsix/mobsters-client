//
//  Stopwatch.h
//  YachtWithFriendsPaid
//
//  Created by justin stofle on 4/3/11.
//  Copyright 2011 Justin Stofle. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WBStopwatch : NSObject {

}

- (id) initWithName:(NSString*)name;

- (void) start;
- (double) stop;
- (void) elapsed;

@end