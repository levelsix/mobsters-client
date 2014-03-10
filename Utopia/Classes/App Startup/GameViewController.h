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

@class TutorialController;

@interface GameViewController : UIViewController <AttackMapDelegate, BattleLayerDelegate, CCDirectorDownloaderDelegate, DialogueViewControllerDelegate, ClanRaidDetailsDelegate> {
  int _questIdAfterDialogue;
  
  BOOL _isFreshRestart;
}

@property (nonatomic, strong) TopBarViewController *topBarViewController;
@property (nonatomic, strong) OneLineNotificationViewController *notifViewController;
@property (nonatomic, strong) GameMap *currentMap;

@property (nonatomic, strong) IBOutlet TravelingLoadingView *loadingView;

@property (nonatomic, strong) TutorialController *tutController;

+ (id) baseController;

- (void) handleConnectedToHost;
- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialFinishedWithStartupResponse:(StartupResponseProto *)startupResponse loadCityResponse:(LoadCityResponseProto *)loadCityResponse;

- (void) buildingPurchased:(int)structId;
- (void) enterDungeon:(int)taskId withDelay:(float)delay;

- (void) openPrivateChatWithUserId:(int)userId;

- (void) openGemShop;

- (void) beginDialogue:(DialogueProto *)proto withQuestId:(int)questId;

- (void) crossFadeIntoBattleLayer:(NewBattleLayer *)bl;
- (void) blackFadeIntoBattleLayer:(NewBattleLayer *)bl;

- (void) showTopBarDuration:(float)duration completion:(void (^)(void))completion;
- (void) hideTopBarDuration:(float)duration completion:(void (^)(void))completion;

@end
