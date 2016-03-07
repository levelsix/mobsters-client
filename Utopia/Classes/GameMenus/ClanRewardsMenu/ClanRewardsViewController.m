//
//  ClanRewardsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRewardsViewController.h"

#import "Protocols.pb.h"

#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

#import "OutgoingEventController.h"

#define GREEN_BG @"ECFBD4"
#define GREY_TEXT @"C3C3C3"

#define GREEN_GRADIENT @"C5F285"
#define GREEN_STROKE @"2F5008"

#define PURPLE_TEXT @"9100DE"
#define DARK_GREY_TEXT @"333333"

@implementation ClanRewardsQuestView

- (void) updateForUserAchievement:(UserAchievement *)ua achievement:(AchievementProto *)ap {
  self.completeView.hidden = YES;
  self.collectView.hidden = YES;
  self.rewardView.hidden = YES;
  self.goButtonView.hidden = YES;
  
  self.nameLabel.textColor = [UIColor colorWithHexString:DARK_GREY_TEXT];
  self.gemsLabel.textColor = [UIColor colorWithHexString:PURPLE_TEXT];
  
  self.nameLabel.highlighted = self.greyScale;
  
  self.nameLabel.text = ap.name;
  
  [Globals imageNamed:ap.description withView:self.descriptionIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (!ua.isComplete) {
    self.gemsLabel.text = [NSString stringWithFormat:@"%d", ap.gemReward];
    self.goButtonView.hidden = NO;
    
    //    self.progressView.hidden = self.greyScale;
    self.rewardView.hidden = NO;
  } else if (!ua.isRedeemed) {
    self.collectView.hidden = NO;
  } else {
    self.completeView.hidden = NO;
  }
}

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClicked:self];
}

- (IBAction)goClicked:(id)sender {
  [self.delegate goClicked:self];
}

@end

@implementation ClanRewardsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = POPUP_CORNER_RADIUS;
  self.containerView.superview.clipsToBounds = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ACHIEVEMENTS_CHANGED_NOTIFICATION object:nil];
  [self reload];
  
  [[GameViewController baseController] clearTutorialArrows];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  if (!_goClicked) {
//    [[GameViewController baseController] showEarlyGameTutorialArrow];
  }
}

- (IBAction) closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (void) reload {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *arr = gl.clanRewardAchievementIds;
  ClanRewardsQuestView *curActive;
  for (int i = 0; i < arr.count; i++) {
    int achievementId = [arr[i] intValue];
    
    UserAchievement *ua = gs.myAchievements[@(achievementId)];
    AchievementProto *ap = [gs achievementWithId:achievementId];
    ClanRewardsQuestView *questView = self.questViews[i];
    
    if (!ua.isRedeemed && !curActive) {
      curActive = questView;
      
      CGSize size = [self.titleLabel.text getSizeWithFont:self.titleLabel.font];
      self.titleDiamond.center = CGPointMake(self.titleLabel.center.x+(size.width/2)+(self.titleDiamond.frame.size.width/2), self.titleLabel.center.y);
      
      CGPoint arrowLocation = CGPointMake((questView.size.width/2) + (questView.size.width * i) , self.squadRewardArrow.center.y);
      self.squadRewardArrow.center = arrowLocation;
      
      questView.greyScale = NO;
      
    } else if(!ua.isComplete || ua.isRedeemed) {
      questView.greyScale = YES;
    }
    
    [questView updateForUserAchievement:ua achievement:ap];
  }
}

- (void) collectClicked:(id)sender {
  NSInteger idx = [self.questViews indexOfObject:sender];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (idx != NSNotFound && idx < gl.clanRewardAchievementIds.count) {
    int achievementId = [gl.clanRewardAchievementIds[idx] intValue];
    AchievementProto *ap = [gs achievementWithId:achievementId];
    
    [[OutgoingEventController sharedOutgoingEventController] redeemAchievement:achievementId delegate:nil];
    
    [Globals addPurpleAlertNotification:[NSString stringWithFormat:@"You collected %d Gems for completing %@!", ap.gemReward, ap.name] isImmediate:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACHIEVEMENTS_CHANGED_NOTIFICATION object:self];
    
    [self reload];
  }
}

- (void) goClicked:(id)sender {
  NSInteger idx = [self.questViews indexOfObject:sender];
  
  
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (idx != NSNotFound && idx < gl.clanRewardAchievementIds.count) {
    int achievementId = [gl.clanRewardAchievementIds[idx] intValue];
    AchievementProto *ap = [gs achievementWithId:achievementId];
    
    GameViewController *gvc = [GameViewController baseController];
    
    if (ap.achievementType == AchievementProto_AchievementTypeUpgradeBuilding) {
      [gvc arrowToStructInShopWithId:1100];
    } else if (ap.achievementType == AchievementProto_AchievementTypeJoinClan) {
      [gvc arrowToOpenClanMenu];
    } else if (ap.achievementType == AchievementProto_AchievementTypeRequestToon) {
      [gvc arrowToRequestToon];
    }
    
    _goClicked = YES;
    [self closeClicked:sender];
  }
}

@end
