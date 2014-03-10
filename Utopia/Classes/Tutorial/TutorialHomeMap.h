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

- (void) boatLanded;
- (void) enterHospitalClicked;

- (void) purchasedBuildingWasSetDown:(int)structId coordinate:(CGPoint)coordinate cashCost:(int)cashCost oilCost:(int)oilCost;
- (void) buildingWasSpedUp:(int)gemsSpent;
- (void) buildingWasCompleted;

@end

@interface TutorialHomeMap : HomeMap {
  CGPoint _lastBoatPosition;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) NSMutableArray *myStructs;

@property (nonatomic, retain) AnimatedSprite *friendSprite;
@property (nonatomic, retain) AnimatedSprite *markZSprite;

@property (nonatomic, retain) CCSprite *boatSprite;

@property (nonatomic, assign) id<TutorialHomeMapDelegate> delegate;

@property (nonatomic, assign) int clickableUserStructId;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants;

- (HospitalBuilding *) hospital;

- (void) landBoatOnShore;
- (void) walkToHospitalAndEnter;
- (void) friendFaceMark;
- (void) zoomOutMap;
- (void) speedupPurchasedBuilding;
- (void) moveToOilDrill;

@end
