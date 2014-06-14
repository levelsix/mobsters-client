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
#import "ClanSubViewController.h"
#import "ClanInfoViews.h"

typedef enum {
  ClanInfoSortOrderLevel = 1,
  ClanInfoSortOrderMember,
  ClanInfoSortOrderTeam,
  ClanInfoSortOrderRaid,
  ClanInfoSortOrderBattleWins,
} ClanInfoSortOrder;

@interface ClanInfoViewController : ClanSubViewController <UITableViewDataSource, UITableViewDelegate, ClanInfoSettingsDelegate> {
  ClanMemberCell *_curClickedCell;
  ClanInfoSettingsButtonView *_clickedSettingsButton;
  UIButton *_clickedHeaderButton;
  
  BOOL _waitingForResponse;
  BOOL _isMyClan;
}

@property (nonatomic, retain) IBOutlet ClanInfoView *infoView;
@property (nonatomic, retain) IBOutlet UIView *headerButtonsView;
@property (nonatomic, retain) IBOutlet ClanMemberCell *memberCell;
@property (nonatomic, retain) IBOutlet UITableView *infoTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;
@property (nonatomic, retain) NSArray *allMembers;
@property (nonatomic, retain) NSArray *shownMembers;
@property (nonatomic, retain) NSMutableDictionary *curTeams;
@property (nonatomic, retain) NSArray *requesters;
@property (nonatomic, retain) MinimumUserProtoForClans *myUser;
@property (nonatomic, assign) ClanInfoSortOrder sortOrder;

@property (nonatomic, retain) IBOutlet UIView *settingsView;
@property (nonatomic, retain) IBOutletCollection(ClanInfoSettingsButtonView) NSArray *settingsButtons;

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
