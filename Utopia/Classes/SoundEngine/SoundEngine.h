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
  kMissionMapMusic,
  kHomeMapMusic,
  kBattleMusic
} BackgroundMusic;

@interface SoundEngine : NSObject {
  BackgroundMusic _curMusic;
  BackgroundMusic _lastPlayedMusic;
}

@property (nonatomic, retain) id<ALSoundSource> damageTick;
@property (nonatomic, retain) id<ALSoundSource> ambientNoise;

+ (SoundEngine *)sharedSoundEngine;

- (void) stopBackgroundMusic;
- (void) resumeBackgroundMusic;
- (id<ALSoundSource>) playEffect:(NSString *)effect;

- (void) playHomeMapMusic;
- (void) playMissionMapMusic;
- (void) playBattleMusic;

+ (void) dialogueBoxOpen;
+ (void) spriteJump;
+ (void) tutorialBoatScene;

+ (void) closeButtonClick;
+ (void) generalButtonClick;
+ (void) menuPopUp;

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
+ (void) puzzleBoardExplosion;
+ (void) puzzleComboCreated;
+ (void) puzzleComboFire;
+ (void) puzzleSwapPiece;
+ (void) puzzleOrbsSlideIn;
+ (void) puzzleFirework;
+ (void) puzzlePiecesDrop;
+ (void) puzzleMakeItRain;
+ (void) puzzlePvpQueueUISlideIn;
+ (void) puzzlePvpQueueUISlideOut;
+ (void) puzzleWinLoseUI;
+ (void) puzzleYouWon;
+ (void) puzzleYouLose;

@end
