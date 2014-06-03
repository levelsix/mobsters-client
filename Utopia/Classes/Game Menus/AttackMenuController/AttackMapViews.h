//
//  AttackMapViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface AttackMapIconView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *cityNameIcon;
@property (nonatomic, strong) IBOutlet THLabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIButton *cityButton;
@property (nonatomic, strong) IBOutlet UILabel *cityNumLabel;
@property (nonatomic, strong) IBOutlet UIImageView *shadowIcon;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, strong) FullCityProto *fcp;
@property (nonatomic, assign) int cityNumber;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

- (void) doShake;

@end

@protocol AttackEventViewDelegate <NSObject>

- (void) eventViewSelected:(id)eventView;

@end

@interface AttackEventView : TouchableSubviewsView {
  int _persistentEventId;
  PersistentEventProto_EventType _eventType;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *monsterImage;
@property (nonatomic, retain) IBOutlet UIImageView *enhanceBubbleImage;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *cooldownLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupGemsLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet UIView *enterView;
@property (nonatomic, retain) IBOutlet UIView *cooldownView;

@property (nonatomic, assign) IBOutlet id<AttackEventViewDelegate> delegate;

@property (nonatomic, assign) int taskId;
@property (nonatomic, assign) int persistentEventId;

- (void) updateForEvo;
- (void) updateForEnhance;
- (void) updateLabels;

@end

@interface AttackMapIconViewContainer : UIView

@property (nonatomic, strong) IBOutlet AttackMapIconView *iconView;

@end

@interface LeaguePromotionView : UIView

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;
@property (nonatomic, retain) IBOutlet UIImageView *oldLeagueIcon;
@property (nonatomic, retain) IBOutlet UIImageView *curLeagueIcon;
@property (nonatomic, retain) IBOutlet UIImageView *spinner;

- (void) updateForOldLeagueId:(int)oldLeagueId newLeagueId:(int)newLeagueId;
- (void) dropLeagueIcon;

@end

@interface LeagueDescriptionView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *leagueBgd;
@property (nonatomic, retain) IBOutlet UIImageView *leagueIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

- (void) updateForLeague:(PvpLeagueProto *)pvp;

@end

@interface MultiplayerView : UIView

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;
@property (nonatomic, strong) IBOutlet UILabel *cashCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *backButton;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *findMatchView;
@property (nonatomic, strong) IBOutlet UIView *rankView;

@property (nonatomic, strong) IBOutlet LeagueView *leagueView;

@property (nonatomic, strong) IBOutletCollection(LeagueDescriptionView) NSArray *leagueDescriptionViews;

- (void) updateForLeague;
- (IBAction) leagueSelected:(id)sender;
- (IBAction) backClicked:(id)sender;

@end