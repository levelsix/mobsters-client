//
//  ClanInfoViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonsterCardView.h"
#import "Protocols.pb.h"

@interface ClanMemberCell : UITableViewCell

@property (nonatomic, assign) IBOutlet CircleMonsterView *userIcon;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet UILabel *raidContributionLabel;
@property (nonatomic, assign) IBOutlet UILabel *battleWinsLabel;

@property (nonatomic, assign) IBOutlet UIView *profileView;
@property (nonatomic, assign) IBOutlet UIView *editMemberView;

@property (nonatomic, retain) IBOutletCollection(MiniMonsterView) NSArray *monsterViews;

@property (nonatomic, retain) MinimumUserProtoForClans *user;

- (void) loadForUser:(MinimumUserProtoForClans *)mup currentTeam:(NSArray *)currentTeam myStatus:(UserClanStatus)myStatus;

@end

@interface ClanInfoView : UIView {
  CGFloat _baseHeight;
}

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *membersLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UILabel *foundedLabel;
@property (nonatomic, assign) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;
@property (nonatomic, retain) IBOutlet UIImageView *gradientView;

@property (nonatomic, retain) IBOutlet UIView *requestView;
@property (nonatomic, retain) IBOutlet UIView *cancelView;
@property (nonatomic, retain) IBOutlet UIView *leaveView;
@property (nonatomic, retain) IBOutlet UIView *joinView;
@property (nonatomic, retain) IBOutlet UIView *leaderView;
@property (nonatomic, retain) IBOutlet UIView *anotherClanView;

- (void) loadForClan:(FullClanProtoWithClanSize *)c clanStatus:(UserClanStatus)clanStatus;

- (void) beginSpinners;
- (void) stopAllSpinners;

@end

@class ClanInfoSettingsButtonView;

typedef enum {
  ClanSettingTransferLeader = 1,
  ClanSettingPromoteToJrLeader,
  ClanSettingPromoteToCaptain,
  ClanSettingDemoteToCaptain,
  ClanSettingDemoteToMember,
  ClanSettingBoot,
  ClanSettingAcceptMember,
  ClanSettingRejectMember,
} ClanSetting;

@protocol ClanInfoSettingsDelegate

- (void) settingClicked:(ClanInfoSettingsButtonView *)button;

@end

@interface ClanInfoSettingsButtonView : UIView

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, assign) ClanSetting setting;

@property (nonatomic, assign) IBOutlet id<ClanInfoSettingsDelegate> delegate;

- (void) updateForSetting:(ClanSetting)setting;

- (IBAction) buttonClicked:(id)sender;

- (void) beginSpinning;
- (void) stopSpinning;

@end