//
//  HomeBuilding.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Building.h"
#import "AnimatedSprite.h"

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
  CCSprite *_retrieveBubble;
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
  int _monsterId;
}

@property (nonatomic, retain) CCSprite *tubeSprite;
@property (nonatomic, retain) CCSprite *monsterSprite;

@property (nonatomic, retain) CCAnimation *baseAnimation;
@property (nonatomic, retain) CCAnimation *tubeAnimation;

- (void) beginAnimatingWithMonsterId:(int)monsterId;
- (void) stopAnimating;

@end

@interface ResidenceBuilding : HomeBuilding

@end

@interface LabBuilding : HomeBuilding

@property (nonatomic, retain) CCAnimation *anim;

@end

@interface EvoBuilding : HomeBuilding

@end

@interface ExpansionBoard : Building

@property (nonatomic, assign) CGPoint expandSpot;

- (id) initWithExpansionBlock:(CGPoint)block location:(CGRect)location map:(GameMap *)map isExpanding:(BOOL)isExpanding;
- (void) beginExpanding;

@end