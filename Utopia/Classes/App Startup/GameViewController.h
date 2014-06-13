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
#import "AttackMapViewController.h"
#import "DungeonBattleLayer.h"
#import "OneLineNotificationViewController.h"
#import "CCDirector+Downloader.h"
#import "DialogueViewController.h"
#import "ClanRaidDetailsViewController.h"
#import "MiniTutorialController.h"
#import "QuestUtil.h"
#import "QuestLogViewController.h"
#import "QuestCompleteLayer.h"
#import "AchievementUtil.h"
#import "ChatViewController.h"

@class TutorialController;

@interface GameViewController : UIViewController <AttackMapDelegate, BattleLayerDelegate, CCDirectorDownloaderDelegate, DialogueViewControllerDelegate, ClanRaidDetailsDelegate, MiniTutorialDelegate, QuestUtilDelegate, QuestLogDelegate, QuestCompleteDelegate, AchievementUtilDelegate, ChatViewControllerDelegate> {
  int _questIdAfterDialogue;
  
  int _assetIdForMissionMap;
  
  BOOL _isFreshRestart;
  
  BOOL _isFromFacebook;
  BOOL _shouldRejectFacebook;
  
  BOOL _isInBattle;
  
  AttackMapViewController *_amvc;
}

@property (nonatomic, strong) TopBarViewController *topBarViewController;
@property (nonatomic, strong) OneLineNotificationViewController *notifViewController;
@property (nonatomic, strong) GameMap *currentMap;
@property (nonatomic, strong) ChatViewController *chatViewController;

@property (nonatomic, strong) IBOutlet TravelingLoadingView *loadingView;

@property (nonatomic, strong) TutorialController *tutController;
@property (nonatomic, strong) MiniTutorialController *miniTutController;

@property (nonatomic, strong) MinimumUserTaskProto *resumeUserTask;
@property (nonatomic, strong) NSArray *resumeTaskStages;

@property (nonatomic, strong) QuestCompleteLayer *questCompleteLayer;
@property (nonatomic, strong) TopBarQuestProgressView *topBarQuestProgressView;
@property (nonatomic, strong) NSMutableArray *completedQuests;
@property (nonatomic, strong) NSMutableArray *progressedJobs;
@property (nonatomic, strong) AchievementProto *completedAchievement;
@property (nonatomic, assign) int numAchievementsComplete;

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

- (void) buildingPurchased:(int)structId;
- (void) enterDungeon:(int)taskId withDelay:(float)delay;

- (void) visitCityClicked:(int)cityId assetId:(int)assetId;
- (void) visitCityClicked:(int)cityId;

- (void) openPrivateChatWithUserId:(int)userId name:(NSString *)name;
- (void) openChatWithScope:(ChatScope)scope;

- (void) openGemShop;

- (void) questComplete:(FullQuestProto *)fqp;
- (void) beginDialogue:(DialogueProto *)proto withQuestId:(int)questId;

- (void) crossFadeIntoBattleLayer:(NewBattleLayer *)bl;
- (void) blackFadeIntoBattleLayer:(NewBattleLayer *)bl;

- (void) showTopBarDuration:(float)duration completion:(void (^)(void))completion;
- (void) hideTopBarDuration:(float)duration completion:(void (^)(void))completion;

- (BOOL) canProceedWithFacebookId:(NSString *)facebookId;

@end
