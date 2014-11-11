//
//  TutorialHealViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HealViewController.h"

@protocol TutorialHealDelegate <NSObject>

@optional
- (void) healOpened;
- (void) queuedUpMonster:(int)cashSpent;
- (void) spedUpQueue:(int)gemsSpent;
- (void) healClosed;

@end

@interface TutorialHealViewController : HealViewController {
  float _hospitalHealSpeed;
  
  BOOL _allowClose;
  BOOL _allowCardClick;
  
  BOOL _arrowOverPlusCreated;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) NSMutableArray *healingQueue;
@property (nonatomic, retain) NSMutableArray *myMonsters;

@property (nonatomic, assign) uint64_t clickableUserMonsterId;

@property (nonatomic, assign) id<TutorialHealDelegate> delegate;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants damageDealt:(int)damageDealt hospitalHealSpeed:(float)hospSpeed;

- (void) allowCardClick;
- (void) allowSpeedup;
- (void) allowClose;

@end
