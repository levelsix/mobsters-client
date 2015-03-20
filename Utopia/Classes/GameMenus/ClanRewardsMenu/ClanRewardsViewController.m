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

#import "OutgoingEventController.h"

#define GREEN_BG @"ECFBD4"

@implementation ClanRewardsQuestView

- (void) updateForUserAchievement:(UserAchievement *)ua achievement:(AchievementProto *)ap {
  self.progressView.hidden = YES;
  self.checkView.hidden = YES;
  self.completeView.hidden = YES;
  self.collectView.hidden = YES;
  self.diamondIcon.superview.hidden = YES;
  self.goButtonLabel.superview.hidden = YES;
  
  if(!self.greyScale && !ua.isComplete) {
    self.backgroundColor =[UIColor colorWithHexString:GREEN_BG];
    self.goButtonLabel.superview.hidden = NO;
  }
  
  NSString *numberImage = [NSString stringWithFormat:@"%@squadreward%d.png", self.greyScale ? @"grey" : @"green", ap.lvl];
  self.numberIcon.image = [Globals imageNamed:numberImage];
  self.nameLabel.text = ap.name;
  
  [Globals imageNamed:ap.description withView:self.descriptionIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"diamond.png" withView:self.diamondIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:[NSString stringWithFormat:@"srrewardbg%@",self.greyScale ? @"bw":@""] withView:self.diamondIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  if (!ua.isComplete) {
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", ua.progress, ap.quantity];
    self.gemsLabel.text = [NSString stringWithFormat:@"%d GEMS", ap.gemReward];
    
    self.progressView.hidden = self.greyScale;
    self.diamondIcon.superview.hidden = NO;
  } else if (!ua.isRedeemed) {
    self.checkView.hidden = NO;
    self.collectView.hidden = NO;
  } else {
    self.checkView.hidden = NO;
    self.completeView.hidden = NO;
  }
}

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClicked:self];
}

@end

@implementation ClanRewardsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ACHIEVEMENTS_CHANGED_NOTIFICATION object:nil];
  [self reload];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (void) reload {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *arr = gl.clanRewardAchievementIds;
  
  for (int i = 0; i < arr.count; i++) {
    int achievementId = [arr[i] intValue];
    
    UserAchievement *ua = gs.myAchievements[@(achievementId)];
    
    if (!ua.isComplete) {
      [self centerOnAchievementWithIndex:i];
      return;
    }
  }
  
  [self centerOnAchievementWithIndex:0];
}

- (void)centerOnAchievementWithIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [Globals sharedGlobals].clanRewardAchievementIds;
  int achievementId = [arr[index] intValue];
  
  UserAchievement *ua = gs.myAchievements[@(achievementId)];
  AchievementProto *ap = [gs achievementWithId:achievementId];
  
  ClanRewardsQuestView *questView;
  questView = self.questViews[1];
  questView.greyScale = NO;
  [questView updateForUserAchievement:ua achievement:ap];
  if(index) {
    ua = gs.myAchievements[@(achievementId-1)];
    ap = [gs achievementWithId:achievementId-1];
    questView = self.questViews[0];
    questView.greyScale = NO;
    [questView updateForUserAchievement:ua achievement:ap];
  } else {
    questView = self.questViews[0];
    questView.hidden = YES;
  }
  if (index+1 != arr.count) {
    ua = gs.myAchievements[@(achievementId+1)];
    ap = [gs achievementWithId:achievementId+1];
    questView = self.questViews[2];
    questView.greyScale = YES;
    [questView updateForUserAchievement:ua achievement:ap];
  } else {
    questView = self.questViews[2];
    questView.hidden = YES;
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
  }
}

@end
