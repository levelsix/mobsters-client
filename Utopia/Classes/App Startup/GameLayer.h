//
//  HelloWorldLayer.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"

@class MaskedBar;
@class ProfilePicture;
@class GameMap;
@class HomeMap;
@class MissionMap;


@interface TravelingLoadingView : LoadingView

@property (nonatomic, retain) IBOutlet UILabel *label;

- (void) displayWithText:(NSString *)text;

@end

@interface WelcomeView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UIImageView *middleLine;

@end

// HelloWorldLayer
@interface GameLayer : CCLayerGradient
{
  float _slideVelocity;
  float _slideDirection;
  NSTimeInterval _prevTouchTime;
  
  HomeMap *_homeMap;
  MissionMap *_missionMap;
  
  ProfilePicture *_profileBgd;
  
  BOOL _loading;
}

@property (nonatomic, assign) int assetId;
@property (nonatomic, assign) int currentCity;
@property (nonatomic, retain) MissionMap *missionMap;

@property (nonatomic, retain) IBOutlet WelcomeView *welcomeView;
@property (nonatomic, retain) IBOutlet TravelingLoadingView *loadingView;

- (void) begin;
- (void) loadHomeMap;
- (void) closeHomeMap;
- (void) loadMissionMapWithProto:(LoadCityResponseProto *)proto;
- (void) closeMenus;
- (void) unloadTutorialMissionMap;
- (void) loadTutorialMissionMap;
- (GameMap *) currentMap;
- (void) startHomeMapTimersIfOkay;

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
+ (GameLayer *) sharedGameLayer;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

@end
