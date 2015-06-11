//
//  LeaderBoardObject.h
//  Utopia
//
//  Created by Kenneth Cox on 5/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@protocol LeaderBoardObject <NSObject>

- (MinimumUserProto *) mup;
- (long) score;
- (NSString *) name;
- (int) rank;

@end

@interface StrengthLeaderBoardProto (leaderBoardObject) <LeaderBoardObject>

@end
