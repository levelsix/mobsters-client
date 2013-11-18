//
//  ProfileViewController.m
//  Utopia
//
//  Created by Danny on 10/17/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ProfileViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "GameViewController.h"
#import "MonsterPopUpViewController.h"
#import "ClanViewController.h"
#import "MenuNavigationController.h"
#import "OutgoingEventController.h"

@implementation ProfileViewController

- (id)initWithUserId:(int)userId {
  if ((self = [super init])) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveUsersForUserIds:[NSArray arrayWithObject:@(userId)] includeCurMonsterTeam:YES delegate:self];
  }
  return self;
}

- (id)initWithFullUserProto:(FullUserProto *)fup andCurrentTeam:(NSArray *)curTeam {
  if ((self = [super init])) {
    self.fup = fup;
    self.curTeam = curTeam;
  }
  return self;
}

- (void) handleRetrieveUsersForUserIdsResponseProto:(FullEvent *)fe {
  RetrieveUsersForUserIdsResponseProto *proto = (RetrieveUsersForUserIdsResponseProto *)fe.event;
  self.fup = [proto.requestedUsersList lastObject];
  self.curTeam = [[Globals convertUserTeamArrayToDictionary:proto.curTeamList] objectForKey:@(self.fup.userId)];
  [self loadProfile];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadProfile];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.monsterSlotOne.monsterCardView.delegate = self;
  self.monsterSlotTwo.monsterCardView.delegate = self;
  self.monsterSlotThree.monsterCardView.delegate = self;
}

- (void)loadProfile {
  self.winsLabel.text = [NSString stringWithFormat:@"%d wins", self.fup.battlesWon];
  self.lossesLabel.text = [NSString stringWithFormat:@"%d wins", self.fup.battlesLost];
  self.nameLabel.text = self.fup ? [NSString stringWithFormat:@"%@ (LVL %d)", self.fup.name,self.fup.level] : @"Loading...";
  
  if (self.fup.hasClan) {
    self.clanView.label.textColor = [Globals goldColor];
    [self.clanView setString:self.fup.clan.name isEnabled:YES];
  } else {
    self.clanView.label.textColor = [UIColor whiteColor];
    [self.clanView setString:@"No Clan" isEnabled:NO];
  }
  
  [self.monsterSlotOne.monsterCardView updateForNoMonsterWithLabel:@"Team Slot Empty"];
  [self.monsterSlotTwo.monsterCardView updateForNoMonsterWithLabel:@"Team Slot Empty"];
  [self.monsterSlotThree.monsterCardView updateForNoMonsterWithLabel:@"Team Slot Empty"];
  for (UserMonster *um in self.curTeam) {
    if (um.teamSlot == 1) {
      [self.monsterSlotOne.monsterCardView updateForMonster:um];
    } else if (um.teamSlot == 2) {
      [self.monsterSlotTwo.monsterCardView updateForMonster:um];
    } else if (um.teamSlot == 3) {
      [self.monsterSlotThree.monsterCardView updateForMonster:um];
    }
  }
}

- (void) infoClicked:(MonsterCardView *)view {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:view.monster];
  [self addChildViewController:mpvc];
  [self.view addSubview:mpvc.view];
}

- (void) labelClicked:(UnderlinedLabelView *)label {
  // Go visit clan
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[ClanInfoViewController alloc] initWithClanId:self.fup.clan.clanId andName:self.fup.clan.name] animated:NO];
  
  [self close:nil];
}

- (IBAction)message:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openPrivateChatWithUserId:self.fup.userId];
  
  [self close:nil];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
