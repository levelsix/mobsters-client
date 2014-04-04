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
  self.monsterIcon.superview.transform = CGAffineTransformMakeScale(0.64, 0.64);
}

- (void) displayForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest {
  NSString *file = [quest.questGiverImagePrefix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:file withView:self.monsterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  file = [Globals imageNameForElement:quest.monsterElement suffix:@"team.png"];
  [Globals imageNamed:file withView:self.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (quest.quantity < 100) {
    int progress = userQuest.progress;
    
    if (!userQuest && quest.questType == FullQuestProto_QuestTypeDonateMonster) {
      progress = [QuestUtil checkQuantityForDonateQuest:quest];
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", progress, quest.quantity];
  } else {
    self.progressLabel.text = [NSString stringWithFormat:@"%@", [Globals commafyNumber:userQuest.progress]];
  }
  
  self.questLabel.text = [NSString stringWithFormat:@"Quest: %@", quest.name];

  [self animateIn];
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
  }];
}

@end
