//
//  TutorialDropBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialBattleLayer.h"

@interface TutorialDropBattleLayer : MiniTutorialBattleLayer {
  BOOL _allowLootPickup;
}

@property (nonatomic, assign) uint64_t newUserMonsterId;

- (void) finishBattle;

@end
