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
  
  // Prevent closing button
  self.bgdView.userInteractionEnabled = NO;
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView completion:^(BOOL finished) {
    self.bgdView.userInteractionEnabled = YES;
  }];
  
  self.monsterSlotOne.monsterCardView.delegate = self;
  self.monsterSlotTwo.monsterCardView.delegate = self;
  self.monsterSlotThree.monsterCardView.delegate = self;
}

- (void)loadProfile {
  GameState *gs = [GameState sharedGameState];
  
  self.winsLabel.text = [Globals commafyNumber:self.fup.attacksWon+self.fup.defensesWon];
  self.lossesLabel.text = [Globals commafyNumber:self.fup.attacksLost+self.fup.defensesLost];
  self.nameLabel.text = self.fup ? [NSString stringWithFormat:@"%@ (LVL %d)", self.fup.name,self.fup.level] : @"Loading...";
  
  if (self.fup.hasClan) {
    [self.clanButton setTitle:self.fup.clan.name forState:UIControlStateNormal];
    self.clanButton.enabled = YES;
    
    self.shieldIcon.hidden = NO;
    ClanIconProto *icon = [gs clanIconWithId:self.fup.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.shieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    CGRect r = self.clanButton.frame;
    r.origin.x = self.shieldIcon.frame.size.width+3;
    self.clanButton.frame = r;
  } else {
    self.clanButton.enabled = NO;
    self.shieldIcon.hidden = YES;
    
    CGRect r = self.clanButton.frame;
    r.origin.x = 0;
    self.clanButton.frame = r;
  }
  
  [Globals adjustViewForCentering:self.clanButton.superview withLabel:self.clanButton.titleLabel];
  
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
  
  [self updateForLeague];
}

- (void) updateForLeague {
  NSMutableArray *leagues = [NSMutableArray arrayWithArray:@[@"bronze", @"silver", @"gold", @"diamond", @"platinum", @"champion"]];
  [leagues shuffle];
  NSString *league = leagues[0];
  int rank = arc4random()%2 ? arc4random()%9+1 : arc4random()%2 ? arc4random()%1000+1 : arc4random()%100+1;
  [Globals imageNamed:[league stringByAppendingString:@"leaguebg.png"] withView:self.leagueBgd greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  [Globals imageNamed:[league stringByAppendingString:@"icon.png"] withView:self.leagueIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  self.leagueLabel.text = [NSString stringWithFormat:@"%@ League", league.capitalizedString];
  self.rankLabel.text = [Globals commafyNumber:rank];
  self.rankQualifierLabel.text = [Globals qualifierStringForNumber:rank];
  
  CGSize size = [self.rankLabel.text sizeWithFont:self.rankLabel.font constrainedToSize:self.rankLabel.frame.size];
  float leftSide = CGRectGetMaxX(self.rankLabel.frame)-size.width;
  size = [self.placeLabel.text sizeWithFont:self.placeLabel.font];
  float rightSide = CGRectGetMinX(self.placeLabel.frame)+size.width;
  float midX = leftSide+(rightSide-leftSide)/2;
  
  float distFromCenter = midX-self.rankLabel.superview.frame.size.width/2;
  CGPoint curCenter = self.rankLabel.superview.center;
  self.rankLabel.superview.center = ccp(curCenter.x-distFromCenter, curCenter.y);
}

- (void) infoClicked:(MonsterCardView *)view {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:view.monster];
  [self addChildViewController:mpvc];
  mpvc.view.frame = self.view.frame;
  [self.view addSubview:mpvc.view];
}

- (IBAction)clanClicked:(id)sender {
  // Go visit clan
  UIViewController *gvc = (UIViewController *)self.parentViewController;
  
  GameState *gs = [GameState sharedGameState];
  MinimumClanProto *clan = self.fup.clan;
  ClanInfoViewController *cvc = nil;
  if (gs.clan.clanId == clan.clanId) {
    cvc = [[ClanInfoViewController alloc] init];
    [cvc loadForMyClan];
  } else {
    cvc = [[ClanInfoViewController alloc] initWithClanId:clan.clanId andName:clan.name];
  }
  
  // Call close first so that the block will retain this controller
  [self close:nil];
  if (!gvc.presentingViewController) {
    MenuNavigationController *m = [[MenuNavigationController alloc] init];
    [gvc presentViewController:m animated:YES completion:nil];
    [m pushViewController:cvc animated:NO];
  } else {
    UINavigationController *nav = self.navigationController;
    [self removeFromParentViewController];
    [nav pushViewController:cvc animated:YES];
  }
}

- (IBAction)message:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openPrivateChatWithUserId:self.fup.userId];
  
  // Will close automatically
  // [self close:nil];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
