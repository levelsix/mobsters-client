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
@property (nonatomic, assign) IBOutlet UIView *editMemberView;
@property (nonatomic, assign) IBOutlet UIView *respondInviteView;

@property (nonatomic, retain) MinimumUserProtoForClans *user;

@end

@interface ClanInfoCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *membersLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UILabel *foundedLabel;
@property (nonatomic, assign) IBOutlet UITextView *descriptionView;
@property (nonatomic, assign) IBOutlet UIButton *buttonOverlay;

@property (nonatomic, retain) IBOutlet UIView *requestView;
@property (nonatomic, retain) IBOutlet UIView *cancelView;
@property (nonatomic, retain) IBOutlet UIView *leaveView;
@property (nonatomic, retain) IBOutlet UIView *joinView;
@property (nonatomic, retain) IBOutlet UIView *leaderView;
@property (nonatomic, retain) IBOutlet UIView *anotherClanView;

@end

@interface ClanInfoViewController : GenViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet ClanInfoCell *infoCell;
@property (nonatomic, assign) IBOutlet ClanMemberCell *memberCell;
@property (nonatomic, assign) IBOutlet UITableView *infoTable;
@property (nonatomic, assign) IBOutlet UIView *loadingMembersView;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;
@property (nonatomic, retain) NSArray *members;
@property (nonatomic, retain) NSArray *requesters;

- (id) initWithClan:(FullClanProtoWithClanSize *)clan;
- (void) loadForMyClan;

- (IBAction)joinClicked:(id)sender;
- (IBAction)requestClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)leaveClicked:(id)sender;
- (IBAction)editClicked:(id)sender;

@end
