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

@implementation ProfileMonsterBar

- (void) awakeFromNib {
  UIView *buttonView = [[UIView alloc] initWithFrame:self.button1.frame];
  buttonView.backgroundColor = [UIColor colorWithWhite:0.975 alpha:1.f];
  UIImage *selectedImage = [Globals snapShotView:buttonView];
  
  [self.button1 setImage:selectedImage forState:UIControlStateHighlighted];
  [self.button2 setImage:selectedImage forState:UIControlStateHighlighted];
  [self.button3 setImage:selectedImage forState:UIControlStateHighlighted];
}

- (void) clickButton:(int)button {
  [super clickButton:button];
  
  UIView *view = [self viewWithTag:button];
  self.selectedView.center = ccp(view.center.x, self.selectedView.center.y);
  self.selectedView.hidden = NO;
}

@end

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
  
  // Prevent closing button
  self.bgdView.userInteractionEnabled = NO;
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView completion:^(BOOL finished) {
    self.bgdView.userInteractionEnabled = YES;
  }];
  
  self.avatarIcon.layer.cornerRadius = self.avatarIcon.frame.size.width/2;
  
  self.statsView.frame = self.teamView.frame;
  [self.teamView.superview addSubview:self.statsView];
  
  [self loadProfile];
}

- (void)loadProfile {
  GameState *gs = [GameState sharedGameState];
  
  if (!self.fup) {
    self.statsView.hidden = YES;
    self.teamView.hidden = YES;
    
    self.nameLabel.text = @"Loading...";
    self.avatarIcon.image = nil;
    self.avatarBgd.image = nil;
    
    [self.navBar clickButton:0];
  } else {
    [self.statsView updateForUser:self.fup];
    
    for (int i = 0; i < self.monsterTeamViews.count; i++) {
      ProfileMonsterTeamView *mv = self.monsterTeamViews[i];
      UserMonster *um = i < self.curTeam.count ? self.curTeam[i] : nil;
      
      if (um) {
        [mv updateForUserMonster:um];
      } else {
        [mv updateForEmptySlot:i];
      }
    }
    
    self.nameLabel.text = self.fup.name;
    
    MonsterProto *avMonster = [gs monsterWithId:self.fup.avatarMonsterId];
    NSString *file = [Globals imageNameForElement:avMonster.monsterElement suffix:@"bigavatar.png"];
    [Globals imageNamed:file withView:self.avatarBgd greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
    file = [avMonster.imagePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:file withView:self.avatarIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    [self button1Clicked:self.navBar];
    [self button1Clicked:self.monsterBar];
  }
}

- (void) infoClicked:(MonsterCardView *)view {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:view.monster];
  [self addChildViewController:mpvc];
  mpvc.view.frame = self.view.frame;
  [self.view addSubview:mpvc.view];
}

- (IBAction)clanClicked:(id)sender {
  // Go visit clan
  if (self.fup.hasClan) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc openClanViewForClanId:self.fup.clan.clanId];
    
    [self close:nil];
  }
}

- (IBAction)message:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openPrivateChatWithUserId:self.fup.userId name:self.fup.name];
  
  // Will close automatically
  // [self close:nil];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Tab Bar delegate

- (void) loadDescriptionViewForSlot:(int)slotNum {
  if (self.curTeam.count >= slotNum) {
    [self.monsterDescriptionView updateForUserMonster:self.curTeam[slotNum-1]];
  }
}

- (void) button1Clicked:(id)sender {
  if (self.fup) {
    if (sender == self.navBar) {
      self.statsView.hidden = NO;
      self.teamView.hidden = YES;
    } else if (sender == self.monsterBar) {
      [self loadDescriptionViewForSlot:1];
    }
    
    [sender clickButton:1];
  }
}

- (void) button2Clicked:(id)sender {
  if (self.fup) {
    if (sender == self.navBar) {
      self.statsView.hidden = YES;
      self.teamView.hidden = NO;
    } else if (sender == self.monsterBar) {
      [self loadDescriptionViewForSlot:2];
    }
    
    [sender clickButton:2];
  }
}

- (void) button3Clicked:(id)sender {
  if (self.fup) {
    if (sender == self.monsterBar) {
      [self loadDescriptionViewForSlot:3];
    }
    
    [sender clickButton:3];
  }
}

@end
