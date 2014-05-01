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
#import "DiamondShopViewController.h"
#import "MenuNavigationController.h"
#import "MyCroniesViewController.h"
#import "CCTexture_Private.h"
#import "PvpBattleLayer.h"
#import "DialogueViewController.h"
#import "QuestLogViewController.h"
#import "ClanRaidBattleLayer.h"
#import "TutorialController.h"
#import "FacebookDelegate.h"
#import "SocketCommunication.h"
#import "IncomingEventController.h"
#import "MiniTutorialController.h"
#import "SoundEngine.h"
#import <cocos2d-ui.h>
#import "LevelUpNode.h"
#import "QuestCompleteLayer.h"

#define DEFAULT_PNG_IMAGE_VIEW_TAG 103
#define KINGDOM_PNG_IMAGE_VIEW_TAG 104

#define PART_0_PERCENT 0.f
#define PART_1_PERCENT 0.05f
#define PART_2_PERCENT 0.75f
#define PART_3_PERCENT 0.9f

@implementation GameViewController

- (id) init {
  if ((self = [super init])) {
    _isFreshRestart = YES;
  }
  return self;
}

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
  if (!self.notifViewController) {
    self.notifViewController = [[OneLineNotificationViewController alloc] init];
    [self.notifViewController displayView];
  }
}

- (void) viewDidLoad {
  [self setupTopBar];
  [self fadeToLoadingScreenPercentage:0.f animated:NO];
  [self progressTo:PART_1_PERCENT animated:YES];
  
  [QuestUtil setDelegate:self];
  [AchievementUtil setDelegate:self];
  
  [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLevelUp) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  
  self.completedQuests = [NSMutableArray array];
  self.progressedJobs = [NSMutableArray array];
}

- (void) viewDidAppear:(BOOL)animated {
  [self setupNotificationViewController];
  
  [self checkQuests];
  
  //GameState *gs = [GameState sharedGameState];
  //NSMutableArray *arr = gs.inProgressIncompleteQuests.allValues.mutableCopy;
  //[arr shuffle];
  //[self questComplete:arr[0]];
}

- (void) dealloc {
  // Must do this manually since it will be in the key window
  [self.notifViewController.view removeFromSuperview];
}

- (void) removeAllViewControllers {
  if (self.view.superview) {
    NSArray *acceptable = @[self.topBarViewController, [CCDirector sharedDirector], self.notifViewController];
    for (UIViewController *vc in self.childViewControllers) {
      if (![acceptable containsObject:vc]) {
        if ([vc respondsToSelector:@selector(close)]) {
          [vc performSelector:@selector(close)];
        } else if ([vc respondsToSelector:@selector(close:)]) {
          [vc performSelector:@selector(close:) withObject:nil];
        } else if ([vc respondsToSelector:@selector(closeClicked:)]) {
          [vc performSelector:@selector(closeClicked:) withObject:nil];
        } else {
          [vc.view removeFromSuperview];
          [vc removeFromParentViewController];
        }
      }
    }
  }
}

- (void) fadeToLoadingScreenAnimated:(BOOL)animated {
  LoadingViewController *lvc = (LoadingViewController *)[(UINavigationController *)self.presentedViewController visibleViewController];
  if (![lvc isKindOfClass:[LoadingViewController class]]) {
    if (self.presentedViewController) {
      [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (!self.tutController) {
      [self removeAllViewControllers];
      
      LoadingViewController *lvc = [[LoadingViewController alloc] initWithPercentage:0];
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:lvc];
      nav.navigationBarHidden = YES;
      [self presentViewController:nav animated:animated completion:nil];
    }
  }
}

- (void) fadeToLoadingScreenPercentage:(float)percentage animated:(BOOL)animated {
  [self fadeToLoadingScreenAnimated:animated];
  [self progressTo:percentage animated:NO];
}

- (void) handleSignificantTimeChange {
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected && !gs.isTutorial && !_isFromFacebook) {
    // App delegate will have already initialized network connection
    [self fadeToLoadingScreenPercentage:0 animated:NO];
    _isFreshRestart = YES;
  }
}

- (void) handleForceLogoutResponseProto:(ForceLogoutResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if ([proto.udid isEqualToString:[SocketCommunication getUdid]]) {
    if (gs.lastLoginTimeNum != proto.previousLoginTime) {
      [self fadeToLoadingScreenAnimated:YES];
    }
  } else {
    gs.connected = NO;
    [[SocketCommunication sharedSocketCommunication] closeDownConnection];
    [GenericPopupController displayNotificationViewWithText:@"You have been logged in on another device. Would you like to reconnect?" title:@"Reconnect?" okayButton:@"Reconnect" target:self selector:@selector(doFreshRestart)];
  }
}

- (void) doFreshRestart {
  _isFreshRestart = YES;
  [self fadeToLoadingScreenPercentage:0 animated:YES];
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:self];
}

- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse {
  GameState *gs = [GameState sharedGameState];
  gs.isTutorial = NO;
  
  // For tutorial
  self.tutController = nil;
  
  [self fadeToLoadingScreenPercentage:PART_3_PERCENT animated:YES];
  FullEvent *fe = [FullEvent createWithEvent:startupResponse tag:0];
  [[IncomingEventController sharedIncomingEventController] handleStartupResponseProto:fe];
  [self handleStartupResponseProto:fe];
}

- (void) tutorialReceivedStartupResponse:(StartupResponseProto *)startupResponse {
  GameState *gs = [GameState sharedGameState];
  gs.isTutorial = NO;
  
  FullEvent *fe = [FullEvent createWithEvent:startupResponse tag:0];
  [[IncomingEventController sharedIncomingEventController] handleStartupResponseProto:fe];
  [self handleStartupResponseProto:fe];
}

- (void) tutorialFinished {
  GameState *gs = [GameState sharedGameState];
  gs.isTutorial = NO;
  
  // For tutorial
  self.tutController = nil;
}

- (void) progressTo:(float)t animated:(BOOL)animated {
  LoadingViewController *lvc = (LoadingViewController *)[(UINavigationController *)self.presentedViewController visibleViewController];
  if ([lvc isKindOfClass:[LoadingViewController class]]) {
    if (animated) {
      [lvc progressToPercentage:t];
    } else {
      [lvc setPercentage:t];
    }
  }
}

- (void) handleConnectedToHost {
  if (!self.tutController && !_isFromFacebook) {
    [self progressTo:PART_2_PERCENT animated:YES];
    
    if (_isFreshRestart) {
      CCDirector *dir = [CCDirector sharedDirector];
      [self showTopBarDuration:0.f completion:nil];
      
      if (self.miniTutController) {
        [self.miniTutController stop];
        self.miniTutController = nil;
      }
      if (dir.runningScene) {
        [dir popToRootScene];
      }
    }
    
    [FacebookDelegate getFacebookIdAndDoAction:^(NSString *facebookId) {
      if ([SocketCommunication isForcedTutorial]) {
        NSLog(@"Forcing tutorial. Throwing away facebook id %@.", facebookId);
        facebookId = nil;
      }
      [[OutgoingEventController sharedOutgoingEventController] startupWithFacebookId:facebookId isFreshRestart:_isFreshRestart delegate:self];
      _isFreshRestart = NO;
    }];
  } else if (_isFromFacebook) {
    GameState *gs = [GameState sharedGameState];
    gs.connected = YES;
    
    [[SocketCommunication sharedSocketCommunication] initUserIdMessageQueue];
  }
  _isFromFacebook = NO;
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  [self progressTo:PART_3_PERCENT animated:YES];
  
  StartupResponseProto *proto = (StartupResponseProto *)fe.event;
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    GameState *gs = [GameState sharedGameState];
    [[OutgoingEventController sharedOutgoingEventController] loadPlayerCity:gs.userId withDelegate:self];
    
    [self.loadingView stop];
    
    if (proto.hasCurTask) {
      self.resumeUserTask = proto.curTask;
      self.resumeTaskStages = proto.curTaskStagesList;
    }
  } else if (proto.startupStatus == StartupResponseProto_StartupStatusUserNotInDb) {
    if (!self.tutController) {
      [self dismissViewControllerAnimated:YES completion:nil];
      [self beginTutorial:proto.tutorialConstants];
    }
  } else if (proto.startupStatus == StartupResponseProto_StartupStatusServerInMaintenance) {
    [self fadeToLoadingScreenPercentage:PART_2_PERCENT animated:YES];
    [GenericPopupController displayNotificationViewWithText:@"Sorry, the server is undergoing maintenance right now. Try again?" title:@"Server Maintenance" okayButton:@"Retry" target:self selector:@selector(handleConnectedToHost)];
  }
}

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  if ([self.navigationController.visibleViewController isKindOfClass:[LoadingViewController class]]) {
    [self progressTo:1.f animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{
      [self checkLevelUp];
    }];
    
    // Load the home map
    [self visitCityClicked:0 assetId:0 animated:NO];
    
    if (self.resumeUserTask) {
      GameState *gs = [GameState sharedGameState];
      DungeonBattleLayer *bl = [[DungeonBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
      [bl resumeFromUserTask:self.resumeUserTask stages:self.resumeTaskStages];
      bl.delegate = self;
      [self beginBattleLayer:bl];
      
      self.resumeUserTask = nil;
      self.resumeTaskStages = nil;
    }
  } else if (self.currentMap.cityId == 0 && [self.currentMap isKindOfClass:[HomeMap class]]) {
    [(HomeMap *)self.currentMap refresh];
  }
}

#pragma mark - Tutorial Stuff

- (void) beginTutorial:(StartupResponseProto_TutorialConstants *)constants {
  self.tutController = [[TutorialController alloc] initWithTutorialConstants:constants gameViewController:self];
  [self.tutController beginTutorial];
  
  GameState *gs = [GameState sharedGameState];
  gs.isTutorial = YES;
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
      
      [self checkLevelUp];
      
      if (completion) {
        completion();
      }
    }];
  } else {
    self.topBarViewController.view.alpha = 1.f;
    [self.topBarViewController viewDidAppear:NO];
    
    [self checkLevelUp];
    
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
      if (finished) {
        self.topBarViewController.view.hidden = YES;
        [self.topBarViewController viewDidDisappear:YES];
      }
      
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
  [self visitCityClicked:cityId assetId:0 animated:YES];
}

- (void) visitCityClicked:(int)cityId assetId:(int)assetId {
  [self visitCityClicked:cityId assetId:assetId animated:YES];
}

- (void) playMapMusic {
  if (self.currentMap.cityId == 0) {
    [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  } else if (self.currentMap.cityId > 0) {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
}

- (void) visitCityClicked:(int)cityId assetId:(int)assetId animated:(BOOL)animated {
  // If not animated, create new scene in case there are leftover artifacts.
  if (!self.currentMap || self.currentMap.cityId != cityId || !animated) {
    if (cityId == 0) {
      CCScene *scene = [CCScene node];
      HomeMap *hm = [HomeMap node];
      [scene addChild:hm];
      [hm moveToCenterAnimated:NO];
      self.currentMap = hm;
      
      CCDirector *dir = [CCDirector sharedDirector];
      float dur = 0.4f;
      if (animated) {
        [dir presentScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:dur]];
        [UIView animateWithDuration:dur animations:^{
          [self.topBarViewController removeMyCityView];
          [self.topBarViewController showClanView];
        }];
      } else {
        [dir presentScene:scene];
        [self.topBarViewController removeMyCityView];
        [self.topBarViewController showClanView];
      }
      
      [self playMapMusic];
    } else {
      _assetIdForMissionMap = assetId;
      
      [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:cityId withDelegate:self];
      
      GameState *gs = [GameState sharedGameState];
      FullCityProto *city = [gs cityWithId:cityId];
      self.loadingView.label.text = [NSString stringWithFormat:@"Traveling to\n%@", city.name];
      [self.loadingView display:self.view];
    }
  } else {
    if (cityId == 0) {
      [(HomeMap *)self.currentMap refresh];
    } else {
      if (assetId) {
        [(MissionMap *)self.currentMap moveToAssetId:assetId animated:YES];
      }
    }
  }
}

- (void) handleLoadCityResponseProto:(FullEvent *)fe {
  LoadCityResponseProto *proto = (LoadCityResponseProto *)fe.event;
  
  CCScene *scene = [CCScene node];
  MissionMap *mm = [[MissionMap alloc] initWithProto:proto];
  [scene addChild:mm];
  if (_assetIdForMissionMap) {
    [(MissionMap *)mm moveToAssetId:_assetIdForMissionMap animated:NO];
    _assetIdForMissionMap = 0;
  } else {
    [mm moveToCenterAnimated:NO];
  }
  self.currentMap = mm;
  
  float dur = 0.4f;
  [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:dur]];
  [UIView animateWithDuration:dur animations:^{
    [self.topBarViewController showMyCityView];
    [self.topBarViewController removeClanView];
  }];
  
  [self.loadingView stop];
  
  [self playMapMusic];
}

- (BOOL) miniTutorialControllerForTaskId:(int)taskId {
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *ftp = [gs taskWithId:taskId];
  MiniTutorialController *mtc = [MiniTutorialController miniTutorialForCityId:ftp.cityId assetId:ftp.assetNumWithinCity gameViewController:self];
  mtc.delegate = self;
  self.miniTutController = mtc;
  
  return mtc != nil;
}

- (void) enterDungeon:(int)taskId withDelay:(float)delay {
  if (![self miniTutorialControllerForTaskId:taskId]) {
    GameState *gs = [GameState sharedGameState];
    DungeonBattleLayer *bl = [[DungeonBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
    bl.delegate = self;
    [self performSelector:@selector(crossFadeIntoBattleLayer:) withObject:bl afterDelay:delay];
    [[OutgoingEventController sharedOutgoingEventController] beginDungeon:taskId withDelegate:bl];
  } else {
    [self.miniTutController performSelector:@selector(begin) withObject:nil afterDelay:delay];
  }
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
  [self removeAllViewControllers];
  
  [[SoundEngine sharedSoundEngine] playBattleMusic];
  _isInBattle = YES;
}

- (void) beginBattleLayer:(NewBattleLayer *)bl {
  CCDirector *dir = [CCDirector sharedDirector];
  CCScene *scene = [CCScene node];
  [scene addChild:bl];
  if (dir.runningScene) {
    [dir pushScene:scene];
  } else {
    [dir replaceScene:scene];
  }
  
  [self hideTopBarDuration:0.f completion:nil];
  [self removeAllViewControllers];
  
  [[SoundEngine sharedSoundEngine] playBattleMusic];
  _isInBattle = YES;
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
  [self removeAllViewControllers];
  
  [[SoundEngine sharedSoundEngine] playBattleMusic];
  _isInBattle = YES;
}

- (void) findPvpMatch:(BOOL)useGems {
  GameState *gs = [GameState sharedGameState];
  PvpBattleLayer *bl = [[PvpBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO];
  bl.delegate = self;
  bl.useGemsForQueue = useGems;
  
  [[OutgoingEventController sharedOutgoingEventController] queueUpEvent:nil withDelegate:bl];
  
  [self blackFadeIntoBattleLayer:bl];
}

- (void) beginPvpMatch:(PvpHistoryProto *)history {
  GameState *gs = [GameState sharedGameState];
  PvpBattleLayer *bl = [[PvpBattleLayer alloc] initWithMyUserMonsters:[gs allBattleAvailableMonstersOnTeam] puzzleIsOnLeft:NO pvpHistoryForRevenge:history];
  bl.delegate = self;
  
  [self crossFadeIntoBattleLayer:bl];
}

#pragma mark - MiniTutorial delegate

- (void) miniTutorialComplete:(MiniTutorialController *)tut {
  self.miniTutController = nil;
  
  [self performSelector:@selector(checkQuests) withObject:nil afterDelay:0.7];
  
  [self checkLevelUp];
  
  [self playMapMusic];
}

#pragma mark - BattleLayerDelegate methods

- (void) battleComplete:(NSDictionary *)params {
  float duration = 0.6;
  
  _isInBattle = NO;
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:duration]];
  
  if ([[params objectForKey:BATTLE_MANAGE_CLICKED_KEY] boolValue]) {
    MenuNavigationController *m = [[MenuNavigationController alloc] init];
    [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
    [self presentViewController:m animated:YES completion:^{
      [self showTopBarDuration:0.f completion:nil];
    }];
  } else {
    // Don't show top bar if theres a completed quest because it will just be faded out immediately
    if (self.completedQuests.count) {
      [self performSelector:@selector(checkQuests) withObject:nil afterDelay:duration+0.1];
    } else {
      [self showTopBarDuration:duration completion:^{
        [self checkQuests];
      }];
    }
  }
  
  [self playMapMusic];
}

#pragma mark - CCDirectorDownloaderDelegate methods

- (NSString *) filepathToFile:(NSString *)filename {
  return [Globals pathToFile:filename];
}

- (NSString *) downloadFile:(NSString *)filename {
  return [[Downloader sharedDownloader] syncDownloadFile:[Globals getDoubleResolutionImage:filename]];
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
  
  [self removeAllViewControllers];
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

#pragma mark - Quests and Achievements

- (void) checkQuests {
  if (self.completedQuests.count) {
    [self questComplete:self.completedQuests[0]];
  } else {
    if (self.progressedJobs.count) {
      [self jobProgress:self.progressedJobs[0]];
    }
    if (self.completedAchievement) {
      [self achievementComplete:self.completedAchievement];
    }
  }
}

- (void) achievementComplete:(AchievementProto *)ap {
  if (!_isInBattle && !self.miniTutController && !self.presentedViewController) {
    if (self.numAchievementsComplete > 1 || (self.completedAchievement && ap != self.completedAchievement)) {
      if (self.completedAchievement && ap != self.completedAchievement) {
        self.numAchievementsComplete++;
      }
      [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%d Achievements Complete! Tap on the Jobs button to collect your rewards.", self.numAchievementsComplete]];
    } else {
      [Globals addGreenAlertNotification:[NSString stringWithFormat:@"Achievement Complete! %@: Rank %d", ap.name, ap.lvl]];
    }
    self.completedAchievement = nil;
    self.numAchievementsComplete = 0;
  } else {
    self.numAchievementsComplete++;
    self.completedAchievement = ap;
  }
}

- (void) questComplete:(FullQuestProto *)fqp {
  if (!_isInBattle && !self.miniTutController && !self.presentedViewController) {
    [self hideTopBarDuration:0.3f completion:^{
      CCBReader *reader = [CCBReader reader];
      QuestCompleteLayer *questComplete = (QuestCompleteLayer *)[reader load:@"QuestCompleteLayer"];
      [[[CCDirector sharedDirector] runningScene] addChild:questComplete];
      questComplete.anchorPoint = ccp(0.5, 0.5);
      questComplete.position = ccp(questComplete.parent.contentSize.width/2, questComplete.parent.contentSize.height/2);
      [questComplete animateForQuest:fqp completion:^{
        [self checkQuests];
      }];
      reader.animationManager.delegate = questComplete;
      questComplete.delegate = self;
    }];
    [self.completedQuests removeObject:fqp];
  } else {
    [self.completedQuests addObject:fqp];
  }
}

- (void) questCompleteLayerCompleted:(QuestCompleteLayer *)questComplete withNewQuest:(FullQuestProto *)quest {
  if (quest && quest.hasAcceptDialogue) {
    [self beginDialogue:quest.acceptDialogue withQuestId:quest.questId];
  } else {
    [self showTopBarDuration:0.3f completion:nil];
  }
}

- (void) jobProgress:(QuestJobProto *)qjp {
  if (!_isInBattle && !self.miniTutController && !self.presentedViewController) {
    GameState *gs = [GameState sharedGameState];
    FullQuestProto *fqp = [gs questForId:qjp.questId];
    [self.topBarViewController displayQuestProgressViewForQuest:fqp userQuest:[gs myQuestWithId:fqp.questId] jobId:qjp.questJobId completion:^{
      [self checkQuests];
    }];
    
    [self.progressedJobs removeObject:qjp];
  } else {
    [self.progressedJobs addObject:qjp];
  }
}

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
    qvc.delegate = self;
    [self addChildViewController:qvc];
    qvc.view.frame = self.view.bounds;
    [self.view addSubview:qvc.view];
    
    GameState *gs = [GameState sharedGameState];
    FullQuestProto *fqp = [gs questForId:_questIdAfterDialogue];
    [qvc loadDetailsViewForQuest:fqp userQuest:nil animated:NO];
  }
}

- (void) questLogClosed {
  [self checkLevelUp];
}

#pragma mark - Level Up

- (void) checkLevelUp {
  if (!_isInBattle && !self.miniTutController && !self.completedQuests.count && [CCDirector sharedDirector].isAnimating) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    if (gs.level < gl.maxLevelForUser && gs.experience >= [gs expNeededForLevel:gs.level+1]) {
      [[OutgoingEventController sharedOutgoingEventController] levelUp];
      [self spawnLevelUp];
    }
  }
}

- (void) spawnLevelUp {
  LevelUpNode *levelUp = (LevelUpNode *)[CCBReader load:@"LevelUpNode"];
  [[[CCDirector sharedDirector] runningScene] addChild:levelUp];
  levelUp.position = ccp(0, 0);
}

#pragma mark - Facebook stuff

- (void) openedFromFacebook {
  MSDate *openDate = [[FacebookDelegate sharedFacebookDelegate] timeOfLastLoginAttempt];
  if (-openDate.timeIntervalSinceNow > 5*60) {
    _shouldRejectFacebook = YES;
  } else if (_isFreshRestart) {
    _shouldRejectFacebook = YES;
  } else {
    _isFromFacebook = YES;
  }
}

- (BOOL) canProceedWithFacebookId:(NSString *)facebookId {
  GameState *gs = [GameState sharedGameState];
  if (_shouldRejectFacebook) {
    _shouldRejectFacebook = NO;
    [Globals popupMessage:@"Unable to login to Facebook. Please try again!"];
    [FacebookDelegate logout];
  } else if ((!_isFromFacebook && !gs.connected) || gs.isTutorial) {
    return YES;
  } else if ([gs.facebookId isEqualToString:facebookId]) {
    return YES;
  } else if (!gs.facebookId.length) {
    [[OutgoingEventController sharedOutgoingEventController] setFacebookId:facebookId delegate:self];
  } else {
    // Logged in with different fb
    NSString *desc = [NSString stringWithFormat:@"Oops! This Facebook account is different from the one linked to this player. Would you like to reload the game?"];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Account Already Set" okayButton:@"Reload" cancelButton:@"Cancel" okTarget:self okSelector:@selector(swapAccounts) cancelTarget:self cancelSelector:@selector(swapRejected)];
  }
  return NO;
}

- (void) handleSetFacebookIdResponseProto:(FullEvent *)fe {
  SetFacebookIdResponseProto *proto = (SetFacebookIdResponseProto *)fe.event;
  if (proto.status == SetFacebookIdResponseProto_SetFacebookIdStatusFailFbIdExists) {
    NSString *desc = [NSString stringWithFormat:@"Oops! This Facebook account is already linked to another player (%@). Would you like to load that account now?", proto.existing.name];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Account Already Used" okayButton:@"Load" cancelButton:@"Cancel" okTarget:self okSelector:@selector(swapAccounts) cancelTarget:self cancelSelector:@selector(swapRejected)];
  } else if (proto.status == SetFacebookIdResponseProto_SetFacebookIdStatusSuccess) {
    [FacebookDelegate facebookIdIsValid];
  } else {
    [FacebookDelegate logout];
  }
}

- (void) swapAccounts {
  _isFreshRestart = YES;
  self.currentMap = nil;
  [self fadeToLoadingScreenPercentage:0.f animated:YES];
  [self progressTo:PART_1_PERCENT animated:YES];
  [self handleConnectedToHost];
}

- (void) swapRejected {
  [FacebookDelegate logout];
}

@end
