//
//  MiniTutorialBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "DungeonBattleLayer.h"
#import "TutorialOrbLayer.h"

@protocol MiniTutorialBattleLayerDelegate <BattleLayerDelegate>

@optional
- (void) battleLayerReachedEnemy;
- (void) moveMade;
- (void) moveFinished;
- (void) turnFinished;

@end

@interface MiniTutorialBattleLayer : DungeonBattleLayer {
  BOOL _allowTurnBegin;
}

@property (nonatomic, assign) id<MiniTutorialBattleLayerDelegate> delegate;

@property (nonatomic, assign) int swappableTeamSlot;

- (void) beginFirstMove;
- (void) beginSecondMove;
- (void) beginThirdMove;
- (void) allowMove;

- (NSString *) presetLayoutFile;

@end
