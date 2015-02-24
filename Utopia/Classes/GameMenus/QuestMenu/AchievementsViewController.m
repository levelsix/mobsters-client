//
//  AchievementsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "AchievementsViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"

#import "ChartboostDelegate.h"

@implementation AchievementsCell

- (void) awakeFromNib {
  self.collectView.frame = self.progressView.frame;
  [self.progressView.superview addSubview:self.collectView];
  
  self.spinner.transform = CGAffineTransformMakeScale(0.75, 0.75);
}

- (void) loadForAchievement:(AchievementProto *)ap userAchievement:(UserAchievement *)ua {
  self.titleLabel.text = ap.name;
  self.descriptionLabel.text = ap.description;
  self.gemRewardLabel.text = [Globals commafyNumber:ap.gemReward];
  
  int numStars = 0;
  if (!ua.isRedeemed) {
    NSString *str1 = ap.resourceType == ResourceTypeCash ? [Globals cashStringForNumber:ua.progress] : [Globals commafyNumber:ua.progress];
    NSString *str2 = ap.resourceType == ResourceTypeCash ? [Globals cashStringForNumber:ap.quantity] : [Globals commafyNumber:ap.quantity];
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@", str1, str2];
    self.progressBar.percentage = ua.progress/(float)ap.quantity;
    numStars = ap.lvl-1;
  } else {
    self.progressLabel.text = @"Complete";
    self.progressBar.percentage = 1.f;
    numStars = ap.lvl;
  }
  
  for (int i = 0; i < self.starViews.count; i++) {
    UIImageView *img = self.starViews[i];
    img.highlighted = i >= numStars;
  }
  self.rankLabel.text = [NSString stringWithFormat:@"%d", numStars];
  
  self.collectView.hidden = (!ua.isComplete || ua.isRedeemed);
  self.progressView.hidden = !self.collectView.hidden;
  
  self.achievementId = ap.achievementId;
}

- (void) animateCompletion {
  CGPoint originalCenter = self.mainView.center;
  
  // Call this before reloading cell
  UIImage *img = [Globals snapShotView:self.mainView];
  UIImageView *iv = [[UIImageView alloc] initWithImage:img];
  iv.center = self.mainView.center;
  self.mainView.center = ccp(originalCenter.x*3, originalCenter.y);
  [self.contentView addSubview:iv];
  
  [UIView animateWithDuration:0.3 animations:^{
    iv.center = ccp(-originalCenter.x, originalCenter.y);
    self.mainView.center = originalCenter;
  } completion:^(BOOL finished) {
    [iv removeFromSuperview];
  }];
}

@end

@implementation AchievementsViewController

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  if (_redeemedSomething) {
    [ChartboostDelegate fireAchievementRedeemed];
  }
}

- (void) reloadWithAchievements:(NSDictionary *)allAchievements userAchievements:(NSDictionary *)userAchievements {
  self.allAchievements = allAchievements;
  self.userAchievements = userAchievements;
  
  NSArray *achievements = allAchievements.allValues;
  NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(AchievementProto *ap, NSDictionary *bindings) {
    UserAchievement *ua = userAchievements[@(ap.achievementId)];
    
    if (ua.isRedeemed) {
      return ap.successorId == 0 && ap.priority;
    } else {
      if (ap.prerequisiteId) {
        UserAchievement *pre = userAchievements[@(ap.prerequisiteId)];
        return pre.isRedeemed;
      } else if (ap.priority) {
        return YES;
      }
    }
    return NO;
  }];
  achievements = [achievements filteredArrayUsingPredicate:pred];
  achievements = [achievements sortedArrayUsingComparator:^NSComparisonResult(AchievementProto *obj1, AchievementProto *obj2) {
    UserAchievement *ua1 = userAchievements[@(obj1.achievementId)];
    UserAchievement *ua2 = userAchievements[@(obj2.achievementId)];
    if (ua1.isRedeemed != ua2.isRedeemed) {
      return [@(ua1.isRedeemed) compare:@(ua2.isRedeemed)];
    } else if (ua1.isComplete != ua2.isComplete) {
      return [@(ua2.isComplete) compare:@(ua1.isComplete)];
    } else {
      return [@(obj1.priority) compare:@(obj2.priority)];
    }
  }];
  self.activeAchievements = [achievements mutableCopy];
  
  [self.achievementsTable reloadData];
}

- (IBAction) collectClicked:(UIView *)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[AchievementsCell class]];
  
  if (sender && !_redeemingAchievementId) {
    AchievementsCell *cell = (AchievementsCell *)sender;
    [[OutgoingEventController sharedOutgoingEventController] redeemAchievement:cell.achievementId delegate:self];
    
    cell.spinner.hidden = NO;
    [cell.spinner startAnimating];
    cell.collectLabel.hidden = YES;
    _redeemingAchievementId = cell.achievementId;
    
    _redeemedSomething = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACHIEVEMENTS_CHANGED_NOTIFICATION object:self];
  }
}

- (void) handleAchievementRedeemResponseProto:(FullEvent *)fe {
  AchievementProto *ap = self.allAchievements[@(_redeemingAchievementId)];
  AchievementProto *nextAp;
  
  if (ap.successorId) {
    nextAp = self.allAchievements[@(ap.successorId)];
  } else {
    nextAp = ap;
  }
  
  NSUInteger index = [self.activeAchievements indexOfObject:ap];
  if (index != NSNotFound) {
    [self.activeAchievements replaceObjectAtIndex:index withObject:nextAp];
    
    UserAchievement *ua = self.userAchievements[@(nextAp.achievementId)];
    
    AchievementsCell *cell = (AchievementsCell *)[self.achievementsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    // Animate it only if it is a new quest
    if (nextAp != ap) [cell animateCompletion];
    [cell loadForAchievement:nextAp userAchievement:ua];
    cell.spinner.hidden = YES;
    cell.collectLabel.hidden = NO;
  }
  
  [Globals addPurpleAlertNotification:[NSString stringWithFormat:@"You collected %d Gems for completing %@: Rank %d!", ap.gemReward, ap.name, ap.lvl]];
  
  [Analytics redeemedAchievement:_redeemingAchievementId];
  
  _redeemingAchievementId = 0;
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.activeAchievements.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AchievementsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AchievementsCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"AchievementsCell" owner:self options:nil];
    cell = self.achievementsCell;
  }
  
  AchievementProto *ap = self.activeAchievements[indexPath.row];
  UserAchievement *ua = self.userAchievements[@(ap.achievementId)];
  [cell loadForAchievement:ap userAchievement:ua];
  
  if (ap.achievementId == _redeemingAchievementId) {
    cell.spinner.hidden = NO;
    [cell.spinner startAnimating];
    cell.collectLabel.hidden = YES;
  } else {
    cell.spinner.hidden = YES;
    cell.collectLabel.hidden = NO;
  }
  
  return cell;
}

@end
