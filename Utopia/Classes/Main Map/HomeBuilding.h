//
//  HomeBuilding.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Building.h"
#import "AnimatedSprite.h"

#import "cocos2d-ui.h"

@interface HomeBuilding : Building {
  CGPoint _startTouchLocation;
  BOOL _isSetDown;
  BOOL _isConstructing;
  HomeMap *_homeMap;
  
  CGPoint _startMoveCoordinate;
  StructOrientation _startOrientation;
}

@property (nonatomic, assign) CGPoint startTouchLocation;
@property (nonatomic, assign) BOOL isSetDown;
@property (nonatomic, assign) BOOL isConstructing;
@property (nonatomic, assign) BOOL isPurchasing;

@property (nonatomic, retain) CCSprite *statusSprite;

@property (nonatomic, retain) UserStruct *userStruct;

+ (id) buildingWithUserStruct:(UserStruct *)us map:(HomeMap *)map;
- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map;
- (void) locationAfterTouch:(CGPoint)touchLocation;
- (void) placeBlock:(BOOL)shouldPlaySound;
- (void) liftBlock;
- (void) updateMeta;
- (void) clearMeta;
- (void) cancelMove;

- (void) displayMoveArrows;
- (void) removeMoveArrows;

- (void) displayUpgradeComplete;

@end

@interface ResourceGeneratorBuilding : HomeBuilding {
  CCButton *_retrieveBubble;
}

@property (nonatomic, assign) BOOL retrievable;

@end

@interface ResourceStorageBuilding : HomeBuilding

@property (nonatomic, retain) CCAnimation *anim;

- (void) setPercentage:(float)percentage;

@end

@interface TownHallBuilding : HomeBuilding

@end

@interface HospitalBuilding : HomeBuilding {
  UserMonsterHealingItem *_healingItem;
}

@property (nonatomic, retain) CCSprite *tubeSprite;
@property (nonatomic, retain) CCSprite *monsterSprite;

@property (nonatomic, retain) CCAnimation *baseAnimation;
@property (nonatomic, retain) CCAnimation *tubeAnimation;

- (void) beginAnimatingWithHealingItem:(UserMonsterHealingItem *)hi;
- (void) stopAnimating;

@end

@interface ResidenceBuilding : HomeBuilding

@end

@interface LabBuilding : HomeBuilding {
  UserEnhancement *_enhancement;
}

@property (nonatomic, retain) CCAnimation *anim;

- (void) beginAnimatingWithEnhancement:(UserEnhancement *)ue;
- (void) stopAnimating;

@end

@interface EvoBuilding : HomeBuilding {
  UserEvolution *_evolution;
}

- (void) beginAnimatingWithEvolution:(UserEvolution *)ue;
- (void) stopAnimating;

@end

@interface MiniJobCenterBuilding : HomeBuilding

@property (nonatomic, retain) UserMiniJob *activeMiniJob;

- (void) updateForActiveMiniJob:(UserMiniJob *)activeMiniJob;

@end

@interface TeamCenterBuilding : HomeBuilding

@end
