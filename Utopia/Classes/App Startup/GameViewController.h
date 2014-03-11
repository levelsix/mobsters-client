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

@class TutorialController;

@interface GameViewController : UIViewController <AttackMapDelegate, BattleLayerDelegate, CCDirectorDownloaderDelegate, DialogueViewControllerDelegate, ClanRaidDetailsDelegate, MiniTutorialDelegate> {
  int _questIdAfterDialogue;
  
  BOOL _isFreshRestart;
}

@property (nonatomic, strong) TopBarViewController *topBarViewController;
@property (nonatomic, strong) OneLineNotificationViewController *notifViewController;
@property (nonatomic, strong) GameMap *currentMap;

@property (nonatomic, strong) IBOutlet TravelingLoadingView *loadingView;

@property (nonatomic, strong) TutorialController *tutController;
@property (nonatomic, strong) MiniTutorialController *miniTutController;

+ (id) baseController;

- (void) handleConnectedToHost;
- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialReceivedStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialFinished;

- (void) buildingPurchased:(int)structId;
- (void) enterDungeon:(int)taskId withDelay:(float)delay;

- (void) openPrivateChatWithUserId:(int)userId;

- (void) openGemShop;

- (void) beginDialogue:(DialogueProto *)proto withQuestId:(int)questId;

- (void) crossFadeIntoBattleLayer:(NewBattleLayer *)bl;
- (void) blackFadeIntoBattleLayer:(NewBattleLayer *)bl;

- (void) showTopBarDuration:(float)duration completion:(void (^)(void))completion;
- (void) hideTopBarDuration:(float)duration completion:(void (^)(void))completion;

- (BOOL) canProceedWithFacebookId:(NSString *)facebookId;

@end
