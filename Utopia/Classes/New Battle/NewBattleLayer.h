//
//  NewBattleLayer.h
//  PadClone
//
//  Created by Ashwin Kamath on 8/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "OrbLayer.h"
#import "MyPlayer.h"
#import "BattleSprite.h"

@protocol BattleBgdLayerDelegate <NSObject>

- (void) reachedNextScene;

@end

@interface BattleBgdLayer : CCLayer {
  CGPoint _curBasePoint;
}

@property (nonatomic, assign) id<BattleBgdLayerDelegate> delegate;

@end

@interface NewBattleLayer : CCLayer <OrbLayerDelegate, BattleBgdLayerDelegate> {
  int _orbCount;
  int _comboCount;
  int _currentScore;
  int _labelScore;
}

@property (nonatomic, assign) CCSprite *rightDamageBgd;
@property (nonatomic, assign) CCLabelTTF *rightDamageLabel;
@property (nonatomic, assign) CCSprite *leftDamageBgd;
@property (nonatomic, assign) CCLabelTTF *leftDamageLabel;
@property (nonatomic, assign) CCLabelTTF *movesLeftLabel;

@property (nonatomic, assign) CCLabelTTF *leftHealthLabel;
@property (nonatomic, assign) CCLabelTTF *rightHealthLabel;
@property (nonatomic, assign) CCProgressTimer *leftHealthBar;
@property (nonatomic, assign) CCProgressTimer *rightHealthBar;

@property (nonatomic, assign) BattleBgdLayer *bgdLayer;
@property (nonatomic, assign) OrbLayer *orbLayer;

@property (nonatomic, assign) BattleSprite *myPlayer;
@property (nonatomic, assign) BattleSprite *currentEnemy;

+(CCScene *) scene;

@end
