//
//  DailyEventCornerView.m
//  Utopia
//
//  Created by Ashwin on 11/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "DailyEventCornerView.h"

#import <cocos2d.h>

#import "GameState.h"
#import "Globals.h"

#import "PersistentEventProto+Time.h"

@implementation DailyEventCornerView

- (void) awakeFromNib {
  self.gradientView.superview.layer.cornerRadius = 6.f;
  self.gradientView.height -= 0.5;
  
  self.characterIcon.layer.anchorPoint = ccp(0.5, 1.f);
  self.characterIcon.originY += self.characterIcon.height/2-0.5;
  self.characterIcon.layer.transform = CATransform3DMakeScale(0.73, 0.73, 1.f);
  _initCharCenterX = self.characterIcon.centerX;
  
  _initTimeLabelX = self.timeLabel.centerX;
  
  self.nameLabel.gradientStartColor = [UIColor whiteColor];
  self.nameLabel.strokeSize = 0.5f;
  self.nameLabel.shadowBlur = 0.5f;
  
  self.timeLabel.strokeSize = 1.f;
  self.timeLabel.strokeColor = [UIColor whiteColor];
  self.timeLabel.shadowBlur = 0.9f;
}

- (void) updateForEvo {
  GameState *gs = [GameState sharedGameState];
  
  _eventType = PersistentEventProto_EventTypeEvolution;
  
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
  [self updateForPersistentEvent:pe greyscaleString:nil];
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  
  _eventType = PersistentEventProto_EventTypeEnhance;
  
  NSString *str = nil;
  if (![Globals shouldShowFatKidDungeon]) {
    UserStruct *us = gs.myLaboratory;
    str = [NSString stringWithFormat:@" Requires LVL%d %@", FAT_KID_DUNGEON_LEVEL, [us.staticStruct.structInfo.name substringToIndex:3]];
  }
  
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
  [self updateForPersistentEvent:pe greyscaleString:str];
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe greyscaleString:(NSString *)greyscaleString {
  BOOL greyscale = greyscaleString != nil;
  
  GameState *gs = [GameState sharedGameState];
  
  MSDate *cdTime = pe.cooldownEndTime;
  int cdTimeLeft = [cdTime timeIntervalSinceNow];
  
  if (!greyscale) {
    if (cdTimeLeft <= 0) {
      NSMutableArray *imgs = [NSMutableArray array];
      float speed = 0.1;
      if (pe.type == PersistentEventProto_EventTypeEvolution) {
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", (int)pe.monsterElement, i];
          UIImage *img = [Globals imageNamed:str];
          [imgs addObject:img];
        }
        for (int i = 0; i <= 12; i++) {
          // Repeat breath
          [imgs addObject:imgs[i]];
        }
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", (int)pe.monsterElement, i];
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
          NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", (int)pe.monsterElement, i];
          UIImage *img = [Globals imageNamed:str];
          [imgs addObject:img];
        }
        speed = 0.08;
      } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", (int)pe.monsterElement, i];
          UIImage *img = [Globals imageNamed:str];
          [imgs addObject:img];
        }
      }
      
      self.characterIcon.animationImages = imgs;
      if (imgs.count > 0) self.characterIcon.image = imgs[0];
      
      self.characterIcon.animationDuration = imgs.count*speed;
      
      if (!self.characterIcon.isAnimating) {
        [self.characterIcon startAnimating];
      }
    } else {
      if (pe.type == PersistentEventProto_EventTypeEvolution) {
        NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, 0];
        UIImage *img = [Globals imageNamed:str];
        self.characterIcon.image = img;
      } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
        NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", pe.monsterElement, 0];
        UIImage *img = [Globals imageNamed:str];
        self.characterIcon.image = img;
      }
    }
  } else {
    NSString *file = [Globals imageNameForElement:ElementRock suffix:@"cakekid.png"];
    self.characterIcon.image = [Globals imageNamed:file];
  }
  
  if (pe.type == PersistentEventProto_EventTypeEnhance) {
    self.characterIcon.centerX = _initCharCenterX+10;
  }
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    int idx = greyscale ? ElementRock : pe.monsterElement;
    
    NSString *file = [Globals imageNameForElement:idx suffix:@"eventbg.png"];
    self.gradientView.image = [Globals imageNamed:file];
    
    file = [Globals imageNameForElement:idx suffix:@"eventtag.png"];
    self.eventTagIcon.image = [Globals imageNamed:file];
    
    if (!greyscale) {
      file = [Globals imageNameForElement:idx suffix:@"eventtimer.png"];
      self.timerIcon.image = [Globals imageNamed:file];
    } else {
      self.timerIcon.hidden = YES;
      self.timeLabel.centerX = _initTimeLabelX - self.timerIcon.width;
      self.timeLabel.text = greyscaleString;
    }
    
    if (idx <= ElementRock && idx >= ElementFire) {
      self.nameLabel.gradientEndColor = [UIColor colorWithHexString:BottomGradientColor[idx]];
      self.nameLabel.strokeColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      self.nameLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      
      self.timeLabel.gradientStartColor = [UIColor colorWithHexString:TimeTopColor[idx]];
      self.timeLabel.gradientEndColor = [UIColor colorWithHexString:TimeBotColor[idx]];
      self.timeLabel.shadowColor = [UIColor colorWithHexString:[NameStrokeColor[idx] stringByAppendingString:@"c0"]];
    }
    
    self.nameLabel.text = [@" " stringByAppendingString:task.name];
    
    _persistentEventId = pe.eventId;
    
    [self updateLabels];
    
    self.hidden = NO;
  } else {
    _persistentEventId = 0;
    self.hidden = YES;
  }
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  PersistentEventProto *pe = [gs currentPersistentEventWithType:_eventType];
  
  if (_persistentEventId != pe.eventId) {
    if (_eventType == PersistentEventProto_EventTypeEnhance) {
      [self updateForEnhance];
    } else {
      [self updateForEvo];
    }
  } else if (!self.timerIcon.hidden) {
    int timeLeft = [pe.endTime timeIntervalSinceNow];
    
    MSDate *cdTime = pe.cooldownEndTime;
    int cdTimeLeft = [cdTime timeIntervalSinceNow];
    
    if (cdTimeLeft <= 0) {
      self.timeLabel.text = [@" " stringByAppendingString:[[Globals convertTimeToShortString:timeLeft] uppercaseString]];
    } else {
      self.timeLabel.text = [@" Reenter: " stringByAppendingString:[[Globals convertTimeToShortString:cdTimeLeft] uppercaseString]];
    }
  }
}

- (IBAction)buttonClicked:(id)sender {
  [self.delegate eventCornerViewClicked:self];
}

@end
