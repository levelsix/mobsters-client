//
//  RootViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "GameViewController.h"
#import "GameConfig.h"
#import "GameState.h"
#import "Globals.h"
#import "GenericPopupController.h"
#import "HomeMap.h"
#import "MissionMap.h"
#import "SoundEngine.h"
#import "NewBattleLayer.h"
#import "LoadingViewController.h"
#import "OutgoingEventController.h"
#import "TopBarViewController.h"
#import "AppDelegate.h"
#import "DungeonBattleLayer.h"
#import "Downloader.h"
#import <Carrot/Carrot.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DiamondShopViewController.h"
#import "MenuNavigationController.h"
#import "MyCroniesViewController.h"
#import "CCTexture_Private.h"
#import "PvpBattleLayer.h"
#import "DialogueViewController.h"
#import "QuestLogViewController.h"
#import "ClanRaidBattleLayer.h"

#define DEFAULT_PNG_IMAGE_VIEW_TAG 103
#define KINGDOM_PNG_IMAGE_VIEW_TAG 104

#define PART_0_PERCENT 0.f
#define PART_1_PERCENT 0.05f
#define PART_2_PERCENT 0.85f
#define PART_3_PERCENT 1.f

@implementation GameViewController

+ (id) baseController {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  UINavigationController *nav = (UINavigationController *)ad.window.rootViewController;
  UIViewController *vc = [nav.childViewControllers objectAtIndex:0];
  return vc;
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGSize size = rect.size;
  rect.size = CGSizeMake(rect.size.height, rect.size.width);
  rect.origin = CGPointMake((size.height-rect.size.width)/2, (size.width-rect.size.height)/2);
  UIView *v = [[UIView alloc] initWithFrame:rect];
  v.backgroundColor = [UIColor blackColor];
  
  self.view = v;
  
  [self setupCocos2D];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

- (void)setupCocos2D {
  CCDirector *director = [CCDirector sharedDirector];
  CCGLView *glView = [CCGLView viewWithFrame:self.view.bounds
                                 pixelFormat:kEAGLColorFormatRGB565
                                 depthFormat:GL_DEPTH24_STENCIL8_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  
  // Display link director is causing problems with uiscrollview and table view.
  [director setProjection:CCDirectorProjection2D];
  [director setView:glView];
  
  [self.view insertSubview:glView atIndex:0];
  
	[director setAnimationInterval:1.0/60];
  
#ifdef DEBUG
	[director setDisplayStats:YES];
#else
	[director setDisplayStats:NO];
#endif
  
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
  
  [CCTexture PVRImagesHavePremultipliedAlpha:NO];
  
  [[CCFileUtils sharedFileUtils] setiPhoneRetinaDisplaySuffix:@"@2x"];
  [[CCDirector sharedDirector] setDownloaderDelegate:self];
  
  [self addChildViewController:director];
  [self.view addSubview:director.view];
}

- (void) setupTopBar {
  self.topBarViewController = [[TopBarViewController alloc] initWithNibName:@"TopBarViewController" bundle:nil];
  [self addChildViewController:self.topBarViewController];
  self.topBarViewController.view.frame = self.view.bounds;
  [self.view addSubview:self.topBarViewController.view];
}

- (void) setupNotificationViewController {
  self.notifViewController = [[OneLineNotificationViewController alloc] init];
  [self.notifViewController displayView];
}

- (void) viewDidLoad {
  [self setupTopBar];
  [self fadeToLoadingScreen];
  
  [self progressTo:PART_1_PERCENT];
  
  [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil];
}

- (void) viewDidAppear:(BOOL)animated {
  [self setupNotificationViewController];
}

- (void) dealloc {
  // Must do this manually since it will be in the key window
  [self.notifViewController.view removeFromSuperview];
}

- (void) fadeToLoadingScreen {
  LoadingViewController *lvc = [[LoadingViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:lvc];
  nav.navigationBarHidden = YES;
  [self presentViewController:nav animated:NO completion:nil];
}

- (void) progressTo:(float)t {
  LoadingViewController *lvc = (LoadingViewController *)[(UINavigationController *)self.presentedViewController visibleViewController];
  if ([lvc isKindOfClass:[LoadingViewController class]]) {
    [lvc progressToPercentage:t];
  }
}

- (void) handleConnectedToHost {
  [self progressTo:PART_2_PERCENT];
  [[OutgoingEventController sharedOutgoingEventController] startupWithDelegate:self];
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  [self progressTo:PART_3_PERCENT];
  
  StartupResponseProto *proto = (StartupResponseProto *)fe.event;
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    GameState *gs = [GameState sharedGameState];
    [[OutgoingEventController sharedOutgoingEventController] loadPlayerCity:gs.userId withDelegate:self];
    
    // Stop the map spinner view
    if (self.loadingView.superview) {
      [self.loadingView stop];
    }
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self beginTutorial:proto.tutorialConstants];
  }
}

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  if ([self.navigationController.visibleViewController isKindOfClass:[LoadingViewController class]]) {
    [self progressTo:1.f];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Load the home map
    [self visitCityClicked:0];
  } else if ([self.currentMap isKindOfClass:[HomeMap class]]) {
    [(HomeMap *)self.currentMap refresh];
  }
}

#pragma mark - Tutorial Stuff

- (void) beginTutorial:(StartupResponseProto_TutorialConstants *)constants {
  self.tutController = [[TutorialController alloc] initWithTutorialConstants:constants gameViewController:self];
  [self.tutController beginTutorial];
}

#pragma mark - Observer methods to update top bar

#define BOTTOM_VIEW_KEY_PATH @"bottomOptionView"

- (void) setCurrentMap:(GameMap *)currentMap {
  [self.currentMap removeObserver:self forKeyPath:BOTTOM_VIEW_KEY_PATH];
  _currentMap = currentMap;
  [self.topBarViewController removeViewOverChatView];
  [self.currentMap addObserver:self forKeyPath:BOTTOM_VIEW_KEY_PATH options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self.currentMap) {
    if (self.currentMap.bottomOptionView) {
      [self.topBarViewController replaceChatViewWithView:self.currentMap.bottomOptionView];
    } else {
      [self.topBarViewController removeViewOverChatView];
    }
  }
}

- (void) showTopBarDuration:(float)duration completion:(void (^)(void))completion {
  self.topBarViewController.view.hidden = NO;
  [self.topBarViewController viewWillAppear:(duration > 0.f)];
  if (duration > 0.f) {
    [UIView animateWithDuration:duration animations:^{
      self.topBarViewController.view.alpha = 1.f;
    } completion:^(BOOL finished) {
      [self.topBarViewController viewDidAppear:YES];
      
      if (completion) {
        completion();
      }
    }];
  } else {
    self.topBarViewController.view.alpha = 1.f;
    [self.topBarViewController viewDidAppear:NO];
    
    if (completion) {
      completion();
    }
  }
}

- (void) hideTopBarDuration:(float)duration completion:(void (^)(void))completion {
  [self.topBarViewController viewWillDisappear:(duration > 0.f)];
  if (duration > 0.f) {
    [UIView animateWithDuration:duration animations:^{
      self.topBarViewController.view.alpha = 0.f;
    } completion:^(BOOL finished) {
      self.topBarViewController.view.hidden = YES;
      [self.topBarViewController viewDidDisappear:YES];
      
      if (completion) {
        completion();
      }
    }];
  } else {
    self.topBarViewController.view.alpha = 0.f;
    self.topBarViewController.view.hidden = YES;
    [self.topBarViewController viewDidDisappear:NO];
    
    if (completion) {
      completion();
    }
  }
}

#pragma mark - Home Map Methods

- (void) buildingPurchased:(int)structId {
  if (self.currentMap.cityId != 0) {
    [self visitCityClicked:0];
  }
  if ([self.currentMap isKindOfClass:[HomeMap class]]) {
    [(HomeMap *)self.currentMap preparePurchaseOfStruct:structId];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

#pragma mark - Moving to other cities

- (void) visitCityClicked:(int)cityId {
  if (!self.currentMap || self.currentMap.cityId != cityId) {
    if (cityId == 0) {
      CCScene *scene = [CCScene node];
      HomeMap *hm = [HomeMap node];
      [hm refresh];
      [scene addChild:hm];
      [hm moveToCenterAnimated:NO];
      self.currentMap = hm;
      
      [self.topBarViewController removeMyCityView];
      
      CCDirector *dir = [CCDirector sharedDirector];
      if (![dir runningScene]) {
        [dir pushScene:scene];
      } else {
        [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.4f]];
      }
    } else {
      [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:cityId withDelegate:self];
      
      GameState *gs = [GameState sharedGameState];
      FullCityProto *city = [gs cityWithId:cityId];
      self.loadingView.label.text = [NSString stringWithFormat:@"Traveling to\n%@", city.name];
      [self.loadingView display:self.view];
    }
  } else {
    if (cityId == 0) {
      [(HomeMap *)self.currentMap refresh];
    }
  }
}

- (void) handleLoadCityResponseProto:(FullEvent *)fe {
  LoadCityResponseProto *proto = (LoadCityResponseProto *)fe.event;
  
  CCScene *scene = [CCScene node];
  MissionMap *mm = [[MissionMap alloc] initWithProto:proto];
  [scene addChild:mm];
  [mm moveToCenterAnimated:NO];
  self.currentMap = mm;
  [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.4f]];
  
  [self.topBarViewController performSelector:@selector(showMyCityView) withObject:nil afterDelay:0.4];
  
  [self.loadingView stop];
}

- (void) enterDungeon:(int)taskId withDelay:(float)delay {
  GameState *gs = [GameState sharedGameState];
  DungeonBattleLayer *bl = [[DungeonBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
  bl.delegate = self;
  [self performSelector:@selector(crossFadeIntoBattleLayer:) withObject:bl afterDelay:delay];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:taskId isEvent:NO eventId:0 useGems:NO withDelegate:bl];
}

- (void) crossFadeIntoBattleLayer:(NewBattleLayer *)bl {
  float duration = 0.6;
  
  CCDirector *dir = [CCDirector sharedDirector];
  CCScene *scene = [CCScene node];
  [scene addChild:bl];
  if (dir.runningScene) {
    [dir pushScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:duration]];
  } else {
    [dir replaceScene:scene];
  }
  
  [self hideTopBarDuration:duration completion:nil];
}

- (void) enterDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems {
  GameState *gs = [GameState sharedGameState];
  DungeonBattleLayer *bl = [[DungeonBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
  bl.delegate = self;
  
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:taskId isEvent:isEvent eventId:eventId useGems:useGems withDelegate:bl];
  
  [self blackFadeIntoBattleLayer:bl];
}

- (void) beginClanRaidBattle:(PersistentClanEventProto *)clanEvent withTeam:(NSArray *)team {
  GameState *gs = [GameState sharedGameState];
  if (gs.curClanRaidInfo.clanEventId == clanEvent.clanEventId) {
    ClanRaidBattleLayer *bl = [[ClanRaidBattleLayer alloc] initWithEvent:gs.curClanRaidInfo myUserMonsters:team puzzleIsOnLeft:NO];
    bl.delegate = self;
    
    [self blackFadeIntoBattleLayer:bl];
  }
}

- (void) blackFadeIntoBattleLayer:(NewBattleLayer *)bl {
  // Must start animation so that the scene is auto switched instead of glitching
  [[CCDirector sharedDirector] startAnimation];
  CCScene *scene = [CCScene node];
  [scene addChild:bl];
  
  CCDirector *dir = [CCDirector sharedDirector];
  if (dir.runningScene) {
    CCNodeColor *c = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    [dir.runningScene addChild:c];
    [dir pushScene:scene withTransition:[CCTransition transitionFadeWithColor:[CCColor blackColor] duration:0.6f]];
    [c performSelector:@selector(removeFromParent) withObject:nil afterDelay:1.f];
  } else {
    [dir replaceScene:scene];
  }
  
  [self hideTopBarDuration:0.f completion:nil];
}

- (void) findPvpMatch:(BOOL)useGems {
  GameState *gs = [GameState sharedGameState];
  PvpBattleLayer *bl = [[PvpBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
  bl.delegate = self;
  bl.useGemsForQueue = useGems;
  
  [[OutgoingEventController sharedOutgoingEventController] queueUpEvent:nil withDelegate:bl];
  
  [self blackFadeIntoBattleLayer:bl];
}

#pragma mark - CCDirectorDownloaderDelegate methods

- (NSString *) filepathToFile:(NSString *)filename {
  return [Globals pathToFile:filename];
}

- (NSString *) downloadFile:(NSString *)filename {
  return [[Downloader sharedDownloader] syncDownloadFile:[Globals getDoubleResolutionImage:filename]];
}

#pragma mark - BattleLayerDelegate methods

- (void) battleComplete:(NSDictionary *)params {
  float duration = 0.6;
  
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:duration]];
  
  if ([[params objectForKey:BATTLE_MANAGE_CLICKED_KEY] boolValue]) {
    MenuNavigationController *m = [[MenuNavigationController alloc] init];
    [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
    [self presentViewController:m animated:YES completion:^{
      [self showTopBarDuration:0.f completion:nil];
    }];
  } else {
    [self showTopBarDuration:duration completion:nil];
  }
}

#pragma mark - Chat access

- (void) openPrivateChatWithUserId:(int)userId {
  void (^openChat)(void) = ^{
    [self.topBarViewController.chatViewController openWithConversationForUserId:userId];
  };
  if (self.presentedViewController) {
    [self dismissViewControllerAnimated:YES completion:openChat];
  } else {
    openChat();
  }
}

#pragma mark - Gem Shop access

- (void) openGemShop {
  DiamondShopViewController *dvc = [[DiamondShopViewController alloc] init];
  if (self.presentedViewController) {
    UINavigationController *nav = (UINavigationController *)self.presentedViewController;
    [nav pushViewController:dvc animated:YES];
    
    // In case we go to gem shop from attack map
    nav.navigationBarHidden = NO;
  } else {
    MenuNavigationController *m = [[MenuNavigationController alloc] init];
    [self presentViewController:m animated:YES completion:nil];
    [m pushViewController:[[DiamondShopViewController alloc] init] animated:NO];
  }
}

#pragma mark - Dialogue

- (void) beginDialogue:(DialogueProto *)proto withQuestId:(int)questId {
  _questIdAfterDialogue = questId;
  [self hideTopBarDuration:0.3f completion:^{
    DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:proto];
    dvc.delegate = self;
    [self addChildViewController:dvc];
    [self.view addSubview:dvc.view];
  }];
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self showTopBarDuration:0.3f completion:nil];
  
  if (_questIdAfterDialogue) {
    QuestLogViewController *qvc = [[QuestLogViewController alloc] init];
    [self addChildViewController:qvc];
    qvc.view.frame = self.view.bounds;
    [self.view addSubview:qvc.view];
    
    GameState *gs = [GameState sharedGameState];
    FullQuestProto *fqp = [gs questForId:_questIdAfterDialogue];
    [qvc loadDetailsViewForQuest:fqp userQuest:nil animated:NO];
  }
}

@end
