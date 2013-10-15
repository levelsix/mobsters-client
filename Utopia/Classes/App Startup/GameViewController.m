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
#import "SoundEngine.h"
#import "GameLayer.h"
#import "NewBattleLayer.h"
#import "LoadingViewController.h"
#import "SocketCommunication.h"
#import "OutgoingEventController.h"
#import "TopBarViewController.h"

#define DEFAULT_PNG_IMAGE_VIEW_TAG 103
#define KINGDOM_PNG_IMAGE_VIEW_TAG 104

#define PART_0_PERCENT 0.f
#define PART_1_PERCENT 0.05f
#define PART_2_PERCENT 0.85f
#define PART_3_PERCENT 1.f

@implementation GameViewController

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGSize size = rect.size;
  rect.size = CGSizeMake(rect.size.height, rect.size.width);
  rect.origin = CGPointMake((size.height-rect.size.width)/2, (size.width-rect.size.height)/2);
  UIView *v = [[UIView alloc] initWithFrame:rect];
  v.backgroundColor = [UIColor blackColor];
  
  self.view = v;
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
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
  
  [[CCFileUtils sharedFileUtils] setiPhoneRetinaDisplaySuffix:@"@2x"];
  
  [self addChildViewController:director];
  [self.view addSubview:director.view];
}

- (void) setupTopBar {
  self.topBarViewController = [[TopBarViewController alloc] init];
  [self addChildViewController:self.topBarViewController];
  self.topBarViewController.view.frame = self.view.bounds;
  [self.view addSubview:self.topBarViewController.view];
}

- (void) viewDidLoad {
  [self setupCocos2D];
  [self setupTopBar];
  [self fadeToLoadingScreen];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  [[SocketCommunication sharedSocketCommunication] setDelegate:self forTag:CONNECTED_TO_HOST_DELEGATE_TAG];
  
  [self progressTo:PART_1_PERCENT];
  
  [self performSelector:@selector(handleLoadPlayerCityResponseProto:) withObject:nil afterDelay:3.f];
}

- (void) fadeToLoadingScreen {
  LoadingViewController *lvc = [[LoadingViewController alloc] init];
  [self presentViewController:lvc animated:NO completion:nil];
}

- (void) progressTo:(float)t {
  LoadingViewController *lvc = (LoadingViewController *)self.presentedViewController;
  [lvc progressToPercentage:t];
}

- (void) handleConnectedToHost {
  [self progressTo:PART_2_PERCENT];
  [[OutgoingEventController sharedOutgoingEventController] startupWithDelegate:self];
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  [self progressTo:PART_3_PERCENT];
  
  GameState *gs = [GameState sharedGameState];
  [[OutgoingEventController sharedOutgoingEventController] loadPlayerCity:gs.userId withDelegate:self];
}

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  [self progressTo:1.f];
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
  CCScene *scene = [CCScene node];
  HomeMap *hm = [HomeMap node];
  [hm refresh];
  [scene addChild:hm];
  [hm moveToCenterAnimated:NO];
  [[CCDirector sharedDirector] pushScene:scene];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

@end
