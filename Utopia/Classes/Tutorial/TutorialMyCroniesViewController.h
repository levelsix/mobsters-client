//
//  TutorialMyCroniesViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MyCroniesViewController.h"

@protocol TutorialMyCroniesDelegate <NSObject>

@optional
- (void) queuedUpMonster:(int)cashSpent;
- (void) spedUpQueue:(int)gemsSpent;
- (void) exitedMyCronies;
- (void) addedMobsterToTeam;

@end

@interface TutorialMyCroniesViewController : MyCroniesViewController {
  float _hospitalHealSpeed;
  
  BOOL _allowClose;
  BOOL _allowCardClick;
  
  BOOL _arrowOverPlusCreated;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) NSMutableArray *healingQueue;
@property (nonatomic, retain) NSMutableArray *myMonsters;

@property (nonatomic, assign) uint64_t clickableUserMonsterId;

@property (nonatomic, assign) id<TutorialMyCroniesDelegate> delegate;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants damageDealt:(int)damageDealt hospitalHealSpeed:(float)hospSpeed;

- (void) allowCardClick;
- (void) allowSpeedup;
- (void) allowClose;

- (void) moveToMonster:(uint64_t)userMonsterId;
- (void) unequipSlotThree;
- (void) highlightTeamView;
- (void) allowEquip:(uint64_t)userMonsterId;

@end
