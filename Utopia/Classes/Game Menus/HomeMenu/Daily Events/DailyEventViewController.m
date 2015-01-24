//
//  DailyEventViewController.m
//  Utopia
//
//  Created by Ashwin on 11/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "DailyEventViewController.h"
#import "DailyEventCornerView.h"

#import "PersistentEventProto+Time.h"

#import "GameState.h"
#import "Globals.h"

#import "GenericPopupController.h"
#import "GameViewController.h"

@implementation DailyEventView

- (void) layoutSubviews {
  [super layoutSubviews];
  
  self.bgdView.width = self.width-(self.height-self.bgdView.height);
  self.bgdView.centerX = self.width/2;
}

@end

@implementation DailyEventViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.characterIcon.transform = CGAffineTransformMakeScale(0.9, 0.9);
  
  self.nameLabel.gradientStartColor = [UIColor whiteColor];
  self.nameLabel.strokeSize = 1.f;
  self.nameLabel.shadowBlur = 0.5f;
  
  self.timeLabel.gradientStartColor = [UIColor whiteColor];
  self.timeLabel.strokeSize = 1.f;
  self.timeLabel.shadowBlur = 0.5f;
  
  self.cooldownView.frame = self.enterView.frame;
}

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
  if (!pe) {
    [self.parentViewController popViewControllerAnimated:YES];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  
  NSString *fileName = nil;
  NSString *description = nil;
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    fileName = [NSString stringWithFormat:@"6Scientist%dT1Character.png", (int)pe.monsterElement];
    
    UserStruct *us = gs.myEvoChamber;
    description = [NSString stringWithFormat:@"Scientists let you take your %@s to the next level. Combine 1 Max Level %@ with the same %@ (any level); add a Scientist of the same element and a dash of Oil into the %@ and see what emerges!", MONSTER_NAME, MONSTER_NAME, MONSTER_NAME, us.staticStruct.structInfo.name];
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    fileName = [NSString stringWithFormat:@"6CakeKid%dT1Character.png", (int)pe.monsterElement];
    
    description = [NSString stringWithFormat:@"Cake Kids give you the ultimate boost for enhancing characters. Their experience when sacrificed is unmatched by standard Skinny %@s™.", MONSTER_NAME];
  }
  
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:4];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
  self.descriptionLabel.attributedText = attributedString;
  
  [Globals imageNamed:fileName withView:self.characterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    NSString *file = [Globals imageNameForElement:pe.monsterElement suffix:@"eventbigbgcap.png"];
    UIImage *img = [Globals imageNamed:file];
    self.leftBgdCap.image = img;
    self.rightBgdCap.image = img;
    
    file = [Globals imageNameForElement:pe.monsterElement suffix:@"eventbigbg.png"];
    img = [Globals imageNamed:file];
    self.middleBgd.image = img;
    
    file = [Globals imageNameForElement:pe.monsterElement suffix:@"eventtag.png"];
    self.eventTagIcon.image = [Globals imageNamed:file];
    
    int idx = pe.monsterElement;
    if (idx <= 5 && idx >= 1) {
      self.nameLabel.gradientEndColor = [UIColor colorWithHexString:BottomGradientColor[idx]];
      self.nameLabel.strokeColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      self.nameLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      
      self.timeLabel.gradientEndColor = [UIColor colorWithHexString:BottomGradientColor[idx]];
      self.timeLabel.strokeColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      self.timeLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      
//      self.dateLabel.gradientEndColor = [UIColor colorWithHexString:BottomGradientColor[idx]];
//      self.dateLabel.strokeColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
//      self.dateLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      
      self.descriptionLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
      
      self.endsInLabel.shadowColor = [UIColor colorWithHexString:NameStrokeColor[idx]];
    }
    
//    self.dateLabel.text = [Globals stringOfCurDate];
    
    self.nameLabel.text = [task.name stringByAppendingString:@" Event"];
    self.title = self.nameLabel.text;
    
    _persistentEventId = pe.eventId;
  }
  
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs currentPersistentEventWithType:_eventType];
  
  if (_persistentEventId != pe.eventId) {
    if (_eventType == PersistentEventProto_EventTypeEnhance) {
      [self updateForEnhance];
    } else {
      [self updateForEvo];
    }
  } else {
    int timeLeft = [pe.endTime timeIntervalSinceNow];
    
    MSDate *cdTime = pe.cooldownEndTime;
    int cdTimeLeft = [cdTime timeIntervalSinceNow];
    if (cdTimeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
      
      self.endsInLabel.text = @"Ends In:";
      self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    } else {
      self.endsInLabel.text = @"Reenter In:";
      self.timeLabel.text = [[Globals convertTimeToShortString:cdTimeLeft] uppercaseString];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:cdTimeLeft allowFreeSpeedup:YES];
      
      if (speedupCost > 0) {
        self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
        [Globals adjustViewForCentering:self.speedupGemsLabel.superview withLabel:self.speedupGemsLabel];
        
        self.speedupGemsLabel.superview.hidden = NO;
        self.freeLabel.hidden = YES;
      } else {
        self.speedupGemsLabel.superview.hidden = YES;
        self.freeLabel.hidden = NO;
      }
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (IBAction)enterClicked:(UIView *)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    PersistentEventProto *pe = [gs persistentEventWithId:_persistentEventId];
    FullTaskProto *ftp = [gs taskWithId:pe.taskId];
    
    BOOL asked = NO;
    if (sender.tag) {
      
      int timeLeft = [pe.cooldownEndTime timeIntervalSinceNow];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
      
      if (speedupCost) {
        NSString *str = [NSString stringWithFormat:@"Would you like to enter %@ for %@ gems?", ftp.name, [Globals commafyNumber:speedupCost]];
        [GenericPopupController displayGemConfirmViewWithDescription:str title:[NSString stringWithFormat:@"Enter %@?", ftp.name] gemCost:speedupCost target:self selector:@selector(enterEventWithGems)];
        asked = YES;
      }
    }
    
    if (!asked) {
      //NSString *str = [NSString stringWithFormat:@"Would you like to enter %@?", ftp.name];
      //[GenericPopupController displayConfirmationWithDescription:str title:[NSString stringWithFormat:@"Enter %@?", ftp.name] okayButton:@"Enter" cancelButton:@"Cancel" target:self selector:@selector(enterEventWithoutGems)];
      [self enterEventWithoutGems];
    }
  }
}

- (void) enterEventWithGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs persistentEventWithId:_persistentEventId];
  
  int timeLeft = [pe.cooldownEndTime timeIntervalSinceNow];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems >= speedupCost) {
    [self enterEventConfirmedUseGems:YES];
  } else {
    [GenericPopupController displayNotEnoughGemsView];
  }
}

- (void) enterEventWithoutGems {
  [self enterEventConfirmedUseGems:NO];
}

- (void) enterEventConfirmedUseGems:(BOOL)useGems {
  [self.updateTimer invalidate];
  
  GameState *gs = [GameState sharedGameState];
  PersistentEventProto *pe = [gs persistentEventWithId:_persistentEventId];
  FullTaskProto *ftp = [gs taskWithId:pe.taskId];
  
  GameViewController *gvc = [GameViewController baseController];
  [gvc enterDungeon:ftp.taskId isEvent:YES eventId:_persistentEventId useGems:useGems];
  _buttonClicked = YES;
}

- (IBAction)scheduleClicked:(id)sender {
  DailyEventScheduleViewController *svc = [[DailyEventScheduleViewController alloc] init];
  [self.parentViewController pushViewController:svc animated:YES];
  [svc initWithEventType:_eventType];
}

@end
