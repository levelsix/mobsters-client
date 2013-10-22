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

@interface ProfileViewController : UIViewController <UnderlinedLabelDelegate>

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIImageView *bgdView;

@property (nonatomic, strong) IBOutlet UILabel *winsLabel;
@property (nonatomic, strong) IBOutlet UILabel *lossesLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UnderlinedLabelView *clanView;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotOne;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotTwo;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *monsterSlotThree;

@property (nonatomic, strong) FullUserProto *fup;
@property (nonatomic, copy) NSArray *curTeam;

- (id)initWithFullUserProto:(FullUserProto *)fup andCurrentTeam:(NSArray *)curTeam;
- (IBAction)message:(id)sender;
- (IBAction)close:(id)sender;

@end
