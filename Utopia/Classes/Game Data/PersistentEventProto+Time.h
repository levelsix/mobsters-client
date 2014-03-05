//
//  PersistentEventProto+Time.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Protocols.pb.h"
#import "ClanRaidProto+EasyAccess.h"

@interface PersistentEventProto (Time)

- (NSDate *) startTime;
- (NSDate *) endTime;
- (NSDate *) cooldownEndTime;
- (BOOL) isRunning;

@end

@interface PersistentClanEventProto (Time)

- (NSDate *) startTime;
- (NSDate *) endTime;
- (BOOL) isRunning;

@end

@interface PersistentClanEventClanInfoProto (Time)

- (ClanRaidStageProto *) currentStage;
- (ClanRaidStageMonsterProto *) currentMonster;
- (float) percentOfStageComplete;
- (NSDate *) stageEndTime;
- (int) curHealthOfActiveStageMonster;
- (float) raidContributionForUserInfo:(PersistentClanEventUserInfoProto *)userInfo;

@end