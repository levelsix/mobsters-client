//
//  ClanRaidProto+EasyAccess.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@interface ClanRaidProto (EasyAccess)

- (ClanRaidStageProto *) stageWithId:(int)stageId;

@end

@interface ClanRaidStageProto (EasyAccess)

- (ClanRaidStageMonsterProto *) monsterWithId:(int)crsmId;
- (int) totalHealth;

@end
