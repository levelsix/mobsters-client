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
#import <AudioToolbox/AudioServices.h>
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "MenuNavigationController.h"
#import "MyCroniesViewController.h"

@implementation MissionMap

- (id) initWithProto:(LoadCityResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  if (!fcp) return nil;
  if ((self = [super initWithFile:fcp.mapTmxName])) {
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
    CCTiledMapLayer *layer = [self layerNamed:@"Walkable"];
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
    [layer removeFromParent];
    
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
        mb.orientation = ncep.orientation;
        mb.name = ASSET_TAG(ncep.assetId);
        [self addChild:mb z:1];
        
        [self changeTiles:mb.location canWalk:NO];
      } else if (ncep.type == CityElementProto_CityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        if (!s) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        s.name = ASSET_TAG(ncep.assetId);
        [self addChild:s z:1];
        
        // Don't take it off for decs
        //[self changeTiles:s.location canWalk:NO];
      } else if (ncep.type == CityElementProto_CityElemTypePersonNeutralEnemy ||
                 ncep.type == CityElementProto_CityElemTypeBoss) {
        CGRect r = CGRectZero;
        r.origin = [self randomWalkablePosition];
        r.size = CGSizeMake(1, 1);
        NeutralEnemy *ne = [[NeutralEnemy alloc] initWithFile:ncep.imgId location:r map:self];
        if (!ne) {
          LNLog(@"Unable to find %@", ncep.imgId);
          continue;
        }
        ne.name = ASSET_TAG(ncep.assetId);
        ne.isBoss = ncep.type == CityElementProto_CityElemTypeBoss;
        [self addChild:ne z:1];
      }
    }
    
    [self doReorder];
    
    // Load up the full task protos
    for (NSNumber *taskId in fcp.taskIdsList) {
      FullTaskProto *ftp = [gs taskWithId:taskId.intValue];
      id<TaskElement> asset = (id<TaskElement>)[self assetWithId:ftp.assetNumWithinCity];
      if ([asset conformsToProtocol:@protocol(TaskElement)]) {
        asset.ftp = ftp;
      } else {
        LNLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    if ([Globals isLongiPhone]) {
      [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    } else {
      [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenuSmall" owner:self options:nil];
    }
    
    _allowSelection = YES;
    
    CCSprite *s1 = [CCSprite spriteWithImageNamed:fcp.mapImgName];
    [self addChild:s1 z:-1000];
    
    s1.position = ccp(s1.contentSize.width/2-33, s1.contentSize.height/2-50);
    
    CCSprite *road = [CCSprite spriteWithImageNamed:fcp.roadImgName];
    [self addChild:road z:-998];
    road.position = ccpAdd(s1.position, ccp(fcp.roadImgCoords.x, fcp.roadImgCoords.y));
    
    self.scale = 1;
    
    bottomLeftCorner = ccp(s1.position.x-s1.contentSize.width/2, s1.position.y-s1.contentSize.height/2);
    topRightCorner = ccp(s1.position.x+s1.contentSize.width/2, s1.position.y+s1.contentSize.height/2);
  }
  return self;
}

- (void) setupTeamSprites {
  [super setupTeamSprites];
  for (MyTeamSprite *ts in self.myTeamSprites) {
    [ts stopAllActions];
    [ts recursivelyApplyOpacity:1.f];
    [ts walk];
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
  return [self getChildByName:ASSET_TAG(assetId) recursively:NO];
}

- (void) moveToAssetId:(int)a animated:(BOOL)animated {
  SelectableSprite *spr = [self assetWithId:a];
  [self moveToSprite:spr animated:animated withOffset:ccp(0, -50)];
  
  if ([spr isKindOfClass:[SelectableSprite class]]) {
    for (CCNode *n in self.children) {
      if ([n isKindOfClass:[SelectableSprite class]]) {
        SelectableSprite *ss = (SelectableSprite *)n;
        [ss removeArrowAnimated:NO];
      }
    }
    [spr displayArrow];
    
    _assetIdToDisplayArrow = a;
  }
}

#define SPRITE_DELAY 0.6f

- (void) teamSpritesEnterBuilding:(id<TaskElement>)mp {
  CGPoint start = ccp(mp.location.origin.x-3, floorf(CGRectGetMidY(mp.location)));
  CGPoint end = ccp(mp.location.origin.x-0.5, floorf(CGRectGetMidY(mp.location)));
  float delay = 0;
  for (MyTeamSprite *ts in self.myTeamSprites) {
    [ts runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:delay],
      [CCActionCallBlock actionWithBlock:
       ^{
         CGRect r = ts.location;
         r.origin = start;
         ts.location = r;
         [ts walkToTileCoord:end completionTarget:ts selector:@selector(stopWalking) speedMultiplier:1.5f];
       }],
      [CCActionDelay actionWithDuration:0.2f],
      [RecursiveFadeTo actionWithDuration:0.3f opacity:0],
      nil]];
    delay += SPRITE_DELAY;
  }
  
}

- (IBAction) performCurrentTask:(id)sender {
  if (_enteringDungeon) {
    return;
  }
  
  if ([self.selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)self.selected;
    if ([Globals checkEnteringDungeon]) {
      [self teamSpritesEnterBuilding:te];
      [self moveToSprite:(CCSprite *)te animated:YES];
      // Set the gvc as the delegate of this
      GameViewController *vc = [GameViewController baseController];
      [vc enterDungeon:te.ftp.taskId withDelay:SPRITE_DELAY*(self.myTeamSprites.count-1)+0.7f];
      _enteringDungeon = YES;
      _assetIdToDisplayArrow = 0;
    }
  }
}

- (void) visitTeamPage {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = [GameViewController baseController];
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
}

- (void) setAllLocksAndArrowsForBuildings {
  GameState *gs = [GameState sharedGameState];
  NSArray *taskIdsWithArrows = gs.taskIdsToUnlockMoreTasks;
  NSArray *curQuestIds = gs.inProgressIncompleteQuests.allKeys;
  for (CCNode *n in self.children) {
    if ([n conformsToProtocol:@protocol(TaskElement)]) {
      id<TaskElement> asset = (id<TaskElement>)n;
      int taskId = asset.ftp.taskId;
      asset.isLocked = ![gs isTaskUnlocked:taskId];
      
      if (!asset.ftp) {
        asset.visible = NO;
      } else {
        asset.visible = YES;
      }
      
      if (!_assetIdToDisplayArrow && [taskIdsWithArrows containsObject:@(taskId)]) {
        [asset displayArrow];
      } else {
        [asset removeArrowAnimated:NO];
      }
      
      if (asset.ftp.hasPrerequisiteQuestId) {
        asset.visible = [curQuestIds containsObject:@(asset.ftp.prerequisiteQuestId)];
      }
    }
  }
  
  if (_assetIdToDisplayArrow) {
    SelectableSprite *spr = [self assetWithId:_assetIdToDisplayArrow];
    [spr displayArrow];
  }
}

- (void) onEnter {
  [super onEnter];
  _enteringDungeon = NO;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAllLocksAndArrowsForBuildings) name:QUESTS_CHANGED_NOTIFICATION object:nil];
  [self setAllLocksAndArrowsForBuildings];
}

- (void) setSelected:(SelectableSprite *)selected {
  if (!_allowSelection && selected) {
    return;
  }
  
  [super setSelected:selected];
  
  if (self.selected) {
    if ([self.selected conformsToProtocol:@protocol(TaskElement)]) {
      self.bottomOptionView = self.missionBotView;
    }
  } else {
    self.bottomOptionView = nil;
  }
}

#pragma mark - MapBotViewDelegate methods

- (void) updateMapBotView:(MapBotView *)botView {
  if ([self.selected conformsToProtocol:@protocol(TaskElement)]) {
    id<TaskElement> te = (id<TaskElement>)self.selected;
    FullTaskProto *ftp = te.ftp;
    self.missionNameLabel.text = ftp.name;
    self.missionDescriptionLabel.text = ftp.description;
  }
}

@end
