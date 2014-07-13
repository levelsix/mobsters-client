//
//  TopBarViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TopBarViewController.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"
#import "AttackMapViewController.h"
#import "GameState.h"
#import "ProfileViewController.h"
#import "QuestLogViewController.h"
#import "RequestsViewController.h"
#import "DialogueViewController.h"
#import "UnreadNotifications.h"
#import "MiniJobsViewController.h"
#import "ClanViewController.h"
#import "HomeViewController.h"
#import "ShopViewController.h"

@implementation TopBarMonsterView

- (void) awakeFromNib {
  self.iconView.transform = CGAffineTransformMakeScale(0.5, 0.5);
}

- (void) updateForUserMonster:(UserMonster *)um {
  if (!um) {
    [self.monsterView updateForMonsterId:0];
    self.topLabel.text = @"Slot Empty";
    self.botLabel.hidden = YES;
    self.healthBarView.hidden = YES;
  } else {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    self.healthBar.percentage = ((float)um.curHealth)/[gl calculateMaxHealthForMonster:um];
    
    BOOL greyscale = (um.curHealth <= 0);
    [self.monsterView updateForElement:mp.monsterElement imgPrefix:mp.imagePrefix greyscale:greyscale];
    
    self.topLabel.text = mp.monsterName;
    
    if (![um isAvailable]) {
      self.botLabel.hidden = NO;
      self.healthBarView.hidden = YES;
      
      self.botLabel.text = [um statusString];
      
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
  
  self.shopViewController = [[ShopViewController alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(gameStateUpdated) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self gameStateUpdated];
  
  [center addObserver:self selector:@selector(updateMonsterViews) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [self updateMonsterViews];
  
  [center addObserver:self selector:@selector(updateMailBadge) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateMailBadge) name:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateMailBadge) name:NEW_BATTLE_HISTORY_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateMailBadge) name:BATTLE_HISTORY_VIEWED_NOTIFICATION object:nil];
  [self updateMailBadge];
  
  [center addObserver:self selector:@selector(updateQuestBadge) name:QUESTS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateQuestBadge) name:ACHIEVEMENTS_CHANGED_NOTIFICATION object:nil];
  [self updateQuestBadge];
  
  [center addObserver:self selector:@selector(updateShopBadge) name:STRUCT_PURCHASED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateShopBadge) name:STRUCT_COMPLETE_NOTIFICATION object:nil];
  [self updateShopBadge];
  
  [self.updateTimer invalidate];
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  if (!self.chatBottomView) {
    [[NSBundle mainBundle] loadNibNamed:@"ChatBottomView" owner:self options:nil];
    [self.chatBottomView openAnimated:NO];
    
    CGRect r = self.chatBottomView.frame;
    r.size.width = self.view.frame.size.width;
    self.chatBottomView.frame = r;
  }
  
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:GLOBAL_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(incrementClanBadge) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(clanChatsViewed) name:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(privateChatViewed) name:PRIVATE_CHAT_VIEWED_NOTIFICATION object:nil];
  
  if (![Globals isLongiPhone]) {
    CGRect r = self.coinBarsView.frame;
    r.origin.x = CGRectGetMaxX(self.expBar.superview.frame);
    r.size.width = self.view.frame.size.width-r.origin.x;
    self.coinBarsView.frame = r;
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
}

- (void) showMyCityView {
  self.myCityView.alpha = 1.f;
}

- (void) removeMyCityView {
  self.myCityView.alpha = 0.f;
}

- (void) showClanView {
  self.clanView.alpha = 1.f;
}

- (void) removeClanView {
  self.clanView.alpha = 0.f;
}

- (void) incrementClanBadge {
  _clanChatBadgeNum++;
  
  if (self.chatBottomView.chatScope != ChatScopeClan) {
    _shouldShowClanDotOnBotView = YES;
    [self.chatBottomView reloadDataAnimated];
  }
}

- (void) clanChatsViewed {
  _clanChatBadgeNum = 0;
  _shouldShowClanDotOnBotView = NO;
  [self.chatBottomView reloadDataAnimated];
}

- (void) privateChatViewed {
  [self.chatBottomView reloadDataAnimated];
}

- (void) updateShopBadge {
  Globals *gl = [Globals sharedGlobals];
  self.shopBadge.badgeNum = [gl calculateNumberOfUnpurchasedStructs];
}

- (void) updateMailBadge {
  GameState *gs = [GameState sharedGameState];
  
  NSInteger requestsBadge = gs.fbUnacceptedRequestsFromFriends.count;
  for (PvpHistoryProto *pvp in gs.battleHistory) {
    if (pvp.isUnread) {
      requestsBadge++;
    }
  }
  self.mailBadge.badgeNum = requestsBadge;
}

- (void) updateQuestBadge {
  GameState *gs = [GameState sharedGameState];
  int badgeNum = 0;
  badgeNum += gs.availableQuests.count;
  badgeNum += gs.inProgressCompleteQuests.count;
  
  for (FullQuestProto *q in gs.inProgressIncompleteQuests.allValues) {
    for (QuestJobProto *j in q.jobsList) {
      if (j.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
        UserQuest *uq = [gs myQuestWithId:q.questId];
        UserQuestJob *uqj = [uq jobForId:j.questJobId];
        if (j.quantity == uqj.progress) {
          badgeNum++;
        }
      }
    }
  }
  
  // Check for completed achievements
  for (UserAchievement *ua in gs.myAchievements.allValues) {
    if (ua.isComplete && !ua.isRedeemed) {
      // Check that it's prereq is done
      AchievementProto *ap = [gs achievementWithId:ua.achievementId];
      if (ap.prerequisiteId) {
        UserAchievement *pre = [gs.myAchievements objectForKey:@(ap.prerequisiteId)];
        if (pre.isRedeemed) {
          badgeNum++;
        }
      } else {
        badgeNum++;
      }
    }
  }
  
  self.questBadge.badgeNum = badgeNum;
}

- (void) displayQuestProgressViewForQuest:(FullQuestProto *)fqp userQuest:(UserQuest *)uq jobId:(int)jobId completion:(void (^)(void))completion {
  [[NSBundle mainBundle] loadNibNamed:@"TopBarQuestProgressView" owner:self options:nil];
  [self.view addSubview:self.questProgressView];
  
  self.questProgressView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-self.questProgressView.frame.size.height/2-10);
  
  [self.questProgressView displayForQuest:fqp userQuest:uq jobId:jobId completion:completion];
  
  self.questProgressView = nil;
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  int shieldTimeLeft = gs.shieldEndTime.timeIntervalSinceNow;
  self.shieldLabel.text = shieldTimeLeft > 0 ? [[Globals convertTimeToShortString:shieldTimeLeft] uppercaseString] : @"NONE";
}

#pragma mark - Bottom view methods

- (void) replaceChatViewWithView:(MapBotView *)view {
  if (self.curViewOverChatView) {
    if (self.curViewOverChatView == view && view == self.chatBottomView) {
      [view update];
    } else {
      MapBotView *v = self.curViewOverChatView;
      [v animateOut:^{
        [v removeFromSuperview];
        if (self.curViewOverChatView == v) {
          self.curViewOverChatView = nil;
          [self addNewView:view];
        }
      }];
    }
  } else {
    [self addNewView:view];
  }
}

- (void) addNewView:(MapBotView *)view {
  if (view) {
    self.curViewOverChatView = view;
    [self.view insertSubview:self.curViewOverChatView atIndex:0];
    self.curViewOverChatView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-view.frame.size.height/2);
    [view animateIn:nil];
  }
}

- (void) removeViewOverChatView {
  if (self.chatBottomView) {
    [self replaceChatViewWithView:self.chatBottomView];
  } else {
    MapBotView *v = self.curViewOverChatView;
    [v animateOut:^{
      [v removeFromSuperview];
      if (self.curViewOverChatView == v) {
        self.curViewOverChatView = nil;
      }
    }];
  }
}

#pragma mark Chat Bottom View delegate

- (void) reloadChatViewAnimated {
  [self.chatBottomView reloadDataAnimated];
}

- (void) updateMapBotView:(ChatBottomView *)botView {
  [botView reloadData];
}

- (int) numChatsAvailableForScope:(ChatScope)scope {
  GameState *gs = [GameState sharedGameState];
  if (scope == ChatScopeGlobal) {
    return (int)gs.globalChatMessages.count;
  } else if (scope == ChatScopeClan) {
    return (int)gs.clanChatMessages.count;
  } else if (scope == ChatScopePrivate) {
    return (int)gs.privateChats.count;
  }
  return 0;
}

- (ChatMessage *) chatMessageForLineNum:(int)lineNum scope:(ChatScope)scope {
  GameState *gs = [GameState sharedGameState];
  if (scope == ChatScopeGlobal) {
    return gs.globalChatMessages[gs.globalChatMessages.count-lineNum-1];
  } else if (scope == ChatScopeClan) {
    return gs.clanChatMessages[gs.clanChatMessages.count-lineNum-1];
  } else if (scope == ChatScopePrivate) {
    PrivateChatPostProto *post = gs.privateChats[lineNum];
    
    ChatMessage *cm = [[ChatMessage alloc] init];
    cm.sender = post.otherUserWithLevel;
    cm.date = [MSDate dateWithTimeIntervalSince1970:post.timeOfPost/1000.];
    cm.message = post.content;
    
    return cm;
  }
  return nil;
}

- (BOOL) shouldShowUnreadDotForLineNum:(int)lineNum scope:(ChatScope)scope {
  GameState *gs = [GameState sharedGameState];
  if (scope == ChatScopePrivate) {
    PrivateChatPostProto *post = gs.privateChats[lineNum];
    return [post isUnread];
  }
  return NO;
}

- (BOOL) shouldShowNotificationDotForScope:(ChatScope)scope {
  GameState *gs = [GameState sharedGameState];
  if (scope == ChatScopePrivate) {
    int privBadge = 0;
    for (PrivateChatPostProto *p in gs.privateChats) {
      if (p.isUnread) {
        privBadge++;
      }
    }
    return privBadge > 0;
  } else if (scope == ChatScopeClan) {
    return _shouldShowClanDotOnBotView;
  }
  return NO;
}

- (void) willSwitchToScope:(ChatScope)scope {
  if (scope == ChatScopeClan) {
    _shouldShowClanDotOnBotView = NO;
  }
}

- (void) bottomViewClicked {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc openChatWithScope:self.chatBottomView.chatScope];
}

#pragma mark - IBActions

- (IBAction)menuClicked:(id)sender {
  [self openShop];
}

- (IBAction)attackClicked:(id)sender {
  if ([Globals checkEnteringDungeon]) {
    GameViewController *gvc = (GameViewController *)self.parentViewController;
    AttackMapViewController *amvc = [[AttackMapViewController alloc] init];
    amvc.delegate = gvc;
    [gvc addChildViewController:amvc];
    amvc.view.frame = gvc.view.bounds;
    [gvc.view addSubview:amvc.view];
  }
}

- (IBAction)plusClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openGemShop];
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

- (IBAction)mailClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  RequestsViewController *rvc = [[RequestsViewController alloc] init];
  [gvc addChildViewController:rvc];
  rvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:rvc.view];
}

- (IBAction)clanClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  [gvc openClanView];
}

#pragma mark - Updating HUD Stuff

- (void) gameStateUpdated {
  GameState *gs = [GameState sharedGameState];
  [self.cashLabel transitionToNum:clampf(gs.silver, 0, [gs maxCash])];
  [self.oilLabel transitionToNum:clampf(gs.oil, 0, [gs maxOil])];
  [self.gemsLabel transitionToNum:gs.gold];
  
  if (self.expLabel.currentNum <= gs.currentExpForLevel) {
    [self.expLabel transitionToNum:gs.currentExpForLevel];
  } else {
    [self.expLabel instaMoveToNum:gs.currentExpForLevel];
  }
  
  self.nameLabel.text = gs.name;
  self.levelLabel.text = [Globals commafyNumber:gs.level];
  
  self.cashMaxLabel.text = [NSString stringWithFormat:@"Max: %@", [Globals cashStringForNumber:[gs maxCash]]];
  self.oilMaxLabel.text = [NSString stringWithFormat:@"Max: %@", [Globals commafyNumber:[gs maxOil]]];
  
  if (gs.clan) {
    ClanIconProto *icon = [gs clanIconWithId:gs.clan.clanIconId];
    NSString *imgName = icon.imgName;
    [Globals imageNamed:imgName withView:self.clanShieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    [Globals imageNamed:@"inaclanbutton.png" withView:self.clanIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    self.clanShieldIcon.hidden = NO;
  } else  {
    [Globals imageNamed:@"notinaclanbutton.png" withView:self.clanIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    self.clanShieldIcon.hidden = YES;
  }
  
  [self updateLabels];
  
  self.attackBadge.badgeNum = ![gs hasShownCurrentLeague];
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

#pragma mark - Shop methods

- (void) openShop {
  if (!self.shopViewController.parentViewController) {
    [self.shopViewController displayInParentViewController:self];
    [self.mainView insertSubview:self.shopViewController.view belowSubview:self.coinBarsView];
  }
}

- (void) openShopWithFunds {
  [self openShop];
  [self.shopViewController openFundsShop];
}

- (void) openShopWithGacha {
  [self openShop];
  [self.shopViewController openGachaShop];
}

@end
