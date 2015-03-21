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
    
    self.goButtonLabel.gradientStartColor = [UIColor whiteColor];
    self.goButtonLabel.gradientEndColor = [UIColor colorWithHexString:GREEN_GRADIENT];
    self.goButtonLabel.strokeColor = [UIColor colorWithHexString:GREEN_STROKE];
    self.goButtonLabel.strokeSize = 1.f;
  } else if(self.greyScale) {
    self.nameLabel.textColor = [UIColor colorWithHexString:GREY_TEXT];
    self.gemsLabel.textColor = [UIColor colorWithHexString:GREY_TEXT];
    self.circleImage.image = [Globals imageNamed:@"lightsquadrewardcircle.png"];
    self.diamondIcon.alpha = .5f;
    self.descriptionIcon.alpha = .5f;
  }
  
  NSString *numberImage = [NSString stringWithFormat:@"%@squadreward%d.png", self.greyScale ? @"grey" : @"green", ap.lvl];
  self.numberIcon.image = [Globals imageNamed:numberImage];
  self.nameLabel.text = ap.name;
  
  
  [Globals imageNamed:ap.description withView:self.descriptionIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:@"diamond.png" withView:self.diamondIcon greyscale:self.greyScale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  [Globals imageNamed:[NSString stringWithFormat:@"srrewardbg%@.png",self.greyScale ? @"bw":@""] withView:self.rewardBg greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  if (!ua.isComplete) {
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", ua.progress, ap.quantity];
    self.gemsLabel.text = [NSString stringWithFormat:@"%d", ap.gemReward];
    
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

- (IBAction)goClicked:(id)sender {
  [self.delegate goClicked:self];
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
  ClanRewardsQuestView *curActive;
  for (int i = 0; i < arr.count; i++) {
    int achievementId = [arr[i] intValue];
    
    UserAchievement *ua = gs.myAchievements[@(achievementId)];
    AchievementProto *ap = [gs achievementWithId:achievementId];
    ClanRewardsQuestView *questView = self.questViews[i];
    questView.questType = i;
    
    if (!ua.isComplete && !curActive) {
      curActive = questView;
      self.titleLabel.text = [NSString stringWithFormat:@"%@ TO EARN FREE", [ap.name uppercaseString]];
      CGSize size = [self.titleLabel.text getSizeWithFont:self.titleLabel.font];
      self.titleDiamond.center = CGPointMake(self.titleLabel.center.x+(size.width/2)+(self.titleDiamond.frame.size.width/2), self.titleLabel.center.y);
      CGPoint arrowLocation = CGPointMake((questView.size.width/2) + (questView.size.width * i) - 1, self.squadRewardArrow.center.y);
      self.squadRewardArrow.center = arrowLocation;
      
    } else if(!ua.isComplete) {
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
  }
}

- (void) goClicked:(id)sender {
  ClanRewardsQuestView *sentView = (ClanRewardsQuestView *)sender;
  if(sentView.questType == QuestTypeBuildHQ) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc arrowToStructInShopWithId:1100];
    [self closeClicked:sender];
  } else if(sentView.questType == QuestTypeJoinClan) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc arrowToOpenClanMenu];
    [self closeClicked:sender];
  } else if(sentView.questType == QuestTypeRequestToon) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc arrowToRequestToon];
    [self closeClicked:sender];
  }
}

@end
