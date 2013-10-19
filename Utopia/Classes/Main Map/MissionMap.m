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
#import "AnimatedSprite.h"
#import "CCLabelFX.h"
#import <AudioToolbox/AudioServices.h>
#import "Drops.h"
#import "GameViewController.h"

#define LAST_BOSS_RESET_STAMINA_TIME_KEY @"Last boss reset stamina time key"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.3f

#define TASK_BAR_DURATION 2.f
#define EXP_LABEL_DURATION 3.f

#define DROP_SPACE 40.f

#define SHAKE_SCREEN_ACTION_TAG 50

#define DRAGON_TAG 5456

@implementation MissionMap

- (id) initWithProto:(LoadCityResponseProto *)proto {
  //  NSString *tmxFile = @"villa_montalvo.tmx";
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  if ((self = [super initWithTMXFile:fcp.mapImgName])) {
    self.cityId = proto.cityId;
    
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
    [self removeChild:layer cleanup:YES];
    
    // Add all the buildings, can't add people till after aviary placed
    for (CityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == CityElementProto_CityElemTypeBuilding) {
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
        
        [self changeTiles:mb.location canWalk:NO];
      } else if (ncep.type == CityElementProto_CityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!s) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        [self addChild:s z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        
        [self changeTiles:s.location canWalk:NO];
      } else if (ncep.type == CityElementProto_CityElemTypePersonNeutralEnemy) {
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
      }
    }
    
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
    
    //    // Load up the minimum user task protos
    //    for (MinimumUserTaskProto *mutp in proto.userTasksInfoList) {
    //      FullTaskProto *ftp = [gs taskWithId:mutp.taskId];
    //      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
    //      if (asset) {
    //        asset.numTimesActedForTask = mutp.numTimesActed;
    //      } else {
    //        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
    //      }
    //    }
    
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
          te.numTimesActedForQuest = 1;
        } else {
          for (MinimumUserQuestTaskProto *taskData in questData.requiredTasksProgressList) {
            if (taskData.taskId == taskId) {
              te.numTimesActedForQuest = taskData.numTimesActed;
              if (te.numTimesActedForQuest < 1) {
                [te displayArrow];
              }
            }
          }
        }
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    
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

- (IBAction) performCurrentTask:(id)sender {
  if ([self.selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)self.selected;
    
    // Set the gvc as the delegate of this
    UIViewController *vc = [GameViewController baseController];
    [[OutgoingEventController sharedOutgoingEventController] beginDungeon:te.ftp.taskId withDelegate:vc];
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (!_allowSelection && selected) {
    return;
  }
  
  [super setSelected:selected];
  
  if (self.selected) {
    if ([self.selected conformsToProtocol:@protocol(TaskElement)]) {
      id<TaskElement> te = (id<TaskElement>)self.selected;
      
      self.missionNameLabel.text = te.name;
      self.bottomOptionView = self.missionBotView;
    }
  } else {
    self.bottomOptionView = nil;
  }
}

@end
