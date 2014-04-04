//
//  AttackMapViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "AttackMapViews.h"
#import "GameState.h"
#import "Globals.h"
#import "PersistentEventProto+Time.h"
#import "CAKeyframeAnimation+AHEasing.h"

@implementation AttackMapIconView

- (void)setIsLocked:(BOOL)isLocked {
  _isLocked = isLocked;
  if (isLocked) {
    [self.cityButton setImage:[UIImage imageNamed:@"closedcity.png"] forState:UIControlStateNormal];
  }
  else {
    [self.cityButton setImage:[UIImage imageNamed:@"opencity.png"] forState:UIControlStateNormal];
  }
}

- (void) doShake {
  [Globals shakeView:self.cityNameIcon duration:0.5f offset:5.f];
}

@end

@implementation AttackEventView

- (void) updateForEvo {
  GameState *gs = [GameState sharedGameState];
  _eventType = PersistentEventProto_EventTypeEvolution;
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
  [self updateForPersistentEvent:pe];
  [self.tabBar clickButton:kButton1];
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  _eventType = PersistentEventProto_EventTypeEnhance;
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
  [self updateForPersistentEvent:pe];
  [self.tabBar clickButton:kButton2];
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *imgs = [NSMutableArray array];
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 16; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  }
  
  self.monsterImage.animationImages = imgs;
  
  self.monsterImage.animationDuration = imgs.count*0.1;
  [self.monsterImage startAnimating];
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    self.topRibbonLabel.text = pe.type == PersistentEventProto_EventTypeEnhance ? @"FEEDER" : @"DAILY";
    self.botRibbonLabel.text = pe.type == PersistentEventProto_EventTypeEvolution ? @"event now!" : @"laboratory";
    
    NSString *file = [Globals imageNameForElement:pe.monsterElement suffix:@"banner.png"];
    self.bgdImage.image = [Globals imageNamed:file];
    file = [Globals imageNameForElement:pe.monsterElement suffix:@"dailylab.png"];
    self.ribbonImage.image = [Globals imageNamed:file];
    
    self.nameLabel.text = task.name;
    
    _persistentEventId = pe.eventId;
    self.taskId = pe.taskId;
    
    self.mainView.hidden = NO;
    self.noEventView.hidden = YES;
    self.monsterImage.hidden = NO;
  } else {
    _persistentEventId = 0;
    self.taskId = 0;
    
    self.mainView.hidden = YES;
    self.noEventView.hidden = NO;
    self.monsterImage.hidden = YES;
  }
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs currentPersistentEventWithType:_eventType];
  
  if (_persistentEventId != pe.eventId) {
    [self updateForPersistentEvent:pe];
  } else {
    int timeLeft = [pe.endTime timeIntervalSinceNow];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time Left: %@", [Globals convertTimeToShortString:timeLeft]];
    
    MSDate *cdTime = pe.cooldownEndTime;
    timeLeft = [cdTime timeIntervalSinceNow];
    if (timeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
    } else {
      self.cooldownLabel.text = [NSString stringWithFormat:@"Opens In: %@", [Globals convertTimeToShortString:timeLeft]];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
      self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (void) button1Clicked:(id)sender {
  [self updateForEvo];
}

- (void) button2Clicked:(id)sender {
  [self updateForEnhance];
}

@end

@implementation AttackMapIconViewContainer

- (void)awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
  [[NSBundle mainBundle] loadNibNamed:@"AttackMapIconView" owner:self options:nil];
  [self addSubview:self.iconView];
}

@end

@implementation LeaguePromotionView

- (void) awakeFromNib {
  self.spinner.alpha = 0.f;
  self.curLeagueIcon.hidden = YES;
}

- (void) dropLeagueIcon {
  self.curLeagueIcon.center = ccp(self.curLeagueIcon.center.x, -self.curLeagueIcon.frame.size.height/2);
  CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:self.curLeagueIcon.center toPoint:self.oldLeagueIcon.center keyframeCount:150];
  kf.duration = 1.f;
  kf.delegate = self;
  kf.beginTime = CACurrentMediaTime()+0.3;
  [self.curLeagueIcon.layer addAnimation:kf forKey:@"bounce"];
  
  CGPoint oldEnd = ccp(self.oldLeagueIcon.center.x, self.frame.size.height+self.curLeagueIcon.frame.size.height/2);
  kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:SineEaseIn fromPoint:self.oldLeagueIcon.center toPoint:oldEnd keyframeCount:150];
  kf.duration = 0.5f;
  kf.beginTime = CACurrentMediaTime();
  [self.oldLeagueIcon.layer addAnimation:kf forKey:@"fall"];
  
  self.curLeagueIcon.center = self.oldLeagueIcon.center;
  self.oldLeagueIcon.center = oldEnd;
}

- (void) animationDidStart:(CAAnimation *)anim {
  self.curLeagueIcon.hidden = NO;
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  CABasicAnimation *fullRotation;
  fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  fullRotation.fromValue = [NSNumber numberWithFloat:0];
  fullRotation.toValue = [NSNumber numberWithFloat:M_PI * 2];
  fullRotation.duration = 6.f;
  fullRotation.repeatCount = 50000;
  [self.spinner.layer addAnimation:fullRotation forKey:@"360"];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.spinner.alpha = 1.f;
  }];
}

- (IBAction) okayClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
  }];
}

@end

@implementation LeagueDescriptionView

- (void) updateForLeague:(PvpLeagueProto *)pvp {
  self.nameLabel.text = pvp.leagueName;
  self.descriptionLabel.text = pvp.description;
  
  NSString *bgd = [pvp.imgPrefix stringByAppendingString:@"rankbg.png"];
  [Globals imageNamed:bgd withView:self.leagueBgd greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *icon = [pvp.imgPrefix stringByAppendingString:@"icon.png"];
  [Globals imageNamed:icon withView:self.leagueIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

@end

@implementation MultiplayerView

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.multiplayerUnlockLabel.superview.layer.cornerRadius = 8.f;
  self.multiplayerUnlockLabel.text = [NSString stringWithFormat:@"Multiplayer play\n unlocks at level %d", gl.pvpRequiredMinLvl];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.cashCostLabel.text = [NSString stringWithFormat:@"Match Cost: %@", [Globals cashStringForNumber:thp.pvpQueueCashCost]];
  
  self.backButton.alpha = 0.f;
  self.titleLabel.text = @"Multiplayer";
  
  self.layer.cornerRadius = 8.f;
  
  for (LeagueDescriptionView *dv in self.leagueDescriptionViews) {
    PvpLeagueProto *pvp = [gs leagueForId:dv.tag];
    [dv updateForLeague:pvp];
  }
  [self.leagueView updateForUserLeague:gs.pvpLeague];
}

- (IBAction)leagueSelected:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.containerView.center = ccp(0, self.containerView.center.y);
    self.backButton.alpha = 1.f;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3f;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
  self.titleLabel.text = @"Rank";
}

- (IBAction)backClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.containerView.center = ccp(self.containerView.frame.size.width/2, self.containerView.center.y);
    self.backButton.alpha = 0.f;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3f;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
  self.titleLabel.text = @"Multiplayer";
}

@end