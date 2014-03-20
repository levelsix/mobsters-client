//
//  Building.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "UserData.h"
#import "MapSprite.h"

#define CONSTRUCTION_TAG @"Construction"
#define SHADOW_TAG @"Shadow"
#define BOUNCE_ACTION_TAG 25334
#define UPGRADING_TAG @"Upgrade"

@class GameMap;
@class HomeMap;

@interface Building : SelectableSprite {
  float _percentage;
}

@property (nonatomic, retain) CCSprite *buildingSprite;
@property (nonatomic, assign) StructOrientation orientation;
@property (nonatomic, assign) float verticalOffset;

@property (nonatomic, assign) float baseScale;

- (void) setupBuildingSprite:(NSString *)fileName;
- (void) adjustBuildingSprite;

- (void) displayProgressBar;
- (void) updateUpgradeBar;
- (void) removeProgressBar;
- (void) instaFinishUpgradeWithCompletionBlock:(void(^)(void))completed;

@end

@interface MissionBuilding : Building <TaskElement> {
  CCSprite *_lockedBubble;
}

@property (nonatomic, assign) BOOL isLocked;

@end

@interface ObstacleSprite : Building

@property (nonatomic, retain) UserObstacle *obstacle;

- (id) initWithObstacle:(UserObstacle *)obstacle map:(HomeMap *)map;

@end
