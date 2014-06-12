//
//  ClanInfoViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "Globals.h"

@interface ClanMemberCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *userIcon;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet UILabel *raidContributionLabel;
@property (nonatomic, assign) IBOutlet UILabel *battleWinsLabel;

@property (nonatomic, assign) IBOutlet UIView *profileView;
@property (nonatomic, assign) IBOutlet UIView *editMemberView;

@property (nonatomic, retain) IBOutletCollection(MiniMonsterView) NSArray *monsterViews;

@property (nonatomic, retain) MinimumUserProtoForClans *user;

@end

@interface ClanInfoView : UIView

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *membersLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UILabel *foundedLabel;
@property (nonatomic, assign) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;

@property (nonatomic, retain) IBOutlet UIView *requestView;
@property (nonatomic, retain) IBOutlet UIView *cancelView;
@property (nonatomic, retain) IBOutlet UIView *leaveView;
@property (nonatomic, retain) IBOutlet UIView *joinView;
@property (nonatomic, retain) IBOutlet UIView *leaderView;
@property (nonatomic, retain) IBOutlet UIView *anotherClanView;

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

- (IBAction) buttonClicked:(id)sender;

- (void) beginSpinning;
- (void) stopSpinning;

@end

typedef enum {
  ClanInfoSortOrderLevel = 1,
  ClanInfoSortOrderMember,
  ClanInfoSortOrderTeam,
  ClanInfoSortOrderRaid,
  ClanInfoSortOrderBattleWins,
} ClanInfoSortOrder;

@interface ClanInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ClanInfoSettingsDelegate> {
  ClanMemberCell *_curClickedCell;
  ClanInfoSettingsButtonView *_clickedButton;
  
  BOOL _waitingForResponse;
  BOOL _isMyClan;
}

@property (nonatomic, retain) IBOutlet ClanInfoView *infoView;
@property (nonatomic, retain) IBOutlet UIView *headerButtonsView;
@property (nonatomic, retain) IBOutlet ClanMemberCell *memberCell;
@property (nonatomic, retain) IBOutlet UITableView *infoTable;
@property (nonatomic, retain) IBOutlet UIView *loadingMembersView;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;
@property (nonatomic, retain) NSArray *allMembers;
@property (nonatomic, retain) NSArray *shownMembers;
@property (nonatomic, retain) NSMutableDictionary *curTeams;
@property (nonatomic, retain) NSArray *requesters;
@property (nonatomic, retain) MinimumUserProtoForClans *myUser;
@property (nonatomic, assign) ClanInfoSortOrder sortOrder;

@property (nonatomic, retain) IBOutlet UIView *settingsView;
@property (nonatomic, retain) IBOutlet UIImageView *settingsBgdImage;
@property (nonatomic, retain) IBOutletCollection(ClanInfoSettingsButtonView) NSArray *settingsButtons;

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *headerButtons;

- (id) initWithClanId:(int)clanId andName:(NSString *)name;
- (id) initWithClan:(FullClanProtoWithClanSize *)clan;
- (void) loadForMyClan;

- (IBAction)sortClicked:(UIView *)sender;
- (IBAction)joinClicked:(id)sender;
- (IBAction)requestClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)leaveClicked:(id)sender;
- (IBAction)editClicked:(id)sender;
- (IBAction)settingsClicked:(id)sender;

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e;

@end
