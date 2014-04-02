//
//  ProfileViewController.h
//  Utopia
//
//  Created by Danny on 10/17/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "MonsterCardView.h"

@interface ProfileViewController : UIViewController <MonsterCardViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *bgdView;

@property (nonatomic, strong) IBOutlet UILabel *winsLabel;
@property (nonatomic, strong) IBOutlet UILabel *lossesLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotOne;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotTwo;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotThree;
@property (nonatomic, strong) IBOutlet UIButton *clanButton;
@property (nonatomic, strong) IBOutlet UIImageView *shieldIcon;

@property (nonatomic, strong) IBOutlet UIView *leagueView;
@property (nonatomic, strong) IBOutlet UIImageView *leagueBgd;
@property (nonatomic, strong) IBOutlet UIImageView *leagueIcon;
@property (nonatomic, strong) IBOutlet UILabel *leagueLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankQualifierLabel;
@property (nonatomic, strong) IBOutlet UILabel *placeLabel;

@property (nonatomic, strong) FullUserProto *fup;
@property (nonatomic, copy) NSArray *curTeam;

- (id)initWithUserId:(int)userId;
- (id)initWithFullUserProto:(FullUserProto *)fup andCurrentTeam:(NSArray *)curTeam;
- (IBAction)message:(id)sender;
- (IBAction)close:(id)sender;

@end
