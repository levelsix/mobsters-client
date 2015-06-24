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
#import "ProfileViews.h"

@interface ProfileMonsterBar : ButtonTabBar

@property (nonatomic, retain) IBOutlet UIButton *button1;
@property (nonatomic, retain) IBOutlet UIButton *button2;
@property (nonatomic, retain) IBOutlet UIButton *button3;

@end

@interface ProfileViewController : UIViewController <TabBarDelegate>

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *bgdView;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *avatarIcon;
@property (nonatomic, strong) IBOutlet UIImageView *avatarBgd;

@property (nonatomic, strong) IBOutlet ProfileMonsterBar *monsterBar;
@property (nonatomic, strong) IBOutlet ButtonTabBar *navBar;

@property (nonatomic, strong) IBOutlet ProfileStatsView *statsView;
@property (nonatomic, strong) IBOutlet UIView *teamView;
@property (nonatomic, strong) IBOutlet UILabel *slotEmptyView;

@property (nonatomic, strong) IBOutletCollection(ProfileMonsterTeamView) NSArray *monsterTeamViews;
@property (nonatomic, strong) IBOutlet ProfileMonsterDescriptionView *monsterDescriptionView;

@property (nonatomic, strong) FullUserProto *fup;
@property (nonatomic, copy) NSArray *curTeam;
@property (nonatomic, strong) ResearchUtil *researchUtil;

- (id)initWithUserUuid:(NSString *)userUuid;
- (id)initWithFullUserProto:(FullUserProto *)fup andCurrentTeam:(NSArray *)curTeam;
- (IBAction)message:(id)sender;
- (IBAction)close:(id)sender;

@end
