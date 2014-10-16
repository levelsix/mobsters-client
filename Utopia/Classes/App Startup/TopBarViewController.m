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
  
  // We have to do this because it seems that the view connection wasnt made when the view was added
  [self.timerViewController viewWillAppear:YES];
}

- (void) viewWillAppear:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  
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
  // If updateShopBadge returns YES, we need to animate it in viewDidAppear so set it to visible or not based on that.
  if ([self updateShopBadge]) {
    self.shopBadge.alpha = 0.f; 
  }
  
  if (gs.connected && !self.chatBottomView && !gs.isTutorial) {
    [[NSBundle mainBundle] loadNibNamed:@"ChatBottomView" owner:self options:nil];
    [self.chatBottomView openAnimated:NO];
    
    // Bigger screens should stretch this
    if (self.view.width > self.chatBottomView.width) {
      self.chatBottomView.width = self.view.width;
    }
    
    [self removeViewOverChatView];
    
    ChatScope scope = gs.clan ? ChatScopeClan : ChatScopeGlobal;
    [self.chatBottomView switchToScope:scope animated:NO];
    
    // Put this here so it only happens once
    [self adjustTopBarForPhoneSize];
  }
  
  [self.updateTimer invalidate];
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:GLOBAL_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(reloadChatViewAnimated) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanChatBadge) name:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanChatBadge) name:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(privateChatViewed) name:PRIVATE_CHAT_VIEWED_NOTIFICATION object:nil];
  [center addObserver:self selector:@selector(updateClanChatBadge) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  [self.chatBottomView reloadData];
  
  // Arrow to residence
  [Globals removeUIArrowFromViewRecursively:self.view];
}

- (void) adjustTopBarForPhoneSize {
  if (![Globals isSmallestiPhone]) {
    // Turn off autoresizing for coinbarsview while we adjust for diff
    self.coinBarsView.autoresizesSubviews = NO;
    
    NSArray *arr = @[self.cashBgd, self.oilBgd];
    for (UIImageView *iv in arr) {
      iv.image = [Globals imageNamed:@"toplongbar.png"];
      
      CGSize s = iv.image.size;
      CGSize cur = iv.size;
      
      // This will get auto readjusted
      //iv.width = s.width;
      
      float diff = s.width-cur.width;
      iv.superview.width += diff;
      
      // Check in case view is not part of coin bars view
      if ([iv isDescendantOfView:self.coinBarsView]) {
        self.coinBarsView.width += diff;
        self.coinBarsView.originX -= diff;
      }
    }
    
    self.coinBarsView.autoresizesSubviews = YES;
    
    // Put cash bgd flush with right side
    self.cashView.originX = self.cashView.superview.width-self.cashView.width;
    
    int extraSpace = self.view.frame.size.width-self.coinBarsView.frame.size.width-self.expView.frame.size.width;
    if (extraSpace >= self.timersView.width || [Globals isiPhone6]) {
      // iPhone 6 and bigger
      // Move timers to top and move coin bars over
      self.timersView.height += self.timersView.originY;
      self.timersView.originY = 0;
      
      self.coinBarsView.originX -= self.timersView.width;
      
      
      // Move gem bar to the end and adjust auto resizing masks
      float diff = self.oilView.originX;
      self.oilView.originX -= diff;
      self.cashView.originX -= diff;
      
      self.gemsView.originX = self.coinBarsView.width-self.gemsView.width;
      
      self.oilView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
      self.cashView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
      self.gemsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    
    self.timerHeaderLabel.originX -= 14;
  }
  
  // For iPhone 4, just squish top bar. autoresizing will put it into place
  if (self.expView.originX+self.expView.width > self.coinBarsView.originX) {
    float newX = CGRectGetMaxX(self.expView.frame);
    float oldWidth = self.coinBarsView.width;
    float newWidth = CGRectGetMaxX(self.coinBarsView.frame)-newX;
    float maxWidth = self.view.width-newX;
    self.coinBarsView.width = MIN(maxWidth, newWidth + (oldWidth-newWidth)/4);
    self.coinBarsView.originX = newX;
  }
}

- (void) viewDidAppear:(BOOL)animated {
  // Have to do it again since animation gets cancelled otherwise
  [self updateShopBadge] ? [self animateShopBadge] : [self stopAnimatingShopBadge];
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

- (void) updateClanChatBadge {
  [self.chatBottomView reloadDataAnimated];
}

- (void) privateChatViewed {
  [self.chatBottomView reloadDataAnimated];
}

// Will return whether or not it should animate
- (BOOL) updateShopBadge {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];

  BOOL dailyFreeSpin = [gs hasDailyFreeSpin];
  int numGoodSpins = [gs numberOfFreeSpinsForBoosterPack:[gs.boosterPacks[1] boosterPackId]];
  int numBadSpins = [gs numberOfFreeSpinsForBoosterPack:[gs.boosterPacks[0] boosterPackId]];
  
  if (dailyFreeSpin) {
    self.shopBadge.badgeNum = 1;
    self.shopBadgeImage.image = [Globals imageNamed:@"bluenotificationbubble.png"];
    return YES;
  }
  else if (numGoodSpins) {
    self.shopBadge.badgeNum = numGoodSpins;
    self.shopBadgeImage.image = [Globals imageNamed:@"pinknotificationbubble.png"];
  }
  else if (numBadSpins) {
    self.shopBadge.badgeNum = numBadSpins;
    self.shopBadgeImage.image = [Globals imageNamed:@"bluenotificationbubble.png"];
  }
  else {
    self.shopBadge.badgeNum = [gl calculateNumberOfUnpurchasedStructs];
    self.shopBadgeImage.image = [Globals imageNamed:@"badgeicon.png"];
  }
  return NO;
}

- (void) animateShopBadge {
  [self stopAnimatingShopBadge];
  
  float scale = 6.f;
  self.shopBadge.transform = CGAffineTransformMakeScale(scale, scale);
  self.shopBadge.alpha = 0.f;
  [UIView animateWithDuration:0.15f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.shopBadge.alpha = 1.f;
    self.shopBadge.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    if (finished) {
      [self rotateShopBadge];
    }
  }];
}

- (void) rotateShopBadge {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  // Divide by 2 to account for autoreversing
  int repeatCt = 3;
  float rotationAmt = M_PI/7;
  [animation setDuration:0.1];
  [animation setRepeatCount:repeatCt];
  [animation setAutoreverses:YES];
  [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [animation setFromValue:[NSNumber numberWithFloat:-rotationAmt]];
  [animation setToValue:[NSNumber numberWithFloat:rotationAmt]];
  [animation setDelegate:self];
  [animation setBeginTime:CACurrentMediaTime()+4.f];
  [self.shopBadge.badgeLabel.layer addAnimation:animation forKey:@"rotation"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (flag) {
    [self rotateShopBadge];
  }
}

- (void) stopAnimatingShopBadge {
  [self.shopBadge.layer removeAllAnimations];
  [self.shopBadge.badgeLabel.layer removeAllAnimations];
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
  
  // No longer using quests
  badgeNum = 0;
  
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
    return (int)gs.allClanChatObjects.count;
  } else if (scope == ChatScopePrivate) {
    return (int)gs.privateChats.count;
  }
  return 0;
}

- (NSString *) emptyStringForScope:(ChatScope)scope {
  if (scope == ChatScopeGlobal) {
    return @"Global chat is empty, say something!";
  } else if (scope == ChatScopeClan) {
    return @"Join a squad to chat with them.";
  } else if (scope == ChatScopePrivate) {
    return @"You have no private conversations.";
  }
  return nil;
}

- (ChatMessage *) chatMessageForLineNum:(int)lineNum scope:(ChatScope)scope {
  GameState *gs = [GameState sharedGameState];
  if (scope == ChatScopeGlobal) {
    return gs.globalChatMessages[gs.globalChatMessages.count-lineNum-1];
  } else if (scope == ChatScopeClan) {
    NSArray *arr = [gs allClanChatObjects];
    return arr[arr.count-lineNum-1];
  } else if (scope == ChatScopePrivate) {
    PrivateChatPostProto *post = gs.privateChats[lineNum];
    
    ChatMessage *cm = [[ChatMessage alloc] init];
    cm.sender = post.otherUserWithLevel.minUserProto;
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
    for (PrivateChatPostProto *p in gs.privateChats) {
      if (p.isUnread) {
        return YES;
      }
    }
  } else if (scope == ChatScopeClan) {
    for (id<ChatObject> obj in gs.allClanChatObjects) {
      if (![obj isRead]) {
        return YES;
      }
    }
  }
  return NO;
}

- (void) bottomViewClicked {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc openChatWithScope:self.chatBottomView.chatScope];
}

#pragma mark - IBActions

- (IBAction)menuClicked:(id)sender {
  if (_shouldShowArrowOnResidence) {
    // Find the base residence struct
    GameState *gs = [GameState sharedGameState];
    int structId = 0;
    for (UserStruct *us in gs.myStructs) {
      if ([us.staticStruct structInfo].structType == StructureInfoProto_StructTypeResidence) {
        structId = [us baseStructId];
      }
    }
    
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self openShopWithBuildings:structId];
    _shouldShowArrowOnResidence = NO;
  } else {
    [self openShop];
  }
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
  [self.cashLabel transitionToNum:clampf(gs.cash, 0, [gs maxCash])];
  [self.oilLabel transitionToNum:clampf(gs.oil, 0, [gs maxOil])];
  [self.gemsLabel transitionToNum:gs.gems];
  
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

- (void) openShopWithBuildings:(int)structId {
  [self openShop];
  [self.shopViewController openBuildingsShop];
  [self.shopViewController.buildingViewController displayArrowOverStructId:structId];
}

- (void) openShopWithGacha {
  [self openShop];
  [self.shopViewController openGachaShop];
}

- (void) showArrowToResidence {
  _shouldShowArrowOnResidence = YES;
  [Globals createUIArrowForView:self.shopView atAngle:M_PI];
}

#pragma mark - Add home view

- (void) displayHomeViewController:(HomeViewController *)hvc {
  [hvc displayInParentViewController:self];
  
  // Move hvc's main view down a bit if we have space
  if (hvc.mainView.height < self.view.height-self.coinBarsView.height) {
    hvc.mainView.originY = self.coinBarsView.height;
    hvc.mainView.height = self.view.height-self.coinBarsView.height;
    
    // Move the coin bars above
    [self.mainView insertSubview:hvc.view belowSubview:self.coinBarsView];
  }
}

@end
