//
//  SoundEngine.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kNoMusic = 0,
  kHomeMapMusic,
  kMissionMapMusic,
  kBattleMusic,
  kBazaarMusic
} BackgroundMusic;

@interface SoundEngine : NSObject {
  BackgroundMusic _curMusic;
  BackgroundMusic _lastPlayedMusic;
  
  int _curChargeUp;
  int _puzzWalk;
  int _puzzPowerUp;
}

+ (SoundEngine *)sharedSoundEngine;

- (int) playEffect:(NSString *)effect;

- (void) playHomeMapMusic;
- (void) playMissionMapMusic;
- (void) playBattleMusic;
- (void) playBazaarMusic;
- (void) resumeBackgroundMusic;
- (void) stopBackgroundMusic;

- (void) archerAttack;
- (void) legionMageAttack;
- (void) allianceMageAttack;
- (void) warriorAttack;
- (void) archerCharge;
- (void) legionMageCharge;
- (void) allianceMageCharge;
- (void) warriorCharge;
- (void) stopCharge;
- (void) perfectAttack;
- (void) goodAttack;
- (void) greatAttack;
- (void) missAttack;
- (void) battleVictory;
- (void) battleLoss;

- (void) warriorTaskSound;
- (void) archerTaskSound;
- (void) mageTaskSound;
- (void) genericTaskSound;

- (void) coinDrop;
- (void) coinPickup;
- (void) shinyItem;

- (void) closeDoor;
- (void) openDoor;

- (void) levelUp;
- (void) levelUpPopUp;

- (void) questComplete;
- (void) questAccepted;
- (void) questLogOpened;

- (void) armoryBuy;
- (void) armoryEnter;
- (void) armoryLeave;

- (void) marketplaceBuy;
- (void) marketplaceEnter;
- (void) marketplaceLeave;

- (void) vaultWithdraw;
- (void) vaultDeposit;
- (void) vaultEnter;
- (void) vaultLeave;

- (void) carpenterEnter;
- (void) carpenterComplete;
- (void) carpenterPurchase;

- (void) forgeEnter;
- (void) forgeSubmit;
- (void) forgeCollect;
- (void) forgeSuccess;
- (void) forgeFailure;

- (void) notificationAlert;

// Puzzle
- (void) puzzleBoardExplosion;
- (void) puzzlePlane;
- (void) puzzleRocket;
- (void) puzzleComboSound:(int)combo;
- (void) puzzleGemPop;
- (void) puzzleWrongMove;
- (void) puzzleWalking;
- (void) puzzleStopWalking;
- (void) puzzlePowerUp;
- (void) puzzleStopPowerUp;

@end
