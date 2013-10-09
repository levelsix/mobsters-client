//
//  MissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMap.h"
#import "GameState.h"
#import "Globals.h"
#import "UserData.h"
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "AnimatedSprite.h"
#import "CCLabelFX.h"
#import "TopBar.h"
#import "QuestLogController.h"
#import "BossEventMenuController.h"
#import <AudioToolbox/AudioServices.h>
#import "Drops.h"
#import "CityRankupViewController.h"

#define LAST_BOSS_RESET_STAMINA_TIME_KEY @"Last boss reset stamina time key"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.3f

#define TASK_BAR_DURATION 2.f
#define EXP_LABEL_DURATION 3.f

#define DROP_SPACE 40.f

#define SHAKE_SCREEN_ACTION_TAG 50

#define DRAGON_TAG 5456

@implementation MissionMap

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto {
  //  NSString *tmxFile = @"villa_montalvo.tmx";
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  if ((self = [super initWithTMXFile:fcp.mapImgName])) {
    _cityId = proto.cityId;
    
    self.walkableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.walkableData addObject:row];
    }
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    // Get the walkable data
    CCTMXLayer *layer = [self layerNamed:@"Walkable"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        NSMutableArray *row = [self.walkableData objectAtIndex:i];
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
      }
    }
    //    [self removeChild:layer cleanup:YES];
    
    // Add all the buildings, can't add people till after aviary placed
    for (NeutralCityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        // Add a mission building
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!mb) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        mb.name = ncep.name;
        mb.orientation = ncep.orientation;
        [self addChild:mb z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        [mb release];
        
        [self changeTiles:mb.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!s) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:s z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        
        [self changeTiles:s.location canWalk:NO];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePersonQuestGiver) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        QuestGiver *qg = [[QuestGiver alloc] initWithQuest:nil questGiverState:kNoQuest file:ncep.imgId map:self location:r];
        if (!qg) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:qg z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        qg.name = ncep.name;
        [qg release];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypePersonNeutralEnemy) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        NeutralEnemy *ne = [[NeutralEnemy alloc] initWithFile:ncep.imgId location:r map:self];
        if (!ne) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:ne z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        ne.name = ncep.name;
        [ne release];
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBoss) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        BossSprite *bs = [[BossSprite alloc] initWithFile:ncep.imgId location:r map:self];
        if (!bs) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        //        [self addChild:bs z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        bs.name = ncep.name;
        [bs release];
      }
    }
    
    [self reloadQuestGivers];
    
    [self addEnemiesFromArray:proto.defeatTypeJobEnemiesList];
    
    [self doReorder];
    
    // Load up the full task protos
    for (NSNumber *taskId in fcp.taskIdsList) {
      FullTaskProto *ftp = [gs taskWithId:taskId.intValue];
      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.ftp = ftp;
      } else {
        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Load up the minimum user task protos
    for (MinimumUserTaskProto *mutp in proto.userTasksInfoList) {
      FullTaskProto *ftp = [gs taskWithId:mutp.taskId];
      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.numTimesActedForTask = mutp.numTimesActed;
      } else {
        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Same for bosses
    for (NSNumber *bossId in fcp.bossIdsList) {
      FullBossProto *fbp = [gs bossWithId:bossId.intValue];
      BossSprite *asset = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
      if (asset) {
        asset.fbp = fbp;
      } else {
        LNLog(@"Could not find asset number %d.", fbp.assetNumWithinCity);
      }
    }
    
    for (FullUserBossProto *ub in proto.userBossesList) {
      FullBossProto *fbp = [gs bossWithId:ub.bossId];
      BossSprite *asset = (BossSprite *)[self assetWithId:fbp.assetNumWithinCity];
      if (asset) {
        asset.ub = [UserBoss userBossWithFullUserBossProto:ub];
        [asset.ub createTimer];
      } else {
        LNLog(@"Could not find asset number %d.", fbp.assetNumWithinCity);
      }
    }
    
    // Just use jobs for defeat type jobs, tasks are tracked on their own
    _jobs = [[NSMutableArray alloc] init];
    
    for (FullUserQuestDataLargeProto *questData in proto.inProgressUserQuestDataInCityList) {
      FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:[NSNumber numberWithInt:questData.questId]];
      fqp = fqp ? fqp : [gs.inProgressCompleteQuests objectForKey:[NSNumber numberWithInt:questData.questId]];
      if (fqp.cityId != proto.cityId) {
        continue;
      }
      
      for (NSNumber *taskNum in fqp.taskReqsList) {
        int taskId = taskNum.intValue;
        FullTaskProto *ftp = [gs taskWithId:taskId];
        id<TaskElement> te = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
        
        te.partOfQuest = YES;
        
        if (questData.isComplete) {
          te.numTimesActedForQuest = ftp.numRequiredForCompletion;
        } else {
          for (MinimumUserQuestTaskProto *taskData in questData.requiredTasksProgressList) {
            if (taskData.taskId == taskId) {
              te.numTimesActedForQuest = taskData.numTimesActed;
              if (te.numTimesActedForQuest < ftp.numRequiredForCompletion) {
                [te displayArrow];
              }
            }
          }
        }
      }
      
      for (MinimumUserDefeatTypeJobProto *dtData in questData.requiredDefeatTypeJobProgressList) {
        DefeatTypeJobProto *job = [gs.staticDefeatTypeJobs objectForKey:[NSNumber numberWithInt:dtData.defeatTypeJobId]];
        
        if (job.cityId == _cityId && dtData.numDefeated  < job.numEnemiesToDefeat) {
          [self displayArrowsOnEnemies:job.typeOfEnemy];
          
          UserJob *userJob = [[UserJob alloc] initWithDefeatTypeJob:job];
          userJob.numCompleted = dtData.numDefeated;
          [_jobs addObject:userJob];
          [userJob release];
        }
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"CityBossView" owner:self options:nil];
    [Globals displayUIView:self.bossView];
    self.bossView.hidden = YES;
    
    _myPlayer.location = CGRectMake(fcp.center.x, fcp.center.y, 1, 1);
    [self moveToSprite:_myPlayer animated:NO];
    
    _allowSelection = YES;
    
    
    CCSprite *s1 = [CCSprite spriteWithFile:@"missionmap.png"];
    [self addChild:s1 z:-1000];
    
    s1.position = ccp(s1.contentSize.width/2-33, s1.contentSize.height/2-50);
    
    CCSprite *road = [CCSprite spriteWithFile:@"missionroad.png"];
    [self addChild:road z:-998];
    road.position = ccpAdd(s1.position, ccp(23,21.5));
    
    self.scale = 1;
    
    bottomLeftCorner = ccp(s1.position.x-s1.contentSize.width/2, s1.position.y-s1.contentSize.height/2);
    topRightCorner = ccp(s1.position.x+s1.contentSize.width/2, s1.position.y+s1.contentSize.height/2);
  }
  return self;
}

- (BossUnlockedView *) bossUnlockedView {
  if (!_bossUnlockedView) {
    [[NSBundle mainBundle] loadNibNamed:@"BossUnlockedView" owner:self options:nil];
  }
  return _bossUnlockedView;
}

- (BossInfoView *) bossInfoView {
  if (!_bossInfoView) {
    [[NSBundle mainBundle] loadNibNamed:@"BossInfoView" owner:self options:nil];
  }
  return _bossInfoView;
}

- (void) addEnemiesFromArray:(NSArray *)arr {
  for (FullUserProto *fup in arr) {
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    Enemy *enemy = [[Enemy alloc] initWithUser:fup location:r map:self];
    [self addChild:enemy z:1];
    [enemy release];
    
    enemy.opacity = 0;
    [enemy runAction:[CCFadeIn actionWithDuration:0.5f]];
  }
  [self doReorder];
}

- (void) killEnemy:(int)userId {
  Enemy *enemy = [self enemyWithUserId:userId];
  
  if (enemy) {
    [enemy kill];
    
    // This will only actually display check if the arrow is there..
    for (UserJob *job in _jobs) {
      if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
        DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
        
        if (dtj.cityId == _cityId && (dtj.typeOfEnemy == enemy.user.userType || dtj.typeOfEnemy == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide)) {
          [enemy displayCheck];
          job.numCompleted++;
        }
      }
    }
    [self updateEnemyQuestArrows];
  }
}

- (void) displayArrowsOnEnemies:(DefeatTypeJobProto_DefeatTypeJobEnemyType)enemyType {
  for (CCNode *child in _children) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userType == enemyType || enemyType == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
        // Make sure this enemy wasn't just defeated
        if (enemy.isAlive) {
          [enemy displayArrow];
        }
      }
    }
  }
}

- (void) updateEnemyQuestArrows {
  for (CCNode *node in _children) {
    if ([node isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)node;
      [enemy removeArrowAnimated:NO];
    }
  }
  
  for (UserJob *job in _jobs) {
    if (job.jobType == kDefeatTypeJob && job.numCompleted < job.total) {
      DefeatTypeJobProto *dtj = [[[GameState sharedGameState] staticDefeatTypeJobs] objectForKey:[NSNumber numberWithInt:job.jobId]];
      
      if (dtj.cityId == _cityId) {
        [self displayArrowsOnEnemies:dtj.typeOfEnemy];
      }
    }
  }
}

-(void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
      [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canWalk]];
    }
  }
}

- (id) assetWithId:(int)assetId {
  return [self getChildByTag:assetId+ASSET_TAG_BASE];
}

- (void) moveToAssetId:(int)a animated:(BOOL)animated {
  [self moveToSprite:[self assetWithId:a] animated:animated];
}

- (void) updateBossSprite {
  if (_selected && [_selected isKindOfClass:[BossSprite class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [Globals setFrameForView:self.bossView forPoint:pt];
    self.bossView.hidden = NO;
  } else {
    self.bossView.hidden = YES;
  }
}

- (IBAction) performCurrentTask:(id)sender {
  if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)_selected;
    [[OutgoingEventController sharedOutgoingEventController] beginDungeon:te.ftp.taskId];
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (!_allowSelection && selected) {
    return;
  }
  
  [super setSelected:selected];
  
  if (_selected) {
    if ([_selected conformsToProtocol:@protocol(TaskElement)]) {
      id<TaskElement> te = (id<TaskElement>)_selected;
      
      self.missionNameLabel.text = te.name;
      [[[TopBar sharedTopBar] topBarView] replaceChatViewWithView:self.missionBotView];
    } else if ([_selected isKindOfClass:[BossSprite class]]) {
    }
  } else {
    [[[TopBar sharedTopBar] topBarView] removeViewOverChatView];
  }
}

- (void) questAccepted:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  if ([qg isKindOfClass:[QuestGiver class]]) {
    qg.quest = fqp;
    qg.questGiverState = kInProgress;
  }
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    id<TaskElement> te = (id<TaskElement>)[self assetWithId:task.assetNumWithinCity];
    te.numTimesActedForQuest = 0;
    te.partOfQuest = YES;
    [te displayArrow];
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    DefeatTypeJobProto *dtj = [gs.staticDefeatTypeJobs objectForKey:num];
    UserJob *job = [[UserJob alloc] initWithDefeatTypeJob:dtj];
    job.numCompleted = 0;
    
    [_jobs addObject:job];
    [job release];
  }
  [self updateEnemyQuestArrows];
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  QuestGiver *qg = [self assetWithId:fqp.assetNumWithinCity];
  if ([qg isKindOfClass:[QuestGiver class]]) {
    qg.quest = nil;
    qg.questGiverState = kNoQuest;
  }
  
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *num in fqp.taskReqsList) {
    FullTaskProto *task = [gs taskWithId:num.intValue];
    id<TaskElement> te = (id<TaskElement>)[self assetWithId:task.assetNumWithinCity];
    [te removeArrowAnimated:NO];
    te.partOfQuest = NO;
  }
  
  for (NSNumber *num in fqp.defeatTypeReqsList) {
    UserJob *toDel = nil;
    for (UserJob *job in _jobs) {
      if (job.jobType == kDefeatTypeJob && job.jobId == num.intValue) {
        toDel = job;
      }
    }
    [_jobs removeObject:toDel];
  }
  
  [self updateEnemyQuestArrows];
}

- (void) reloadQuestGivers {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kAvailable;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kInProgress;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
    if (fqp.cityId == _cityId) {
      CCNode *node = [self assetWithId:fqp.assetNumWithinCity];
      if ([node isKindOfClass:[QuestGiver class]]) {
        QuestGiver *qg = (QuestGiver *)node;
        qg.quest = fqp;
        qg.questGiverState = kCompleted;
        [arr addObject:qg];
      } else {
        LNLog(@"Asset num %d for quest %d is not a quest giver", fqp.assetNumWithinCity, fqp.questId);
      }
    }
  }
  
  for (CCNode *node in _children) {
    if ([node isKindOfClass:[QuestGiver class]]) {
      QuestGiver *qg = (QuestGiver *)node;
      if (![arr containsObject:qg]) {
        qg.quest = nil;
        qg.questGiverState = kNoQuest;
      }
    }
  }
  
  [arr release];
}

- (void) bossInfoClicked {
  [BossEventMenuController displayView];
}

- (void) onExit {
  [super onExit];
  [_bossTimeLabel removeFromParentAndCleanup:YES];
  _bossTimeLabel = nil;
  [_powerAttackBgd removeFromParentAndCleanup:YES];
  _powerAttackBgd = nil;
  _powerAttackBar = nil;
  _powerAttackLabel = nil;
  _infoMenu = nil;
}

- (void) dealloc {
  [_jobs release];
  [self.bossUnlockedView removeFromSuperview];
  self.bossUnlockedView = nil;
  [self.bossView removeFromSuperview];
  self.bossView = nil;
  [super dealloc];
}

@end
