//
//  ProfileViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonsterCardView.h"
#import "NibUtils.h"

@interface ProfileMonsterTeamView : UIView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *emptyLabel;

- (void) updateForUserMonster:(UserMonster *)um;
- (void) updateForEmptySlot:(int)slotNum;

@end

@interface ProfileMonsterDescriptionView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *elementIcon;
@property (nonatomic, retain) IBOutlet UILabel *elementLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;

- (void) updateForUserMonster:(UserMonster *)um;

@end

@interface ProfileStatsView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, strong) IBOutlet UIButton *clanButton;
@property (nonatomic, strong) IBOutlet UIImageView *shieldIcon;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) IBOutlet UILabel *winsLabel;

@property (nonatomic, strong) IBOutlet LeagueView *leagueView;

- (void) updateForUser:(FullUserProto *)user;

@end
