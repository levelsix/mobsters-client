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

@interface GameViewController : UIViewController <AttackMapDelegate, BattleLayerDelegate>

@property (nonatomic, strong) TopBarViewController *topBarViewController;
@property (nonatomic, strong) GameMap *currentMap;

@property (nonatomic, strong) IBOutlet TravelingLoadingView *loadingView;

+ (id) baseController;

- (void) handleConnectedToHost;

- (void) buildingPurchased:(int)structId;
- (void) enterDungeon:(int)taskId withDelay:(float)delay;

- (void) openPrivateChatWithUserUuid:(NSString *)userUuid;

- (void) openGemShop;

@end
