//
//  TutorialMissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MissionMap.h"
#import "MyTeamSprite.h"

@protocol TutorialMissionMapDelegate <NSObject>

- (void) initialChaseComplete;
- (void) enemyJumped;
- (void) enemyRanIntoFirstBuilding;
- (void) friendEnteredFirstBuilding;
- (void) enemyRanOffMap;
- (void) enemyArrivedWithBoss;
- (void) friendWalkedUpToBoss;
- (void) enemyTurnedToBossAndBack;
- (void) everyoneEnteredSecondBuilding;
- (void) enemyBossRanOffMap;
- (void) yachtWentOffScene;
- (void) enteredMiniTutBuilding;

@end

@interface TutorialMissionMap : MissionMap

@property (nonatomic, retain) AnimatedSprite *friendSprite;
@property (nonatomic, retain) AnimatedSprite *enemySprite;
@property (nonatomic, retain) AnimatedSprite *enemyBossSprite;
@property (nonatomic, retain) AnimatedSprite *markZSprite;

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) CCSprite *boatSprite;

@property (nonatomic, assign) int clickableAssetId;

@property (nonatomic, assign) id<TutorialMissionMapDelegate> delegate;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants;
- (void) beginInitialChase;
- (void) enemyJump;
- (void) enemyRunIntoFirstBuilding;
- (void) displayArrowOverFirstBuilding;

- (void) beginSecondConfrontation;
- (void) runOutEnemy;
- (void) enemyComeInWithBoss;
- (void) friendWalkUpToBoss;
- (void) enemyTurnToBoss;
- (void) beginChaseIntoSecondBuilding;

- (void) beginThirdConfrontation;
- (void) runOutEnemyBoss;
- (void) markLooksAtYou;
- (void) moveToYacht;

- (void) moveToThirdBuilding;
- (void) displayArrowOverThirdBuilding;

- (void) moveToFourthBuildingAndDisplayArrow;
- (void) moveToFifthBuildingAndDisplayArrow;

@end
