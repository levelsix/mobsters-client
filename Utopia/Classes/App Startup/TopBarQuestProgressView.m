//
//  TopBarQuestProgressView.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TopBarQuestProgressView.h"
#import "GameState.h"
#import "QuestUtil.h"

@implementation TopBarQuestProgressView

- (void) awakeFromNib {
  self.progressLabel.superview.layer.cornerRadius = 6.f;
  self.layer.cornerRadius = 6.f;
  self.monsterView.transform = CGAffineTransformMakeScale(0.64, 0.64);
}

- (void) displayForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest jobId:(int)jobId completion:(void (^)(void))completion {
  [self.monsterView updateForElement:quest.monsterElement imgPrefix:quest.questGiverImagePrefix greyscale:NO];
  
  QuestJobProto *jp = [quest jobForId:jobId];
  UserQuestJob *uj = [userQuest jobForId:jobId];
  
  int progress = uj.progress;
  
  if (!uj && jp.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
    progress = [QuestUtil checkQuantityForDonateQuestJob:jp];
  }
  
  self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", progress, jp.quantity];
  
  self.questLabel.text = [NSString stringWithFormat:@"%@%@", quest.name, quest.jobsList.count > 1 ? [NSString stringWithFormat:@": Task %d", jp.priority] : @""];
  
  [self animateIn];
  
  _completionBlock = completion;
}

- (void) animateIn {
  CGPoint center = self.center;
  self.center = ccp(center.x, self.superview.frame.size.height+self.frame.size.height/2);
  [UIView animateWithDuration:0.18f animations:^{
    self.center = center;
  } completion:^(BOOL finished) {
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:3.f];
  }];
  
  [UIView animateWithDuration:0.75 delay:0.f options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
    self.progressLabel.alpha = 0.4f;
  } completion:nil];
}

- (void) animateOut {
  [UIView animateWithDuration:0.18f animations:^{
    self.center = ccp(self.center.x, self.superview.frame.size.height+self.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    
    if (_completionBlock) {
      _completionBlock();
    }
  }];
}

@end
