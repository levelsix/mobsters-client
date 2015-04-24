//
//  TutorialHomeMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HomeMap.h"
#import "Protocols.pb.h"

@protocol TutorialHomeMapDelegate <NSObject>

@optional
- (void) boatLanded;
- (void) enemyTwoJumped;
- (void) guideJumped;
- (void) guideReachedHideLocation;
- (void) friendEntered;
- (void) enemyTeamWalkedOut;

- (void) guideRanToMark;
- (void) enterHospitalClicked;

- (void) purchasedBuildingWasSetDown:(int)structId coordinate:(CGPoint)coordinate cashCost:(int)cashCost oilCost:(int)oilCost;
- (void) buildingWasSpedUp:(int)gemsSpent;
- (void) buildingWasCompleted;

- (void) teamCenterClicked;
- (void) enterTeamCenterClicked;
- (void) upgradeClicked;

- (void) enterLabClicked;

@end

@interface TutorialHomeMap : HomeMap {
  CGPoint _lastBoatPosition;
  
  BOOL _enteringHospital;
  BOOL _enteringTeamCenter;
  BOOL _enteringTownHall;
  BOOL _enteringLab;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) NSMutableArray *myStructs;

@property (nonatomic, retain) AnimatedSprite *guideSprite;
@property (nonatomic, retain) AnimatedSprite *friendSprite;
@property (nonatomic, retain) AnimatedSprite *markZSprite;

@property (nonatomic, retain) AnimatedSprite *enemy1Sprite;
@property (nonatomic, retain) AnimatedSprite *enemy2Sprite;
@property (nonatomic, retain) AnimatedSprite *enemyBossSprite;

@property (nonatomic, retain) CCSprite *boatSprite;

@property (nonatomic, weak) id<TutorialHomeMapDelegate> delegate;

@property (nonatomic, retain) NSString *clickableUserStructUuid;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants;

- (HospitalBuilding *) hospital;
- (TeamCenterBuilding *) teamCenterBuilding;

- (void) centerOnGuide;
- (void) enemyTwoJump;
- (void) guideJump;
- (void) guideHideBehindObstacle;
- (void) friendEnterScene;
- (void) friendRunForBattleEnter;
- (void) guideRunToMark;

- (void) guideLookScaredWithFlip:(BOOL)flip;

- (void) beginPostBattleConfrontation;
- (void) walkOutEnemyTeam;

- (void) moveFriendsOffBuildableMap;

- (void) landBoatOnShore;
- (void) walkToHospitalAndEnter;
- (void) zoomOutMap;
- (void) speedupPurchasedBuilding;
- (void) moveToOilDrill;
- (void) panToMark;
- (void) friendFaceForward;
- (void) guideFaceForward;

- (void) moveToTeamCenter;
- (UserStruct *) moveToTownHall;
- (void) moveToLab;
- (void) arrowOnLab;

@end
