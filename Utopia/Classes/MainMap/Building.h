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
#import "HomeBuildingMenus.h"

#define CONSTRUCTION_TAG @"Construction"
#define SHADOW_TAG @"Shadow"
#define BOUNCE_ACTION_TAG 25334

@class GameMap;
@class HomeMap;

@interface Building : SelectableSprite {
  float _percentage;
  BuildingBubble *_bubble;
}

@property (nonatomic, retain) CCSprite *buildingSprite;
@property (nonatomic, assign) StructOrientation orientation;
@property (nonatomic, assign) float verticalOffset;
@property (nonatomic, assign) float horizontalOffset;

@property (nonatomic, assign) float baseScale;

@property (nonatomic, retain) UpgradeProgressBar *progressBar;

@property (nonatomic, retain) UpgradeSign *greenSign;
@property (nonatomic, retain) UpgradeSign *redSign;

- (void) setupBuildingSprite:(NSString *)fileName;
- (void) adjustBuildingSprite;

- (NSString *) progressBarPrefix;
- (void) displayProgressBar;
- (void) updateProgressBar;
- (void) removeProgressBar;
- (void) instaFinishUpgradeWithCompletionBlock:(void(^)(void))completed;

- (void) setBubbleType:(BuildingBubbleType)bubbleType;
- (void) setBubbleType:(BuildingBubbleType)bubbleType withNum:(int)num;
- (void) displayBubble;

@end

@interface MissionBuilding : Building <TaskElement> {
  CCSprite *_lockedBubble;
}

@property (nonatomic, assign) BOOL isLocked;

@end

@interface ObstacleSprite : Building

@property (nonatomic, retain) UserObstacle *obstacle;

- (id) initWithObstacle:(UserObstacle *)obstacle map:(HomeMap *)map;
- (void) disappear;

@end

@interface CaveBuilding : Building

@end