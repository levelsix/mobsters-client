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

#define CONSTRUCTION_TAG 49
#define SHADOW_TAG 50
#define BOUNCE_ACTION_TAG 3022
#define UPGRADING_TAG 123

@class GameMap;
@class HomeMap;

@interface Building : SelectableSprite {
  float _percentage;
}

@property (nonatomic, assign) CCSprite *buildingSprite;
@property (nonatomic, assign) StructOrientation orientation;
@property (nonatomic, assign) float verticalOffset;

@property (nonatomic, assign) float baseScale;

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
