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
  self.nameLabel.strokeSize = 1.2f;
  self.nameLabel.gradientStartColor = [UIColor colorWithRed:240/255.f green:253/255.f blue:152/255.f alpha:1.f];
  self.nameLabel.gradientEndColor = [UIColor colorWithRed:222/255.f green:251/255.f blue:72/255.f alpha:1.f];
  
  self.spinner.hidden = YES;
}

- (void)setIsLocked:(BOOL)isLocked {
  _isLocked = isLocked;
  if (isLocked) {
    [self.cityButton setImage:[UIImage imageNamed:@"lockedcitypin.png"] forState:UIControlStateNormal];
    self.cityNumLabel.hidden = YES;
  } else {
    [self.cityButton setImage:[UIImage imageNamed:@"opencitypin.png"] forState:UIControlStateNormal];
    self.cityNumLabel.hidden = NO;
  }
}

- (void) setCityNumber:(int)cityNumber {
  _cityNumber = cityNumber;
  self.cityNumLabel.text = [NSString stringWithFormat:@"%d", cityNumber];
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
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  _eventType = PersistentEventProto_EventTypeEnhance;
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
  [self updateForPersistentEvent:pe];
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
    
    self.nameLabel.text = task.name;
    
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
    self.timeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    MSDate *cdTime = pe.cooldownEndTime;
    timeLeft = [cdTime timeIntervalSinceNow];
    if (timeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
    } else {
      self.cooldownLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
      self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.delegate eventViewSelected:self];
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

- (void) updateForOldLeagueId:(int)oldLeagueId newLeagueId:(int)newLeagueId {
  GameState *gs = [GameState sharedGameState];
  PvpLeagueProto *oldLeague = [gs leagueForId:oldLeagueId];
  PvpLeagueProto *newLeague = [gs leagueForId:newLeagueId];
  
  if (oldLeagueId < newLeagueId) {
    self.topLabel.text = @"You've been promoted!";
  } else {
    self.topLabel.text = @"You've been demoted.";
  }
  
  self.botLabel.text = newLeague.leagueName;
  
  NSString *old = [oldLeague.imgPrefix stringByAppendingString:@"big.png"];
  [Globals imageNamed:old withView:self.oldLeagueIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  NSString *new = [newLeague.imgPrefix stringByAppendingString:@"big.png"];
  [Globals imageNamed:new withView:self.curLeagueIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
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
  self.multiplayerUnlockLabel.text = [NSString stringWithFormat:@"Multiplayer play\n unlocks at level %d", gl.pvpRequiredMinLvl];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.cashCostLabel.text = [NSString stringWithFormat:@"Match Cost: %@", [Globals cashStringForNumber:thp.pvpQueueCashCost]];
  
  self.backButton.alpha = 0.f;
  self.titleLabel.text = @"Multiplayer";
  
  for (LeagueDescriptionView *dv in self.leagueDescriptionViews) {
    PvpLeagueProto *pvp = [gs leagueForId:(int)dv.tag];
    [dv updateForLeague:pvp];
  }
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