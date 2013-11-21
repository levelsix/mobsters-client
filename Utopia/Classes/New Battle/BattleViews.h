//
//  BattleContinueView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobstersEventProtocol.pb.h"
#import "RewardsView.h"
#import "NibUtils.h"
#import "UserData.h"
#import "BattlePlayer.h"

@interface BattleContinueView : UIView

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIView *bgdView;

- (void) display;

@end

@interface BattleEndView : UIView

@property (nonatomic, retain) IBOutlet RewardsViewContainer *rewardsViewContainer;

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIView *bgdView;

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) IBOutlet UIView *doneLabel;

- (void) displayWithDungeon:(BeginDungeonResponseProto *)dungeon;

@end


@interface BattleDeployCardView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;
@property (nonatomic, retain) IBOutlet UIImageView *grayscaleView;

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet ProgressBar *healthbar;
@property (nonatomic, retain) IBOutlet UIButton *button;

@end

@interface BattleDeployView : UIView

@property (nonatomic, retain) IBOutletCollection(BattleDeployCardView) NSArray *cardViews;

- (void) updateWithBattlePlayers:(NSArray *)players;

@end