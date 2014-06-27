//
//  PersistentEventProto+Time.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Protocols.pb.h"
#import "ClanRaidProto+EasyAccess.h"
#import "MSDate.h"

@interface PersistentEventProto (Time)

- (MSDate *) startTime;
- (MSDate *) endTime;
- (MSDate *) cooldownEndTime;
- (BOOL) isRunning;

@end

@interface PersistentClanEventProto (Time)

- (MSDate *) startTime;
- (MSDate *) endTime;
- (BOOL) isRunning;

@end

@interface PersistentClanEventClanInfoProto (Time)

- (ClanRaidStageProto *) currentStage;
- (ClanRaidStageMonsterProto *) currentMonster;
- (float) percentOfStageComplete;
- (MSDate *) stageEndTime;
- (int) curHealthOfActiveStageMonster;
- (float) raidContributionForUserInfo:(PersistentClanEventUserInfoProto *)userInfo;

@end