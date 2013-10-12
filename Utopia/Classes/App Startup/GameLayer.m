//
//  HelloWorldLayer.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright LVL6 2011. All rights reserved.
//

// Import the interfaces
#import "GameLayer.h"
#import "Building.h"
#import "GameMap.h"
#import "HomeMap.h"
#import "AnimatedSprite.h"
#import "Downloader.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "MissionMap.h"
#import "OutgoingEventController.h"
#import "SoundEngine.h"
#import "SocketCommunication.h"

@implementation TravelingLoadingView

@synthesize label;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) displayWithText:(NSString *)text {
  [super display:[[[CCDirector sharedDirector] view] superview]];
  self.label.text = text;
}

- (void) dealloc {
  self.label = nil;
  [super dealloc];
}

@end

@implementation WelcomeView

@synthesize nameLabel, rankLabel, middleLine;

- (void) awakeFromNib {
  self.alpha = 0.f;
}

- (void) displayForName:(NSString *)name rank:(int)rank {
  nameLabel.text = name;
  rankLabel.text = rank > 0 ? [NSString stringWithFormat:@"Rank %d", rank] : @"";
  
  self.alpha = 0.f;
  [UIView animateWithDuration:1.2f delay:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
    self.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.2f delay:1.f options:UIViewAnimationOptionTransitionNone animations:^{
      self.alpha = 0.f;
    } completion:nil];
  }];
}

- (void) dealloc {
  self.nameLabel = nil;
  self.rankLabel = nil;
  self.middleLine = nil;
  [super dealloc];
}

@end

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize assetId, currentCity;
@synthesize missionMap = _missionMap;
@synthesize welcomeView, loadingView;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameLayer);

+(CCScene *) scene
{
  // 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
  
  // 'layer' is an autorelease object.
  GameLayer *layer = [GameLayer sharedGameLayer];
  
  // add layer as a child to scene
  [scene addChild: layer];
	
	// return the scene
	return scene;
}

static BOOL shake_once = NO;

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super initWithColor:ccc4(75, 78, 29, 255)])) {
    [[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil];
    [Globals displayUIView:welcomeView];
    
    [welcomeView.superview sendSubviewToBack:welcomeView];
    [welcomeView.superview sendSubviewToBack:[[CCDirector sharedDirector] view]];
    
    [self begin];
    
//    self.isAccelerometerEnabled = YES;
    shake_once = NO;
  }
  return self;
}

- (TravelingLoadingView *)loadingView {
  if (!loadingView) {
    [[NSBundle mainBundle] loadNibNamed:@"TravelingLoadingView" owner:self options:nil];
  }
  return loadingView;
}

- (void) begin {
  if (![[GameState sharedGameState] isTutorial]) {
    [self checkHomeMapExists];
    
    [self displayHomeMap];
    
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:1];
//    [[OutgoingEventController sharedOutgoingEventController] beginDungeon:1];
  } else {
  }
}

- (void) unloadCurrentMissionMap {
  if (_missionMap) {
    _missionMap.selected = nil;
    [self removeChild:_missionMap cleanup:YES];
    self.missionMap = nil;
  }
}

- (void) loadMissionMapWithProto:(LoadCityResponseProto *)proto {
  MissionMap *m = [[MissionMap alloc] initWithProto:proto];
  GameState *gs = [GameState sharedGameState];
  FullCityProto *fcp = [gs cityWithId:proto.cityId];
  
  [self unloadCurrentMissionMap];
  [self closeHomeMap];
  
  [m moveToCenterAnimated:NO];
  
  [self addChild:m z:1];
  currentCity = proto.cityId;
  
  _missionMap = m;
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
  
  [self.loadingView stop];
  
  [welcomeView displayForName:fcp.name rank:1];
}

- (void) unloadTutorialMissionMap {
//  [[TutorialMissionMap sharedTutorialMissionMap] removeFromParentAndCleanup:YES];
//  [TutorialMissionMap purgeSingleton];
//  _missionMap = nil;
}

- (void) loadTutorialMissionMap {
//  TutorialMissionMap *map = [TutorialMissionMap sharedTutorialMissionMap];
//  currentCity = 1;
//  _missionMap = map;
//  
//  [_missionMap moveToCenterAnimated:NO];
//  [_topBar loadNormalConfiguration];
//  
//  [self addChild:_missionMap z:1];
//  
//  [self closeHomeMap];
}

- (void) checkHomeMapExists {
  if (!_homeMap) {
    _homeMap = [HomeMap sharedHomeMap];
    [self addChild:_homeMap z:1 tag:2];
    [_homeMap moveToCenterAnimated:NO];
    _homeMap.visible = NO;
  }
}

- (void) loadHomeMap {
  if (!_homeMap.visible) {
    [self.currentMap pickUpAllDrops];
    
    [self.loadingView displayWithText:@"Traveling\nHome"];
    _loading = YES;
    // Do move in load so that other classes can move it elsewhere
    [_homeMap moveToCenterAnimated:NO];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(displayHomeMap)], nil]];
  }
  
  [self checkHomeMapExists];
}

- (void) displayHomeMap {
  [self checkHomeMapExists];
  
  [self unloadCurrentMissionMap];
  [_homeMap refresh];
  
//  if (_topBar.isStarted) {
//    [_homeMap beginTimers];
//  }
  
  currentCity = 0;
//  [_topBar loadHomeConfiguration];
  _homeMap.visible = YES;
  
  if (self.isRunning) {
    [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  }
  
  if (_loading) {
    [self.loadingView stop];
    _loading = NO;
  }
  
  [welcomeView displayForName:@"My City" rank:0];
}

- (void) closeHomeMap {
  if (_homeMap) {
    _homeMap.selected = nil;
    
    [_homeMap removeFromParentAndCleanup:YES];
    [_homeMap invalidateAllTimers];
    [HomeMap purgeSingleton];
    _homeMap = nil;
    
    [[SocketCommunication sharedSocketCommunication] flush];
  }
}

- (GameMap *) currentMap {
  if (currentCity == 0) {
      return _homeMap;
  } else {
    return _missionMap;
  }
}

- (void) startHomeMapTimersIfOkay {
  if (currentCity == 0) {
    [_homeMap beginTimers];
  }
}

- (void) onEnter {
  [super onEnter];
  if (currentCity == 0) {
      [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  } else {
    [[SoundEngine sharedSoundEngine] playMissionMapMusic];
  }
}

- (void) closeMenus {
  _missionMap.selected = nil;
  _homeMap.selected = nil;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL canShake = [ud boolForKey:SHAKE_DEFAULTS_KEY];
  
  if (!canShake) {
    return;
  }
  
  float THRESHOLD = 1.3f;
  
  if (acceleration.x > THRESHOLD || acceleration.x < -THRESHOLD ||
      acceleration.y > THRESHOLD || acceleration.y < -THRESHOLD ||
      acceleration.z > THRESHOLD || acceleration.z < -THRESHOLD) {
    
    if (!shake_once) {
      if ([self.currentMap isKindOfClass:[HomeMap class]]) {
        HomeMap *hm = (HomeMap *)self.currentMap;
        [hm collectAllIncome];
      }
      shake_once = true;
    }
  }
  else {
    shake_once = false;
  }
}

- (void) dealloc {
  self.missionMap = nil;
  self.welcomeView = nil;
  self.loadingView = nil;
  [super dealloc];
}

@end
