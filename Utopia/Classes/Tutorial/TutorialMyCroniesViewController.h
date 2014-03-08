//
//  TutorialMyCroniesViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MyCroniesViewController.h"

@protocol TutorialMyCroniesDelegate <NSObject>

- (void) queuedUpMonster;
- (void) spedUpQueue;
- (void) exitedMyCronies;

@end

@interface TutorialMyCroniesViewController : MyCroniesViewController {
  float _hospitalHealSpeed;
  
  BOOL _allowClose;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) NSMutableArray *healingQueue;
@property (nonatomic, retain) NSMutableArray *myMonsters;

@property (nonatomic, assign) id<TutorialMyCroniesDelegate> delegate;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants damageDealt:(int)damageDealt hospitalHealSpeed:(float)hospSpeed;

- (void) allowCardClick;
- (void) allowSpeedup;
- (void) allowClose;

@end
