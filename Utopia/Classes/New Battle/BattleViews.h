//
//  BattleContinueView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "RewardsView.h"
#import "NibUtils.h"
#import "UserData.h"
#import "BattlePlayer.h"

@interface BattleEndView : UIView

@property (nonatomic, retain) IBOutlet RewardsViewContainer *rewardsViewContainer;

@property (nonatomic, retain) IBOutlet UIImageView *splashImage;
@property (nonatomic, retain) IBOutlet UIImageView *splashTextImage;

@property (nonatomic, retain) IBOutlet UIImageView *lostStickerHead;

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIView *bgdView;

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *doneSpinner;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *manageSpinner;
@property (nonatomic, assign) IBOutlet UILabel *doneLabel;
@property (nonatomic, assign) IBOutlet UILabel *manageLabel;
@property (nonatomic, assign) IBOutlet UIView *buttonContainer;

- (void) displayWinWithDungeon:(BeginDungeonResponseProto *)dungeon;
- (void) displayLossWithDungeon:(BeginDungeonResponseProto *)dungeon;

@end


@interface BattleDeployCardView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet ProgressBar *healthbar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@end

@interface BattleDeployView : UIView

@property (nonatomic, retain) IBOutletCollection(BattleDeployCardView) NSArray *cardViews;

- (void) updateWithBattlePlayers:(NSArray *)players;

@end