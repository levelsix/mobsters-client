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

- (void) awakeFromNib {
  self.layer.anchorPoint = ccp(0.5, 0.713);
  [self removeLabelAndGlow];
  
  self.spinner.hidden = YES;
}

- (void) setIsLocked:(BOOL)isLocked bossImage:(NSString *)bossImage element:(Element)element {
  BOOL isBoss = bossImage != nil;
  
  _isLocked = isLocked;
  if (isLocked) {
    NSString *str = [NSString stringWithFormat:@"locked%@.png", isBoss ? @"boss" : @"city"];
    [self.cityButton setImage:[Globals imageNamed:str] forState:UIControlStateNormal];
  } else {
    NSString *str = [@"open" stringByAppendingString:[Globals imageNameForElement:element suffix:@".png"]];
    [self.cityButton setImage:[Globals imageNamed:str] forState:UIControlStateNormal];
  }
  
  if (isBoss) {
    [Globals imageNamed:bossImage withView:self.bossIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    self.cityNumLabel.hidden = YES;
    self.bossIcon.hidden = NO;
    self.shadowIcon.hidden = NO;
  } else {
    self.cityNumLabel.hidden = isLocked;
    self.bossIcon.hidden = YES;
    self.shadowIcon.hidden = YES;
  }
}

- (void) doShake {
  [Globals shakeView:self.cityNameIcon duration:0.5f offset:5.f];
}

- (void) updateForTaskMapElement:(TaskMapElementProto *)elem task:(FullTaskProto *)task isLocked:(BOOL)isLocked {
  [self setIsLocked:isLocked bossImage:(elem.boss ? elem.bossImgName : nil) element:elem.element];
  self.tag = elem.mapElementId;
  self.cityNumLabel.text = [NSString stringWithFormat:@"%d", elem.mapElementId];
  _name = task.name;
  
  [self removeLabelAndGlow];
}

- (void) displayLabelAndGlow {
  // Optimized so all strokes don't get rewritten immediately
  self.nameLabel.strokeSize = 1.2f;
  self.nameLabel.text = [NSString stringWithFormat:@"%@ »", _name];
  
  self.nameLabel.hidden = NO;
  
  if (!self.isLocked) {
    self.glowIcon.hidden = NO;
    
    self.nameLabel.gradientStartColor = [UIColor colorWithRed:240/255.f green:253/255.f blue:152/255.f alpha:1.f];
    self.nameLabel.gradientEndColor = [UIColor colorWithRed:222/255.f green:251/255.f blue:72/255.f alpha:1.f];
    
    self.glowIcon.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.glowIcon.alpha = 1.f;
    [UIView animateWithDuration:1.5f delay:0.f options:UIViewAnimationOptionRepeat animations:^{
      self.glowIcon.transform = CGAffineTransformMakeScale(1.15, 1.15);
      self.glowIcon.alpha = 0.f;
    } completion:nil];
    
    [Globals bounceView:self fromScale:1.f toScale:1.25f];
  }
}

- (void) removeLabelAndGlow {
  self.nameLabel.hidden = YES;
  self.glowIcon.hidden = YES;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.transform = CGAffineTransformIdentity;
  }];
}

@end

@implementation AttackMapStatusView

- (void) updateForTaskId:(int)taskId element:(Element)elem level:(int)level isLocked:(BOOL)isLocked isCompleted:(BOOL)isCompleted {
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *task = [gs taskWithId:taskId];
  
  NSString *file = !isLocked ? [Globals imageNameForElement:elem suffix:@"dailylab.png"] : @"lockeddailylab.png";
  self.bgdImage.image = [Globals imageNamed:file];
  
  self.topLabel.text = task.name;
  self.bottomLabel.text = isLocked ? @"LOCKED" : isCompleted ? @"COMPLETED" : @"UNDEFEATED";
  self.sideLabel.text = [NSString stringWithFormat:@"LEVEL %d", level];
  
  [self.greyscaleView removeFromSuperview];
  if (isLocked) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.enterButtonView]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    self.greyscaleView.userInteractionEnabled = YES;
    [self.enterButtonView addSubview:self.greyscaleView];
  }
  
  self.taskId = taskId;
}

@end

@implementation AttackEventView

- (void) awakeFromNib {
  self.cooldownView.frame = self.enterView.frame;
  [self.enterView.superview addSubview:self.cooldownView];
}

- (void) updateForEvo {
  GameState *gs = [GameState sharedGameState];
  if (gs.myEvoChamber) {
    _eventType = PersistentEventProto_EventTypeEvolution;
    PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
    [self updateForPersistentEvent:pe];
  } else {
    self.hidden = YES;
  }
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  if (gs.myLaboratory) {
    _eventType = PersistentEventProto_EventTypeEnhance;
    PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
    [self updateForPersistentEvent:pe];
  } else {
    self.hidden = YES;
  }
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *imgs = [NSMutableArray array];
  float speed = 0.1;
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 16; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    speed = 0.08;
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  }
  
  self.monsterImage.animationImages = imgs;
  if (imgs.count > 0) self.monsterImage.image = imgs[0];
  
  self.monsterImage.animationDuration = imgs.count*speed;
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    NSString *file = [Globals imageNameForElement:pe.monsterElement suffix:@"dailylab.png"];
    self.bgdImage.image = [Globals imageNamed:file];
    
    self.topLabel.text = task.name;
    
    _persistentEventId = pe.eventId;
    self.taskId = pe.taskId;
    
    if (self.enhanceBubbleImage) {
      file = [Globals imageNameForElement:pe.monsterElement suffix:@"feederevent.png"];
      self.enhanceBubbleImage.image = [Globals imageNamed:file];
    }
    self.hidden = NO;
  } else {
    self.hidden = YES;
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
    self.bottomLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    MSDate *cdTime = pe.cooldownEndTime;
    timeLeft = [cdTime timeIntervalSinceNow];
    if (timeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
    } else {
      self.cooldownLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
      self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
      [Globals adjustViewForCentering:self.speedupGemsLabel.superview withLabel:self.speedupGemsLabel];
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.delegate eventViewSelected:self];
}

@end

@implementation MultiplayerView

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.multiplayerUnlockLabel.text = [NSString stringWithFormat:@"Multiplayer play\n unlocks at level %d", gl.pvpRequiredMinLvl];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.cashCostLabel.text = [NSString stringWithFormat:@"Match Cost: %@", [Globals cashStringForNumber:thp.pvpQueueCashCost]];
  
  self.backButton.alpha = 0.f;
  self.titleLabel.text = @"Multiplayer";
  
  //  for (LeagueDescriptionView *dv in self.leagueDescriptionViews) {
  //    PvpLeagueProto *pvp = [gs leagueForId:(int)dv.tag];
  //    [dv updateForLeague:pvp];
  //  }
}

- (void) updateForLeague {
  GameState *gs = [GameState sharedGameState];
  [self.leagueView updateForUserLeague:gs.pvpLeague ribbonSuffix:@"ribbon.png"];
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