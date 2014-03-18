//
//  SoundEngine.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
  kNoMusic = 0,
  kMapMusic,
  kBattleMusic
} BackgroundMusic;

@interface SoundEngine : NSObject {
  BackgroundMusic _curMusic;
  BackgroundMusic _lastPlayedMusic;
}

@property (nonatomic, retain) id<ALSoundSource> damageTick;

+ (SoundEngine *)sharedSoundEngine;

- (void) stopBackgroundMusic;
- (void) resumeBackgroundMusic;
- (id<ALSoundSource>) playEffect:(NSString *)effect;

- (void) playMapMusic;
- (void) playBattleMusic;

+ (void) dialogueBoxOpen;
+ (void) spriteJump;
+ (void) tutorialBoatScene;

+ (void) closeButtonClick;
+ (void) generalButtonClick;

+ (void) chatOpened;
+ (void) chatClosed;

+ (void) structSpeedupConstruction;
+ (void) structUpgradeClicked;
+ (void) structDropped;
+ (void) structCantPlace;
+ (void) structSelected;
+ (void) structCompleted;
+ (void) structCollectOil;
+ (void) structCollectCash;

+ (void) puzzleDamageTickStart;
+ (void) puzzleDamageTickStop;
+ (void) puzzleSwapWindow;
+ (void) puzzleSwapCharacterChosen;
+ (void) puzzleMonsterDefeated;
+ (void) puzzleRocketMatch;
+ (void) puzzlePlaneDrop;
+ (void) puzzleDestroyPiece;
+ (void) puzzleComboCreated;
+ (void) puzzleComboFire;
+ (void) puzzleSwapPiece;
+ (void) puzzleOrbsSlideIn;
+ (void) puzzleFirework;
+ (void) puzzlePiecesDrop;
+ (void) puzzleMakeItRain;

@end
