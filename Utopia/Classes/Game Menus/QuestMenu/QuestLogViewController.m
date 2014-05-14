//
//  QuestLogViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestLogViewController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "QuestUtil.h"

@implementation QuestLogViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.questListViewController = [[QuestListViewController alloc] init];
  [self addChildViewController:self.questListViewController];
  
  self.achievementsViewController = [[AchievementsViewController alloc] init];
  [self addChildViewController:self.achievementsViewController];
  
  GameState *gs = [GameState sharedGameState];
  [self.questListViewController reloadWithQuests:gs.allCurrentQuests userQuests:gs.myQuests];
  [self.achievementsViewController reloadWithAchievements:gs.staticAchievements userAchievements:gs.myAchievements];
  
  self.titleLabel.alpha = 0.f;
  self.titleLabel.text = self.questListViewController.title;
  self.backView.hidden = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questsChanged:) name:QUESTS_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(achievementsChanged:) name:ACHIEVEMENTS_CHANGED_NOTIFICATION object:nil];
  [self updateBadges];
  
  // Move to tab with badge if we are not specifically trying to view details page
  if (!self.questDetailsViewController) {
    if (self.questBadge.badgeNum) {
      [self button1Clicked:nil];
    } else if (self.achievementBadge.badgeNum) {
      [self button2Clicked:nil];
    } else {
      [self button1Clicked:nil];
    }
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) questsChanged:(NSNotification *)notif {
  GameState *gs = [GameState sharedGameState];
  [self.questListViewController reloadWithQuests:gs.allCurrentQuests userQuests:gs.myQuests];
  
  if (self.questDetailsViewController) {
    int questId = self.questDetailsViewController.quest.questId;
    FullQuestProto *fqp = [gs questForId:questId];
    if (fqp) {
      [self.questDetailsViewController loadWithQuest:fqp userQuest:[gs myQuestWithId:questId]];
    }
  }
  
  [self updateBadges];
}

- (void) achievementsChanged:(NSNotification *)notif {
  if (notif.object != self.achievementsViewController) {
    GameState *gs = [GameState sharedGameState];
    [self.achievementsViewController reloadWithAchievements:gs.staticAchievements userAchievements:gs.myAchievements];
  }
  
  [self updateBadges];
}

- (void) updateBadges {
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
  
  self.questBadge.badgeNum = badgeNum;
  
  badgeNum = 0;
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
  self.achievementBadge.badgeNum = badgeNum;
}

- (IBAction)close:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if ([self.delegate respondsToSelector:@selector(questLogClosed)]) {
      [self.delegate questLogClosed];
    }
  }];
}

#pragma mark - TabBarDelegate methods

- (void) button1Clicked:(id)sender {
  if (!self.questDetailsViewController) {
    [self.topBar clickButton:1];
    
    [self.achievementsViewController.view removeFromSuperview];
    [self.containerView addSubview:self.questListViewController.view];
  }
}

- (void) button2Clicked:(id)sender {
  if (!self.questDetailsViewController) {
    [self.topBar clickButton:2];
    
    [self.questListViewController.view removeFromSuperview];
    [self.containerView addSubview:self.achievementsViewController.view];
  }
}

#pragma mark - Transition between ViewControllers

- (void) transitionToDetailsViewAnimated:(BOOL)animated {
  self.questDetailsViewController.view.center = ccp(self.containerView.frame.size.width+
                                                    self.questDetailsViewController.view.frame.size.width/2,
                                                    self.questDetailsViewController.view.center.y);
  self.backView.hidden = NO;
  self.backView.alpha = 0.f;
  float duration = animated ? 0.3f : 0.f;
  [UIView animateWithDuration:duration animations:^{
    self.questDetailsViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                                      self.questDetailsViewController.view.center.y);
    self.questListViewController.view.center = ccp(-self.questListViewController.view.center.x,
                                                   self.questListViewController.view.center.y);
    self.backView.alpha = 1.f;
    
    self.topBar.alpha = 0.f;
    self.titleLabel.alpha = 1.f;
  }];
  self.titleLabel.text = self.questDetailsViewController.title;
}

- (void) transitionToListView {
  // Do this so that the view doesn't update while scrolling back
  QuestDetailsViewController *qdvc = self.questDetailsViewController;
  self.questDetailsViewController = nil;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.questListViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                                   self.questListViewController.view.center.y);
    qdvc.view.center = ccp(self.containerView.frame.size.width+
                           qdvc.view.frame.size.width/2,
                           qdvc.view.center.y);
    self.backView.alpha = 0.f;
    
    self.topBar.alpha = 1.f;
    self.titleLabel.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.backView.hidden = YES;
    
    [qdvc.view removeFromSuperview];
    [qdvc removeFromParentViewController];
  }];
}

#pragma mark - QuestListCellDelegate methods

- (void) questListCellClicked:(QuestListCell *)cell {
  if (cell.userQuest.isComplete) {
    [[GameViewController baseController] questComplete:cell.quest];
    [self close];
  } else {
    [self loadDetailsViewForQuest:cell.quest userQuest:cell.userQuest animated:YES];
  }
}

- (void) loadDetailsViewForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)uq animated:(BOOL)animated {
  self.questDetailsViewController = [[QuestDetailsViewController alloc] init];
  self.questDetailsViewController.delegate = self;
  [self addChildViewController:self.questDetailsViewController];
  [self.containerView addSubview:self.questDetailsViewController.view];
  [self.questDetailsViewController loadWithQuest:quest userQuest:uq];
  
  [self transitionToDetailsViewAnimated:animated];
  
  if (!uq) {
    [[OutgoingEventController sharedOutgoingEventController] acceptQuest:quest.questId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
    
    [QuestUtil checkNewlyAcceptedQuest:quest];
  }
}

- (IBAction)backClicked:(id)sender {
  [self transitionToListView];
}

#pragma mark - QuestDetailsViewControllerDelegate methods

- (void) visitOrDonateClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC jobId:(int)jobId {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  FullQuestProto *quest = detailsVC.quest;
  UserQuest *uq = detailsVC.userQuest;
  QuestJobProto *jp = [quest jobForId:jobId];
  UserQuestJob *uj = [uq jobForId:jobId];
  if (jp.questJobType == QuestJobProto_QuestJobTypeDonateMonster && jp.quantity == uj.progress) {
    // Donate monsters
    [self doDonateForQuest:quest.questId jobId:jobId];
  } else {
    [gvc visitCityClicked:jp.cityId assetId:jp.cityAssetNum];
    [self close:nil];
  }
}

- (void) doDonateForQuest:(int)questId jobId:(int)jobId {
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *fqp = [gs questForId:questId];
  QuestJobProto *jp = [fqp jobForId:jobId];
  NSMutableArray *potentials = [NSMutableArray array];
  for (UserMonster *um in gs.myMonsters) {
    if (um.monsterId == jp.staticDataId && um.isAvailable) {
      [potentials addObject:um];
    }
  }
  
  [potentials sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.experience < obj2.experience) {
      return NSOrderedAscending;
    } else if (obj1.experience > obj2.experience) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  
  if (potentials.count >= jp.quantity) {
    NSArray *ums = [potentials subarrayWithRange:NSMakeRange(0, jp.quantity)];
    NSMutableArray *ids = [NSMutableArray array];
    int numOnTeam = 0;
    for (UserMonster *um in ums) {
      if (um.teamSlot > 0) {
        numOnTeam++;
      }
      [ids addObject:[NSNumber numberWithUnsignedLongLong:um.userMonsterId]];
    }
    
    self.userMonsterIds = ids;
    
    _donateJobId = jobId;
    if (numOnTeam) {
      NSString *desc = [NSString stringWithFormat:@"%@ of these mobsters %@ on your team. Would you still like to donate?", numOnTeam == 1 ? @"One" : numOnTeam == 2 ? @"Two" : @"Three", numOnTeam == 1 ? @"is" : @"are"];
      [GenericPopupController displayConfirmationWithDescription:desc title:@"Mobsters on Team" okayButton:@"Donate" cancelButton:@"Cancel" target:self selector:@selector(donateConfirmed)];
    } else {
      [self donateConfirmed];
    }
  }
}

- (void) donateConfirmed {
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *quest = self.questDetailsViewController.quest;
  UserQuest *uqNew = [[OutgoingEventController sharedOutgoingEventController] donateForQuest:quest.questId jobId:_donateJobId monsterIds:self.userMonsterIds];
  self.userMonsterIds = nil;
  if (uqNew.isComplete) {
    [UIView animateWithDuration:0.5f animations:^{
      [self.questDetailsViewController loadWithQuest:quest userQuest:uqNew];
    }];
  }
  [self.questListViewController reloadWithQuests:gs.allCurrentQuests userQuests:gs.myQuests];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) collectClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC {
  GameState *gs = [GameState sharedGameState];
  [[OutgoingEventController sharedOutgoingEventController] redeemQuest:detailsVC.quest.questId delegate:self];
  [self.questListViewController reloadWithQuests:gs.allCurrentQuests userQuests:gs.myQuests];
}

#pragma mark - Redeem quest delegate

- (void) handleQuestRedeemResponseProto:(FullEvent *)fe {
  QuestRedeemResponseProto *proto = (QuestRedeemResponseProto *)fe.event;
  GameState *gs = [GameState sharedGameState];
  
  FullQuestProto *quest = nil;
  for (FullQuestProto *fqp in proto.newlyAvailableQuestsList) {
    if (fqp.hasAcceptDialogue) {
      quest = fqp;
      break;
    }
  }
  
  if (quest) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc beginDialogue:quest.acceptDialogue withQuestId:quest.questId];
    [self close:nil];
  } else if (self.questDetailsViewController.quest.questId == proto.questId) {
    [self transitionToListView];
    
    [self.questListViewController reloadWithQuests:gs.allCurrentQuests userQuests:gs.myQuests];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

@end
