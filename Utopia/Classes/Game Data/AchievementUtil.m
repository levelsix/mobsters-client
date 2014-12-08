//
//  AchievementUtil.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "AchievementUtil.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

@implementation AchievementUtil

+ (AchievementUtil *) sharedAchievementUtil
{
  static AchievementUtil *sharedSingleton;
  
  @synchronized(self)
  {
    if (!sharedSingleton)
      sharedSingleton = [[AchievementUtil alloc] init];
    
    return sharedSingleton;
  }
}

+ (void) setDelegate:(id)delegate {
  AchievementUtil *qu = [AchievementUtil sharedAchievementUtil];
  qu.delegate = delegate;
}

+ (void) sendAchievements:(NSSet *)achievements {
  if (achievements.count > 0) {
    [[OutgoingEventController sharedOutgoingEventController] achievementProgress:achievements.allObjects];
    
    GameState *gs = [GameState sharedGameState];
    NSMutableArray *completedAchievements = [NSMutableArray array];
    for (UserAchievement *ua in achievements) {
      if (ua.isComplete) {
        AchievementProto *ap = [gs achievementWithId:ua.achievementId];
        [completedAchievements addObject:ap];
      }
    }
    
    if (completedAchievements.count) {
      [[[AchievementUtil sharedAchievementUtil] delegate] achievementsComplete:completedAchievements];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACHIEVEMENTS_CHANGED_NOTIFICATION object:nil];
  }
}

+ (void) incrementAchievement:(int)achievementId amount:(int)increment changedSet:(NSMutableSet *)changedSet {
  GameState *gs = [GameState sharedGameState];
  
  if (increment > 0) {
    AchievementProto *ap = [gs achievementWithId:achievementId];
    UserAchievement *ua = gs.myAchievements[@(ap.achievementId)];
    
    if (!ua) {
      ua = [[UserAchievement alloc] init];
      ua.achievementId = ap.achievementId;
      [gs.myAchievements setObject:ua forKey:@(ua.achievementId)];
    }
    ua.progress = MIN(ua.progress+increment, ap.quantity);
    ua.isComplete = ua.progress >= ap.quantity;
    
    [changedSet addObject:ua];
  }
}

+ (NSSet *) incrementAllAchievementsWithType:(AchievementProto_AchievementType)type resType:(ResourceType)resType element:(Element)element quality:(Quality)quality staticDataId:(int)staticDataId byAmount:(int)increment {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *changedAchievements = [NSMutableSet set];
  
  for (AchievementProto *ap in gs.staticAchievements.allValues) {
    UserAchievement *ua = gs.myAchievements[@(ap.achievementId)];
    if (!ua.isComplete && ap.achievementType == type && ap.resourceType == resType && ap.element == element && ap.quality == quality && ap.staticDataId == staticDataId) {
      [self incrementAchievement:ap.achievementId amount:increment changedSet:changedAchievements];
    }
  }
  
  return changedAchievements;
}

+ (NSSet *) incrementAllAchievementsWithType:(AchievementProto_AchievementType)type byAmount:(int)increment {
  return [self incrementAllAchievementsWithType:type resType:ResourceTypeNoResource element:ElementNoElement quality:QualityNoQuality staticDataId:0 byAmount:increment];
}

+ (NSSet *) incrementAllAchievementsWithType:(AchievementProto_AchievementType)type resType:(ResourceType)resType byAmount:(int)increment {
  return [self incrementAllAchievementsWithType:type resType:resType element:ElementNoElement quality:QualityNoQuality staticDataId:0 byAmount:increment];
}

+ (NSSet *) incrementAllAchievementsWithType:(AchievementProto_AchievementType)type staticDataId:(int)staticDataId byAmount:(int)increment {
  return [self incrementAllAchievementsWithType:type resType:ResourceTypeNoResource element:ElementNoElement quality:QualityNoQuality staticDataId:staticDataId byAmount:increment];
}

#pragma mark - Individual Achievement Types

+ (NSSet *) destroyOrbs:(int[])orbCounts {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *changedAchievements = [NSMutableSet set];
  
  for (AchievementProto *ap in gs.staticAchievements.allValues) {
    UserAchievement *ua = gs.myAchievements[@(ap.achievementId)];
    if (!ua.isComplete && ap.achievementType == AchievementProto_AchievementTypeDestroyOrbs) {
      int increment = 0;
      if (ap.element != ElementNoElement) {
        increment = orbCounts[ap.element];
      } else {
        for (int i = 0; i < OrbColorNone; i++) {
          increment += orbCounts[i];
        }
      }
      
      [self incrementAchievement:ap.achievementId amount:increment changedSet:changedAchievements];
    }
  }
  
  return changedAchievements;
}

+ (NSSet *) createPowerups:(int[])powerupCounts {
  NSMutableSet *changedAchievements = [NSMutableSet set];
  
  int increment = powerupCounts[PowerupTypeVerticalLine]+powerupCounts[PowerupTypeHorizontalLine];
  NSSet *rockets = [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeCreateRocket byAmount:increment];
  [changedAchievements unionSet:rockets];
  
  increment = powerupCounts[PowerupTypeExplosion];
  NSSet *grenades = [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeCreateGrenade byAmount:increment];
  [changedAchievements unionSet:grenades];
  
  increment = powerupCounts[PowerupTypeAllOfOneColor];
  NSSet *rainbows = [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeCreateRainbow byAmount:increment];
  [changedAchievements unionSet:rainbows];
  
  return changedAchievements;
}

+ (NSSet *) comboCount:(int)comboCount {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeMakeCombo byAmount:comboCount];
}

+ (NSSet *) damageTaken:(int)damageTaken {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeTakeDamage byAmount:damageTaken];
}

+ (NSSet *) collectResource:(ResourceType)type amount:(int)amount {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeCollectResource resType:type byAmount:amount];
}

+ (NSSet *) stealResource:(ResourceType)type amount:(int)amount {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeStealResource resType:type byAmount:amount];
}

+ (NSSet *) pvpBattle:(int)numWon {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeWinPvpBattle byAmount:numWon];
}

+ (NSSet *) sellMonsters:(int)numSold {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeSellMonster byAmount:numSold];
}

+ (NSSet *) healMonsters:(int)numHealed {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeHealMonsters byAmount:numHealed];
}

+ (NSSet *) enhancePoints:(int)amtEnhanced {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeEnhancePoints byAmount:amtEnhanced];
}

+ (NSSet *) upgradeBuilding:(int)buildingId {
  NSMutableSet *set = [NSMutableSet set];
  
  // Go through all prereqs
  GameState *gs = [GameState sharedGameState];
  
  id<StaticStructure> ss = [gs structWithId:buildingId];
  
  while (ss) {
    [set unionSet:[self incrementAllAchievementsWithType:AchievementProto_AchievementTypeUpgradeBuilding staticDataId:ss.structInfo.structId byAmount:1]];
    
    if (ss.structInfo.predecessorStructId) {
      ss = [gs structWithId:ss.structInfo.predecessorStructId];
    } else {
      ss = nil;
    }
  }
  return set;
}

+ (NSSet *) obstacleRemoved {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeRemoveObstacle byAmount:1];
}

+ (NSSet *) leagueJoined:(int)leagueId {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeJoinLeague staticDataId:leagueId byAmount:1];
}

+ (NSSet *) clanJoined {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeJoinClan byAmount:1];
}

+ (NSSet *) solicitedClanHelp {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeSolicitHelp byAmount:1];
}

+ (NSSet *) gaveClanHelp:(int)numTimes {
  return [self incrementAllAchievementsWithType:AchievementProto_AchievementTypeGiveHelp byAmount:numTimes];
}

+ (NSSet *) checkAchievementsForBattleCompleteWithOrbCounts:(int[])orbCounts powerupCounts:(int[])powerupCounts comboCount:(int)comboCount damageTaken:(int)damageTaken {
  NSMutableSet *changed = [NSMutableSet set];
  [changed unionSet:[self destroyOrbs:orbCounts]];
  [changed unionSet:[self createPowerups:powerupCounts]];
  [changed unionSet:[self comboCount:comboCount]];
  [changed unionSet:[self damageTaken:damageTaken]];
  return changed;
}

#pragma mark - Big Achievement Events

+ (void) checkAchievementsForDungeonBattleWithOrbCounts:(int[])orbCounts powerupCounts:(int[])powerupCounts comboCount:(int)comboCount damageTaken:(int)damageTaken dungeonInfo:(BeginDungeonResponseProto *)dungeonInfo wonBattle:(BOOL)wonBattle {
  NSMutableSet *changed = [NSMutableSet set];
  NSSet *gen = [self checkAchievementsForBattleCompleteWithOrbCounts:orbCounts powerupCounts:powerupCounts comboCount:comboCount damageTaken:damageTaken];
  [changed unionSet:gen];
  
  [self sendAchievements:changed];
}

+ (void) checkAchievementsForPvpBattleWithOrbCounts:(int[])orbCounts powerupCounts:(int[])powerupCounts comboCount:(int)comboCount damageTaken:(int)damageTaken pvpInfo:(PvpProto *)pvpInfo wonBattle:(BOOL)wonBattle {
  NSMutableSet *changed = [NSMutableSet set];
  
  int cashAmount = wonBattle ? pvpInfo.prospectiveCashWinnings : 0;
  int oilAmount = wonBattle ? pvpInfo.prospectiveOilWinnings : 0;
  NSSet *gen = [self checkAchievementsForBattleCompleteWithOrbCounts:orbCounts powerupCounts:powerupCounts comboCount:comboCount damageTaken:damageTaken];
  [changed unionSet:gen];
  [changed unionSet:[self stealResource:ResourceTypeCash amount:cashAmount]];
  [changed unionSet:[self stealResource:ResourceTypeOil amount:oilAmount]];
  
  [changed unionSet:[self pvpBattle:wonBattle]];
  
  [self sendAchievements:changed];
}

+ (void) checkBuildingUpgrade:(int)buildingId {
  [self sendAchievements:[self upgradeBuilding:buildingId]];
}

+ (void) checkObstacleRemoved {
  [self sendAchievements:[self obstacleRemoved]];
}

+ (void) checkMonstersHealed:(int)monstersHealed {
  [self sendAchievements:[self healMonsters:monstersHealed]];
}

+ (void) checkSellMonsters:(int)numSold {
  [self sendAchievements:[self sellMonsters:numSold]];
}

+ (void) checkLeagueJoined:(int)leagueId {
  [self sendAchievements:[self leagueJoined:leagueId]];
}

+ (void) checkCollectResource:(ResourceType)res amount:(int)amount {
  [self sendAchievements:[self collectResource:res amount:amount]];
}

+ (void) checkClanJoined {
  [self sendAchievements:[self clanJoined]];
}

+ (void) checkSolicitedClanHelp {
  [self sendAchievements:[self solicitedClanHelp]];
}

+ (void) checkGaveClanHelp:(int)clanHelp {
  [self sendAchievements:[self gaveClanHelp:clanHelp]];
}

@end
