//
//  LeaderBoardObject.m
//  Utopia
//
//  Created by Kenneth Cox on 5/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "LeaderBoardObject.h"

@implementation StrengthLeaderBoardProto (leaderBoardObject)

- (NSString *) name {
  return self.mup.name;
}

- (long) score {
  return self.strength;
}

@end