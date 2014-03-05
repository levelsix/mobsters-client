//
//  ClanRaidViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "Protocols.pb.h"
#import "ClanInfoViewController.h"

@interface ClanRaidTeamEnterView : UIView

@property (nonatomic, retain) IBOutlet UIView *setTeamView;
@property (nonatomic, retain) IBOutlet UIView *switchToTeamView;

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet UIView *teamContainer;

@property (nonatomic, retain) IBOutlet ClanTeamMonsterView *monsterView;

- (void) updateForSetTeam:(NSArray *)team;
- (void) updateForSwitchTeam:(NSArray *)team;
- (IBAction) close;

@end

@interface ClanRaidStageCell : UIView {
  CGPoint _initialBattleButtonCenter;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *headerBgdImage;
@property (nonatomic, retain) IBOutlet UIView *prizesContainer;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;
@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *battleButtonLabel;
@property (nonatomic, retain) IBOutlet UIButton *battleButton;

@property (nonatomic, retain) IBOutlet UIView *battleButtonView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;

@property (nonatomic, retain) IBOutlet ClanTeamMonsterView *monsterView;

@property (nonatomic, retain) ClanRaidStageProto *raidStage;

- (void) updateForRaidStage:(ClanRaidStageProto *)stage raid:(ClanRaidProto *)raid raidForClan:(PersistentClanEventClanInfoProto *)raidForClan canStartRaidStage:(BOOL)canStartRaidStage;

- (void) inProgressConfiguration:(PersistentClanEventClanInfoProto *)raidForClan;

@end

@interface ClanRaidListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *titleImage;
@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *headImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet MaskedButton *maskedButton;

@property (nonatomic, retain) PersistentClanEventProto *clanEvent;

- (void) updateForEvent:(PersistentClanEventProto *)event;
- (void) updateTime;

@end
