//
//  TutorialBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "MiniTutorialBattleLayer.h"

@protocol TutorialBattleLayerDelegate <MiniTutorialBattleLayerDelegate>

@optional
- (void) swappedToMark;

@end

@interface TutorialBattleLayer : MiniTutorialBattleLayer

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, assign) id<TutorialBattleLayerDelegate> delegate;

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants;

@end

@interface TutorialBattleOneLayer : TutorialBattleLayer

@end

@interface TutorialBattleTwoLayer : TutorialBattleLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage;

- (void) swapToMark;

@end
