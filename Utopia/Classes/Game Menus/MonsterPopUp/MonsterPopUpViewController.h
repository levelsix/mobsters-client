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

- (void) updateStatsWithElementType:(MonsterProto_MonsterElement)element andDamage:(int)damage;

@end

@interface MonsterPopUpViewController : UIViewController

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

@property (nonatomic, strong) IBOutlet UILabel *monsterNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *hpLabel;
@property (nonatomic, strong) IBOutlet UILabel *rarityLabel;
@property (nonatomic, strong) IBOutlet UILabel *attackLabel;
@property (nonatomic, strong) IBOutlet UILabel *enhanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *monsterDescription;

@property (nonatomic, strong) IBOutlet UIImageView *monsterImageView;
@property (nonatomic, strong) IBOutlet UIImageView *elementType;

@property (nonatomic, strong) IBOutlet ProgressBar *progressBar;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;


@property (nonatomic, strong) UserMonster *monster;

- (id)initWithMonsterProto:(UserMonster *)monster;
- (IBAction)infoClicked:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)backClicked:(id)sender;

@end
