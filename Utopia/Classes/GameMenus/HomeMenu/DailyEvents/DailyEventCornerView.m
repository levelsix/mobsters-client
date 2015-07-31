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
  
  _initTimeLabelX = self.timeLabel.originX;
  
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
  
  NSString *str = nil;
  if(!_nextEvent) {
    _nextEvent = [gs nextEventWithType:PersistentEventProto_EventTypeEvolution];
  }
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
  if(_nextEvent && !pe) {
    int nextTime = [_nextEvent.startTime timeIntervalSinceNow];
    pe = _nextEvent;
    str = [@" Opens in: " stringByAppendingString:[[Globals convertTimeToShortString:nextTime] uppercaseString]];
  }

  [self updateForPersistentEvent:pe greyscaleString:str];
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  
  _eventType = PersistentEventProto_EventTypeEnhance;
  
  NSString *str = nil;
  if(!_nextEvent) {
    _nextEvent = [gs nextEventWithType:PersistentEventProto_EventTypeEnhance];
  }
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
  
  if (![Globals shouldShowFatKidDungeon]) {
    UserStruct *us = gs.myLaboratory;
    str = [NSString stringWithFormat:@" Requires LVL%d %@", FAT_KID_DUNGEON_LEVEL, [us.staticStruct.structInfo.name substringToIndex:3]];
  } else if( _nextEvent && !pe) {
    pe = _nextEvent;
    int nextTime = [_nextEvent.startTime timeIntervalSinceNow];
    str = [@" Opens in: " stringByAppendingString:[[Globals convertTimeToShortString:nextTime] uppercaseString]];
  }
  
  [self updateForPersistentEvent:pe greyscaleString:str];
}

- (void) setStaticImageForEvent:(PersistentEventProto *)pe {
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", (int)pe.monsterElement, 0];
    [Globals imageNamed:str withView:self.characterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", (int)pe.monsterElement, 0];
    [Globals imageNamed:str withView:self.characterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe greyscaleString:(NSString *)greyscaleString {
  BOOL greyscale = greyscaleString != nil;
  
  GameState *gs = [GameState sharedGameState];
  
  MSDate *cdTime = pe.cooldownEndTime;
  int cdTimeLeft = [cdTime timeIntervalSinceNow];
  
  if (!greyscale) {
    [self setStaticImageForEvent:pe];
    
    if (cdTimeLeft <= 0) {
      NSMutableArray *imgNames = [NSMutableArray array];
      //NSMutableArray *imgs = [NSMutableArray array];
      float speed = 0.1;
      if (pe.type == PersistentEventProto_EventTypeEvolution) {
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", (int)pe.monsterElement, i];
          [imgNames addObject:str];
        }
        for (int i = 0; i <= 12; i++) {
          // Repeat breath
          [imgNames addObject:imgNames[i]];
        }
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", (int)pe.monsterElement, i];
          [imgNames addObject:str];
        }
        for (int i = 0; i <= 12; i++) {
          // Repeat breath
          [imgNames addObject:imgNames[i]];
        }
        for (int i = 0; i <= 12; i++) {
          // Repeat breath
          [imgNames addObject:imgNames[i]];
        }
        for (int i = 0; i <= 16; i++) {
          NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", (int)pe.monsterElement, i];
          [imgNames addObject:str];
        }
        speed = 0.08;
      } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
        for (int i = 0; i <= 12; i++) {
          NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", (int)pe.monsterElement, i];
          [imgNames addObject:str];
        }
      }
      
      NSArray *arr = [NSSet setWithArray:imgNames].allObjects;
      [Globals checkAndLoadFiles:arr useiPhone6Prefix:NO useiPadSuffix:NO completion:^(BOOL success) {
        if (success) {
          NSMutableArray *imgs = [NSMutableArray array];
          for (NSString *str in imgNames) {
            [imgs addObject:[Globals imageNamed:str]];
          }
          
          self.characterIcon.animationImages = imgs;
          if (imgs.count > 0) self.characterIcon.image = imgs[0];
          
          self.characterIcon.animationDuration = imgs.count*speed;
          
          if (!self.characterIcon.isAnimating) {
            [self.characterIcon startAnimating];
          }
        }
      }];
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
      self.timeLabel.originX = _initTimeLabelX - self.timerIcon.width;
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
    
    [self updateLabelsWithEvent:pe];
    
    self.hidden = NO;
  } else {
    _persistentEventId = 0;
    self.hidden = YES;
  }
}

- (void) updateLabelsWithEvent:(PersistentEventProto*)event {
  GameState *gs = [GameState sharedGameState];
  PersistentEventProto *pe;
  if (event) {
    pe = event;
  } else {
    pe = [gs currentPersistentEventWithType:_eventType];
  }
  
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

- (void) updateLabels {
  [self updateLabelsWithEvent:nil];
}

- (IBAction)buttonClicked:(id)sender {
  [self.delegate eventCornerViewClicked:self];
}

@end
