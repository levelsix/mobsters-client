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

@property (nonatomic, retain) id<ALSoundSource> repeatingEffect;
@property (nonatomic, retain) id<ALSoundSource> ambientNoise;

+ (SoundEngine *)sharedSoundEngine;

- (void) stopBackgroundMusic;
- (void) resumeBackgroundMusic;
- (id<ALSoundSource>) playEffect:(NSString *)effect;
- (void) preloadEffect:(NSString *)effect;
+ (void) stopRepeatingEffect;

- (void) playHomeMapMusic;
- (void) playMissionMapMusic;
- (void) playBattleMusic;

+ (void) tutorialFirstGoodDialogue;
+ (void) tutorialFirstBadDialogue;
+ (void) dialogueBoxOpen;
+ (void) spriteJump;
+ (void) tutorialBoatScene;

+ (void) closeButtonClick;
+ (void) generalButtonClick;
+ (void) menuPopUp;

+ (void) chatOpened;
+ (void) chatClosed;

+ (void) nextTask;
+ (void) enhanceFlying;

+ (void) helpRequested;
+ (void) freeSpeedupAvailable;

+ (void) gachaReveal;
+ (void) gachaSpinStart;
+ (void) secretGiftClicked;
+ (void) secretGiftCollectClicked;

+ (void) itemSelectUseGems;
+ (void) itemSelectUseOil;
+ (void) itemSelectUseCash;
+ (void) itemSelectUseSpeedup;

+ (void) structSpeedupConstruction;
+ (void) structUpgradeClicked;
+ (void) structDropped;
+ (void) structCantPlace;
+ (void) structSelected;
+ (void) structCompleted;
+ (void) structCollectOil;
+ (void) structCollectCash;
+ (void) structCollectGems;

+ (void) puzzleDamageTickStart;
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
+ (void) puzzleRainbowCreate;
+ (void) puzzleGrenadeCreate;
+ (void) puzzleRocketCreate;
+ (void) puzzleSkillActivated;
+ (void) puzzleBreakCloud;
+ (void) puzzleBreakLock;

@end
