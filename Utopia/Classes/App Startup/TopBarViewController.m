//
//  TopBarViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TopBarViewController.h"
#import "cocos2d.h"
#import "MainMenuController.h"
#import "Globals.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"
#import "DiamondShopViewController.h"
#import "AttackMapViewController.h"
#import "GameState.h"
#import "ProfileViewController.h"
#import "QuestLogViewController.h"
#import "MyCroniesViewController.h"
#import "RequestsViewController.h"
#import "DialogueViewController.h"

@implementation SplitImageProgressBar

- (void) setPercentage:(float)percentage {
  _percentage = clampf(percentage, 0.f, 1.f);
  
  float totalWidth = (int)roundf(_percentage*self.frame.size.width);
  CGRect r;
  
  r = self.leftCap.frame;
  r.size.width = MIN(ceilf(totalWidth/2), self.leftCap.image.size.width);
  self.leftCap.frame = r;
  
  r = self.rightCap.frame;
  r.size.width = self.leftCap.frame.size.width;
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.origin.x = totalWidth-r.size.width;
  } else {
    r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  }
  self.rightCap.frame = r;
  
  r = self.middleBar.frame;
  r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.size.width = self.rightCap.frame.origin.x-r.origin.x;
  } else {
    r.size.width = 0;
  }
  self.middleBar.frame = r;
  
  if (self.isRightToLeft) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
  } else {
    self.transform = CGAffineTransformIdentity;
  }
}

@end

@implementation TopBarMonsterView

- (void) awakeFromNib {
  self.iconView.transform = CGAffineTransformMakeScale(0.55, 0.55);
}

- (void) updateForUserMonster:(UserMonster *)um {
  if (!um) {
    self.bgdIcon.image = [Globals imageNamed:@"teamempty.png"];
    self.monsterIcon.image = nil;
    self.topLabel.text = @"Slot Empty";
    self.botLabel.hidden = YES;
    self.healthBarView.hidden = YES;
  } else {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    self.healthBar.image = [Globals imageNamed:@"earthhteambar.png"];
    self.healthBar.percentage = ((float)um.curHealth)/[gl calculateMaxHealthForMonster:um];
    
    BOOL greyscale = (um.curHealth <= 0);
    NSString *file = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:file withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    file = [Globals imageNameForElement:mp.monsterElement suffix:@"mteam.png"];
    [Globals imageNamed:file withView:self.bgdIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.topLabel.text = mp.displayName;
    
    if ([um isHealing]) {
      self.botLabel.hidden = NO;
      self.healthBarView.hidden = YES;
      
      self.iconView.alpha = 0.5;
    } else {
      self.botLabel.hidden = YES;
      self.healthBarView.hidden = NO;
      
      self.iconView.alpha = 1;
    }
  }
}

@end

@implementation TopBarViewController

- (void) viewDidLoad {
  _originalProgressCenter = self.questProgressView.center;
  
  for (UIView *container in self.topBarMonsterViewContainers) {
    container.backgroundColor = [UIColor clearColor];
    
    [[NSBundle mainBundle] loadNibNamed:@"TopBarMonsterView" owner:self options:nil];
    [container addSubview:self.topBarMonsterView];
    self.topBarMonsterView.center = ccp(container.frame.size.width/2, container.frame.size.height/2);
  }
  
  self.chatViewController = [[ChatViewController alloc] init];
  [self addChildViewController:self.chatViewController];
  [self.view addSubview:self.chatViewController.view];
  [self.chatViewController closeAnimated:NO];
  
  self.myCityView.hidden = YES;
  
  self.cashBar.isRightToLeft = YES;
  self.oilBar.isRightToLeft = YES;
  
  if (![Globals isLongiPhone]) {
    UIImage *img = [Globals imageNamed:@"levelxpbg.png"];
    int diff = self.expBgd.image.size.width-img.size.width;
    self.expBgd.image = img;
    self.oilBgd.image = img;
    self.cashBgd.image = img;
    
    CGRect r = self.expBgd.superview.frame;
    r.size.width -= diff;
    self.expBgd.superview.frame = r;
    
    r = self.oilBgd.superview.frame;
    r.origin.x += diff;
    r.size.width -= diff;
    self.oilBgd.superview.frame = r;
    
    r = self.cashBgd.superview.frame;
    r.origin.x += diff;
    r.size.width -= diff;
    self.cashBgd.superview.frame = r;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStateUpdated) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self gameStateUpdated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMonsterViews) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [self updateMonsterViews];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMailBadge) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMailBadge) name:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [self updateMailBadge];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQuestBadge) name:QUESTS_CHANGED_NOTIFICATION object:nil];
  [self updateQuestBadge];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) showMyCityView {
  self.myCityView.hidden = NO;
}

- (void) removeMyCityView {
  self.myCityView.hidden = YES;
}

- (void) updateMailBadge {
  GameState *gs = [GameState sharedGameState];
  self.mailBadge.badgeNum = gs.fbUnacceptedRequestsFromFriends.count;
}

- (void) updateQuestBadge {
  GameState *gs = [GameState sharedGameState];
  int badgeNum = 0;
  badgeNum += gs.availableQuests.count;
  badgeNum += gs.inProgressCompleteQuests.count;
  
  for (FullQuestProto *q in gs.inProgressIncompleteQuests.allValues) {
    if (q.questType == FullQuestProto_QuestTypeDonateMonster) {
      UserQuest *uq = [gs myQuestWithId:q.questId];
      if (q.quantity == uq.progress) {
        badgeNum++;
      }
    }
  }
  
  self.questBadge.badgeNum = badgeNum;
}

- (void) displayQuestProgressView {
  [self.questProgressView.layer removeAllAnimations];
  self.questProgressView.center = _originalProgressCenter;
  [UIView animateWithDuration:0.3f animations:^{
    self.questProgressView.alpha = 1.f;
  } completion:^(BOOL finished) {
    if (finished) {
      [UIView animateWithDuration:0.3f delay:4.f options:UIViewAnimationOptionTransitionNone animations:^{
        self.questProgressView.alpha = 0.f;
      } completion:^(BOOL finished) {
        [self.questProgressView.layer removeAllAnimations];
      }];
    }
  }];
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:0.7 delay:0.f options:opt animations:^{
    self.questProgressView.center = CGPointMake(self.questProgressView.center.x+14, self.questProgressView.center.y);
  } completion:nil];
}

#pragma mark - Bottom view methods

- (void) replaceChatViewWithView:(MapBotView *)view {
  if (self.curViewOverChatView) {
    MapBotView *v = self.curViewOverChatView;
    [v animateOut:^{
      [v removeFromSuperview];
      if (self.curViewOverChatView == v) {
        self.curViewOverChatView = nil;
        [self addNewView:view];
      }
    }];
  } else {
    [self addNewView:view];
  }
}

- (void) addNewView:(MapBotView *)view {
  self.curViewOverChatView = view;
  [self.view insertSubview:self.curViewOverChatView atIndex:0];
  self.curViewOverChatView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-view.frame.size.height/2);
  [view animateIn:nil];
}

- (void) removeViewOverChatView {
  MapBotView *v = self.curViewOverChatView;
  [v animateOut:^{
    [v removeFromSuperview];
    if (self.curViewOverChatView == v) {
      self.curViewOverChatView = nil;
    }
  }];
}

#pragma mark - IBActions

- (IBAction)menuClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MainMenuController alloc] init] animated:YES];
}

- (IBAction)attackClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  AttackMapViewController *amvc = [[AttackMapViewController alloc] init];
  amvc.delegate = gvc;
  MenuNavigationController *nav = [[MenuNavigationController alloc] init];
  nav.navigationBarHidden = YES;
  [gvc presentViewController:nav animated:YES completion:nil];
  [nav pushViewController:amvc animated:YES];
}

- (IBAction)plusClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[DiamondShopViewController alloc] init] animated:NO];
}

- (IBAction)profileClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithFullUserProto:[gs convertToFullUserProto] andCurrentTeam:[gs allMonstersOnMyTeam]];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (IBAction)questsClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  QuestLogViewController *qvc = [[QuestLogViewController alloc] init];
  [gvc addChildViewController:qvc];
  qvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:qvc.view];
}

- (IBAction)myCityClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc visitCityClicked:0];
}

- (IBAction)monsterViewsClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
}

- (IBAction)mailClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  RequestsViewController *rvc = [[RequestsViewController alloc] init];
  [gvc addChildViewController:rvc];
  rvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:rvc.view];
  
  [self updateMailBadge];
}

#pragma mark - Updating HUD Stuff

- (void) gameStateUpdated {
  GameState *gs = [GameState sharedGameState];
  [self.cashLabel transitionToNum:gs.silver];
  [self.oilLabel transitionToNum:gs.oil];
  [self.gemsLabel transitionToNum:gs.gold];
  
  if (self.expLabel.currentNum <= gs.currentExpForLevel) {
    [self.expLabel transitionToNum:gs.currentExpForLevel];
  } else {
    [self.expLabel instaMoveToNum:gs.currentExpForLevel];
  }
  
  self.levelLabel.text = [Globals commafyNumber:gs.level];
  
  self.cashMaxLabel.text = [NSString stringWithFormat:@"MAX: %@", [Globals cashStringForNumber:[gs maxCash]]];
  self.oilMaxLabel.text = [NSString stringWithFormat:@"MAX: %@", [Globals commafyNumber:[gs maxOil]]];
}

- (void) updateMonsterViews {
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < self.topBarMonsterViewContainers.count; i++) {
    UserMonster *um = [gs myMonsterWithSlotNumber:i+1];
    UIView *container = [self.topBarMonsterViewContainers objectAtIndex:i];
    TopBarMonsterView *mv = (TopBarMonsterView *)[[container subviews] lastObject];
    [mv updateForUserMonster:um];
  }
}

#pragma mark NumTransitionLabelDelegate methods

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number {
  GameState *gs = [GameState sharedGameState];
  if (label == self.expLabel) {
    label.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:number], [Globals commafyNumber:gs.expDeltaNeededForNextLevel]];
    self.expBar.percentage = number/(float)gs.expDeltaNeededForNextLevel;
  } else if (label == self.cashLabel) {
    label.text = [Globals cashStringForNumber:number];
    self.cashBar.percentage = number/(float)gs.maxCash;
  } else if (label == self.oilLabel) {
    label.text = [Globals commafyNumber:number];
    self.oilBar.percentage = number/(float)gs.maxOil;
  } else if (label == self.gemsLabel) {
    label.text = [Globals commafyNumber:number];
  }
}

@end
