//
//  RootViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "TopBarViewController.h"
#import "GameMap.h"
#import "DungeonBattleLayer.h"
#import "CCDirector+Downloader.h"
#import "DialogueViewController.h"
#import "ClanRaidDetailsViewController.h"
#import "MiniTutorialController.h"
#import "QuestUtil.h"
#import "QuestLogViewController.h"
#import "QuestCompleteLayer.h"
#import "AchievementUtil.h"
#import "ChatViewController.h"
#import "ClanViewController.h"
#import "AttackMapViewController.h"
#import "HudNotificationController.h"
#import "StageCompleteNode.h"
#import "LoadingViewController.h"

@class TutorialController;

@interface GameViewController : UIViewController <AttackMapDelegate, BattleLayerDelegate, CCDirectorDownloaderDelegate, DialogueViewControllerDelegate, ClanRaidDetailsDelegate, MiniTutorialDelegate, QuestUtilDelegate, QuestLogDelegate, QuestCompleteDelegate, AchievementUtilDelegate, ChatViewControllerDelegate, ClanViewControllerDelegate, StageCompleteDelegate> {
  int _questIdAfterDialogue;
  
  int _assetIdForMissionMap;
  
  BOOL _isFreshRestart;
  
  BOOL _isFromFacebook;
  BOOL _shouldRejectFacebook;
  
  BOOL _isInBattle;
  
  AttackMapViewController *_amvc;
}

@property (nonatomic, strong) TopBarViewController *topBarViewController;
@property (nonatomic, strong) HudNotificationController *notificationController;
@property (nonatomic, strong) GameMap *currentMap;

@property (nonatomic, strong) LoadingViewController *loadingViewController;

// Generic spinner for money tree
@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) ChatViewController *chatViewController;
@property (nonatomic, strong) ClanViewController *clanViewController;

@property (nonatomic, strong) TutorialController *tutController;
@property (nonatomic, strong) MiniTutorialController *miniTutController;

@property (nonatomic, strong) MinimumUserTaskProto *resumeUserTask;
@property (nonatomic, strong) NSArray *resumeTaskStages;

@property (nonatomic, strong) QuestCompleteLayer *questCompleteLayer;
@property (nonatomic, strong) TopBarQuestProgressView *topBarQuestProgressView;
@property (nonatomic, strong) NSMutableArray *completedQuests;
@property (nonatomic, strong) NSMutableArray *progressedJobs;

+ (id) baseController;

- (void) removeAllViewControllers;

- (void) fadeToLoadingScreenPercentage:(float)percentage animated:(BOOL)animated;
- (void) handleSignificantTimeChange;
- (void) handleForceLogoutResponseProto:(ForceLogoutResponseProto *)proto;

- (void) openedFromFacebook;
- (void) handleConnectedToHost;
- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialReceivedStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialFinished;

- (BOOL) buildingPurchased:(int)structId;
- (void) pointArrowOnSellMobsters;
- (void) pointArrowOnManageTeam;
- (BOOL) pointArrowToUpgradeForStructId:(int)structId quantity:(int)quantity;
- (void) arrowToStructInShopWithId:(int)structId;
- (void) arrowToOpenClanMenu;
- (void) arrowToRequestToon;

- (void) enterDungeon:(int)taskId withDelay:(float)delay;

- (void) visitCityClicked:(int)cityId assetId:(int)assetId;
- (void) visitCityClicked:(int)cityId;
- (void) visitCityClicked:(int)cityId assetId:(int)assetId animated:(BOOL)animated;

- (void) openPrivateChatWithUserUuid:(NSString *)userUuid name:(NSString *)name;
- (void) openChatWithScope:(ChatScope)scope;
- (void) openClanView;
- (void) openClanViewForClanUuid:(NSString *)clanUuid;

- (void) openGemShop;

- (void) openPushNotificationRequestWithMessage:(NSString *) message;

- (void) questComplete:(FullQuestProto *)fqp;
- (void) beginDialogue:(DialogueProto *)proto withQuestId:(int)questId;

- (void) beginPvpMatchAgainstUser:(NSString *)userUuid;
- (void) beginPvpMatchForRevenge:(PvpHistoryProto *)history;
- (void) beginPvpMatchForAvenge:(PvpClanAvenging *)ca;

- (void) crossFadeIntoBattleLayer:(NewBattleLayer *)bl;
- (void) blackFadeIntoBattleLayer:(NewBattleLayer *)bl;

- (void) showTopBarDuration:(float)duration completion:(void (^)(void))completion;
- (void) hideTopBarDuration:(float)duration completion:(void (^)(void))completion;

- (BOOL) canProceedWithFacebookUser:(NSDictionary *)fbUser;

- (void) invalidateAllTimers;
- (void) beginAllTimers;

@end
