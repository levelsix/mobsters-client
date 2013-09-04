//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

// App
+ (void) openedApp;
+ (void) beganApp;
+ (void) resumedApp;
+ (void) suspendedApp;
+ (void) terminatedApp;

// Monetization
+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold;
+ (void) cancelledGoldPackage:(NSString *)package;
+ (void) inAppPurchaseFailed;
+ (void) viewedGoldShopFromTopMenu;

+ (void) clickedGetMoreGold:(int)goldAmt;
+ (void) clickedGetMoreSilver;

+ (void) notEnoughSilverInArmory:(int)equipId;
+ (void) notEnoughGoldInArmory:(int)equipId;

+ (void) notEnoughSilverForUpgrade:(int)structId cost:(int)cost;
+ (void) notEnoughGoldForUpgrade:(int)structId cost:(int)cost;

+ (void) notEnoughGoldToRefillEnergyPopup;
+ (void) notEnoughGoldToRefillStaminaPopup;

+ (void) notEnoughSilverInCarpenter:(int)structId;
+ (void) notEnoughGoldInCarpenter:(int)structId;

+ (void) notEnoughGoldForInstaBuild:(int)structId;
+ (void) notEnoughGoldForInstaUpgrade:(int)structId level:(int)level cost:(int)cost;

+ (void) notEnoughSilverForMarketplaceBuy:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceBuy:(int)equipId cost:(int)cost;
+ (void) notEnoughSilverForMarketplaceRetract:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceRetract:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceShortLicense;
+ (void) notEnoughGoldForMarketplaceLongLicense;

+ (void) notEnoughGoldToRefillEnergyTopBar;
+ (void) notEnoughGoldToRefillStaminaTopBar;

+ (void) notEnoughStaminaForBattle;
+ (void) notEnoughEnergyForTasks:(int)taskId;
+ (void) notEnoughEquipsForTasks:(int)taskId equipReqs:(NSArray *)reqs;

// Engagement events
+ (void) levelUp:(int)level;
+ (void) placedCritStruct:(NSString *)name;

+ (void) attackAgain;
+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth;

+ (void) questAccept:(int)questId;
+ (void) questComplete:(int)questId;
+ (void) questRedeem:(int)questId;

+ (void) taskViewed:(int)taskId;
+ (void) taskExecuted:(int)taskId;
+ (void) taskClosed:(int)taskId;

+ (void) addedSkillPoint:(NSString *)stat;

+ (void) attemptedPurchase;
+ (void) successfulPurchase:(int)equipId;
+ (void) attemptedPost;
+ (void) successfulPost:(int)equipId;
+ (void) viewedRetract;
+ (void) attemptedRetract;
+ (void) successfulRetract;
+ (void) licensePopup;
+ (void) boughtLicense:(NSString *)type;
+ (void) clickedListAnItem;

+ (void) vaultOpen;
+ (void) vaultDeposit;
+ (void) vaultWithdraw;

+ (void) normStructUpgrade:(int)structId level:(int)level;
+ (void) normStructPurchase:(int)structId;
+ (void) normStructSell:(int)structId level:(int)level;
+ (void) normStructInstaUpgrade:(int)structId level:(int)level;
+ (void) normStructInstaBuild:(int)structId;

+ (void) openedPathMenu;
+ (void) openedNotifications;
+ (void) openedQuestLog;
+ (void) openedMyProfile;

+ (void) clickedVisit;
+ (void) receivedNotification;
+ (void) clickedRevenge;
+ (void) clickedCollect;

+ (void) clickedFillEnergy;
+ (void) clickedFillStamina;
+ (void) enemyProfileFromBattle;
+ (void) enemyProfileFromSprite;
+ (void) enemyProfileFromAttackMap;
+ (void) postedToEnemyProfile;
+ (void) postedToAllyProfile;

+ (void) clickedFreeOffers;
+ (void) watchedAdColony;
+ (void) adColonyFailed;
+ (void) kiipFailed;
+ (void) kiipUnlockedAchievement;
+ (void) kiipEnteredEmail;

+ (void) attemptedNameChange;
+ (void) nameChange;
+ (void) attemptedStatReset;
+ (void) statReset;
+ (void) attemptedTypeChange;
+ (void) typeChange;
+ (void) attemptedResetGame;
+ (void) resetGame;

+ (void) threeCardMonteImpression:(int)badCardId;
+ (void) threeCardMonteConversion:(int)badCardId numPlays:(int)numPlays pattern:(NSString *)pattern;

+ (void) blacksmithGuaranteedForgeWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithNotGuaranteedForgeWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithSpeedUpWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithCollectedItemsWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithGoToMarketplaceWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithBuyOneWithEquipId:(int)equipId level:(int)level;
+ (void) blacksmithFailedToGuaranteeForgeWithEquipId:(int)equipId level:(int)level cost:(int)gold;
+ (void) blacksmithFailedToSpeedUpWithEquipId:(int)equipId level:(int)level cost:(int)gold;

// Missing Features
+ (void) clickedMarketplaceSearch;
+ (void) clickedVisitCity;

// Tutorial
+ (void) tutStart;
+ (void) tutSideChosen;
+ (void) tutCharChosen;
+ (void) tutNameEntered;
+ (void) tutCompleteTask1;
+ (void) tutTaskCoin;
+ (void) tutQuestButton1;
+ (void) tutAvailQuest;
+ (void) tutClickedVisit;
+ (void) tutCompleteQuestTask;
+ (void) tutQuestCoin;
+ (void) tutQuestRedeem;
+ (void) tutLevelUp;
+ (void) tutSkillPoints;
+ (void) tutProfileClicked;
+ (void) tutNoAmuletClicked;
+ (void) tutAmuletEquipped;
+ (void) tutCloseBrowseView;
+ (void) tutCloseProfile1;
+ (void) tutAttackClicked;
+ (void) tutBattleStart;
+ (void) tutClickedBegin;
+ (void) tutClickedOkay1;
+ (void) tutClickedOkay2;
+ (void) tutClickedDone;
+ (void) tutClosedStolenEquip;
+ (void) tutClosedBattleSummary;
+ (void) tutBazaarClicked;
+ (void) tutBlacksmithClicked;
+ (void) tutForgeItemsClicked;
+ (void) tutGuaranteeClicked;
+ (void) tutForgeFinishNow;
+ (void) tutSpeedUpConfirmed;
+ (void) tutCheckResultsClicked;
+ (void) tutClosedForge;
+ (void) tutMyCityClicked;
+ (void) tutCarpenterClicked;
+ (void) tutPurchaseInn;
+ (void) tutPlacedInn;
+ (void) tutFinishNow;
+ (void) tutPathMenu;
+ (void) tutProfileButton;
+ (void) tutCloseProfile2;
+ (void) tutUserCreated;
+ (void) tutQuestButton2;
+ (void) tutComplete;

@end
