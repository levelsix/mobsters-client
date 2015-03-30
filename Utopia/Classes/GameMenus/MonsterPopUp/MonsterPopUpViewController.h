//
//  MonsterPopUpViewController.h
//  Utopia
//
//  Created by Danny on 10/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonsterStuff.pb.h"
#import "UserData.h"
#import "NibUtils.h"

@interface ElementDisplayView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *elementIcon;
@property (nonatomic, strong) IBOutlet UILabel *statLabel;
@property (nonatomic, strong) IBOutlet UILabel *elementLabel;

@end

@interface MonsterPopUpViewController : UIViewController {
  BOOL _allowSell;
}

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *bgdView;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutlet UIView *descriptionView;
@property (nonatomic, strong) IBOutlet UIView *backButtonView;
@property (nonatomic, strong) IBOutlet UIView *elementView;

@property (nonatomic, strong) IBOutlet ElementDisplayView *fireView;
@property (nonatomic, strong) IBOutlet ElementDisplayView *waterView;
@property (nonatomic, strong) IBOutlet ElementDisplayView *earthView;
@property (nonatomic, strong) IBOutlet ElementDisplayView *lightView;
@property (nonatomic, strong) IBOutlet ElementDisplayView *nightView;
@property (nonatomic, strong) IBOutlet ElementDisplayView *rockView;

@property (nonatomic, strong) IBOutlet UILabel *monsterNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *hpLabel;
@property (nonatomic, strong) IBOutlet UILabel *attackLabel;
@property (nonatomic, strong) IBOutlet UILabel *enhanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *elementLabel;
@property (nonatomic, strong) IBOutlet UILabel *speedLabel;
@property (nonatomic, strong) IBOutlet UILabel *powerLabel;
@property (nonatomic, strong) IBOutlet UILabel *monsterDescription;

@property (nonatomic, strong) IBOutlet UIButton *avatarButton;
@property (nonatomic, strong) IBOutlet UIButton *protectedButton;
@property (nonatomic, strong) IBOutlet UIView *buttonsContainer;

@property (nonatomic, strong) IBOutlet UIImageView *monsterImageView;
@property (nonatomic, strong) IBOutlet UIImageView *elementType;
@property (nonatomic, strong) IBOutlet UIImageView *rarityTag;

@property (nonatomic, strong) IBOutlet ProgressBar *progressBar;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;

@property (weak, nonatomic) IBOutlet UIView *skillView;
@property (weak, nonatomic) IBOutlet UIImageView *offensiveSkillBg;
@property (weak, nonatomic) IBOutlet UIImageView *offensiveSkillIcon;
@property (weak, nonatomic) IBOutlet UIImageView *defensiveSkillBg;
@property (weak, nonatomic) IBOutlet UIImageView *defensiveSkillIcon;
@property (weak, nonatomic) IBOutlet UIImageView *offensiveSkillArrow;
@property (weak, nonatomic) IBOutlet FlipImageView *defensiveSkillArrow;
@property (weak, nonatomic) IBOutlet NiceFontLabel8 *offensiveSkillName;
@property (weak, nonatomic) IBOutlet NiceFontLabel8 *defensiveSkillName;
@property (weak, nonatomic) IBOutlet NiceFontLabel2 *offensiveSkillType;
@property (weak, nonatomic) IBOutlet NiceFontLabel2 *defensiveSkillType;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (nonatomic, strong) UserMonster *monster;

- (id)initWithMonsterProto:(UserMonster *)monster;
- (id)initWithMonsterProto:(UserMonster *)monster allowSell:(BOOL)allowSell;
- (IBAction)infoClicked:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)sellClicked:(id)sender;
- (IBAction)heartClicked:(id)sender;

- (IBAction)offensiveSkillTapped:(id)sender;
- (IBAction)defensiveSkillTapped:(id)sender;

@end
