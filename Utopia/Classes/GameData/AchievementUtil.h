//
//  AchievementUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@protocol AchievementUtilDelegate <NSObject>

- (void) achievementsComplete:(NSArray *)aps;

@end

@interface AchievementUtil : NSObject

@property (nonatomic, weak) id<AchievementUtilDelegate> delegate;

+ (void) setDelegate:(id)delegate;

+ (void) checkAchievementsForDungeonBattleWithOrbCounts:(int[])orbCounts powerupCounts:(int[])powerupCounts comboCount:(int)comboCount damageTaken:(int)damageTaken dungeonInfo:(BeginDungeonResponseProto *)dungeonInfo wonBattle:(BOOL)wonBattle;
+ (void) checkAchievementsForPvpBattleWithOrbCounts:(int[])orbCounts powerupCounts:(int[])powerupCounts comboCount:(int)comboCount damageTaken:(int)damageTaken pvpInfo:(PvpProto *)pvpInfo wonBattle:(BOOL)wonBattle;

+ (void) checkBuildingUpgrade:(int)buildingId;
+ (void) checkObstacleRemoved;
+ (void) checkMonstersHealed:(int)monstersHealed;
+ (void) checkEnhancedPoints:(int)pointsEnhanced;
+ (void) checkSellMonsters:(int)numSold;
+ (void) checkLeagueJoined:(int)leagueId;
+ (void) checkCollectResource:(ResourceType)res amount:(int)amount;

+ (void) checkClanJoined;
+ (void) checkSolicitedClanHelp;
+ (void) checkGaveClanHelp:(int)clanHelp;
+ (void) checkRequestedToon;

@end
