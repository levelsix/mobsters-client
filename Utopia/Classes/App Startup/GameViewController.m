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
#import "GameLayer.h"
#import "GameState.h"
#import "GameState.h"
#import "Globals.h"
#import "GenericPopupController.h"
#import "GameLayer.h"
#import "HomeMap.h"
#import "MissionMap.h"
#import "SoundEngine.h"
#import "GameLayer.h"
#import "NewBattleLayer.h"
#import "LoadingViewController.h"
#import "SocketCommunication.h"
#import "OutgoingEventController.h"
#import "TopBarViewController.h"
#import "AppDelegate.h"
#import "DungeonBattleLayer.h"

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
                                 depthFormat:0
                          preserveBackbuffer:NO
                                  sharegroup:nil
                               multiSampling:NO
                             numberOfSamples:0];
  
  // Display link director is causing problems with uiscrollview and table view.
  [director setProjection:kCCDirectorProjection2D];
  [director setView:glView];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
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
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:NO];
  
  [[CCFileUtils sharedFileUtils] setiPhoneRetinaDisplaySuffix:@"@2x"];
  
  [self addChildViewController:director];
  [self.view addSubview:director.view];
}

- (void) setupTopBar {
  self.topBarViewController = [[TopBarViewController alloc] initWithNibName:@"TopBarViewController" bundle:nil];
  [self addChildViewController:self.topBarViewController];
  self.topBarViewController.view.frame = self.view.bounds;
  [self.view addSubview:self.topBarViewController.view];
}

- (void) viewDidLoad {
  [self setupTopBar];
  [self fadeToLoadingScreen];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  [[SocketCommunication sharedSocketCommunication] setDelegate:self forTag:CONNECTED_TO_HOST_DELEGATE_TAG];
  
  [self progressTo:PART_1_PERCENT];
  
  [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil];
  
  [self performSelector:@selector(handleLoadPlayerCityResponseProto:) withObject:nil afterDelay:3.f];
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
  
  if (self.presentedViewController) {
    GameState *gs = [GameState sharedGameState];
    [[OutgoingEventController sharedOutgoingEventController] loadPlayerCity:gs.userId withDelegate:self];
  }
}

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  [self progressTo:1.f];
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
  // Load the home map
  [self visitCityClicked:0];
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
      
      CCDirector *dir = [CCDirector sharedDirector];
      if (![dir runningScene]) {
        [dir pushScene:scene];
      } else {
        [[CCDirector sharedDirector] replaceScene:scene];
      }
    } else {
      [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:cityId withDelegate:self];
      
      GameState *gs = [GameState sharedGameState];
      FullCityProto *city = [gs cityWithId:cityId];
      self.loadingView.label.text = [NSString stringWithFormat:@"Traveling to %@", city.name];
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
  [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:scene]];
  
  [self.loadingView stop];
}

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  float duration = 0.6;
  
  CCScene *bl = [DungeonBattleLayer sceneWithBeginDungeonResponseProto:proto delegate:self];
  [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:duration scene:bl]];
  
  [UIView animateWithDuration:duration/2.f+0.1 animations:^{
    self.topBarViewController.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.topBarViewController.view.hidden = YES;
  }];
}

#pragma mark - BattleLayerDelegate methods

- (void) battleComplete {
  float duration = 0.6;
  
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionCrossFade class] duration:duration];
  
  self.topBarViewController.view.hidden = NO;
  [UIView animateWithDuration:duration/2.f+0.1 animations:^{
    self.topBarViewController.view.alpha = 1.f;
  }];
}

@end
