//
//  BattleHudView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleHudView.h"

#import "Globals.h"
#import "GameViewController.h"

@implementation BattleElementView

- (void) awakeFromNib {
  self.layer.anchorPoint = ccp(0, 0.5);
  self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  BOOL inside = [super pointInside:point withEvent:event];
  if (!inside) {
    [self close];
  }
  return inside;
}

- (void) open {
  if (!self.layer.animationKeys) {
    [UIView animateWithDuration:0.15f animations:^{
      self.transform = CGAffineTransformMakeScale(1.f, 1.f);
    }];
  }
}

- (void) close {
  [UIView animateWithDuration:0.15f animations:^{
    self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
  }];
}

@end

@implementation BattleDeployCardView

- (void) updateForBattlePlayer:(BattlePlayer *)bp {
  if (!bp) {
    self.emptyView.hidden = NO;
    self.mainView.hidden = YES;
  } else {
    self.healthbar.percentage = bp.curHealth/(float)bp.maxHealth;
    self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    BOOL greyscale = bp.curHealth == 0;
    [self.monsterView updateForElement:bp.element imgPrefix:bp.spritePrefix greyscale:greyscale];
    
    self.emptyView.hidden = YES;
    self.mainView.hidden = NO;
  }
}

@end

@implementation BattleDeployView

- (void) updateWithBattlePlayers:(NSArray *)players {
  for (BattleDeployCardView *card in self.cardViews) {
    [card updateForBattlePlayer:nil];
    for (BattlePlayer *bp in players) {
      if (bp.slotNum == card.tag) {
        [card updateForBattlePlayer:bp];
      }
    }
  }
}

@end

@implementation BattleSkillCounterPopupView

- (void) displayWithSkillName:(NSString*)name description:(NSString*)desc counterLabel:(NSString*)counter orbDescription:(NSString*)orbDesc
              backgroundImage:(NSString*)bgImage orbImage:(NSString*)orbImage atPosition:(CGPoint)pos
{
  if (!self.hidden)
    return;
  
  [self.nameLabel setText:name];
  
  NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
  [paragrahStyle setLineSpacing:5.f];
  [paragrahStyle setAlignment:NSTextAlignmentCenter];
  [self.descLabel setAttributedText:[[NSAttributedString alloc] initWithString:desc attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }]];
  
  [self.background setImage:[UIImage imageNamed:bgImage]];
  
  static const CGFloat spacing = 5.f;
  
  if (orbImage != nil)
  {
    [self.orbIcon setImage:[UIImage imageNamed:orbImage]];
    [self.orbIcon setHidden:NO];
    
    if (counter != nil)
    {
      [self.orbDescriptionLabel setHidden:YES];
      
      [self.orbCounterLabel setText:counter];
      [self.orbCounterLabel sizeToFit];
      [self.orbCounterLabel setHidden:NO];
      
      // Align orb icon and counter horizontally in container and vertically to each other
      [self.orbIcon setOriginX:(self.width - (self.orbCounterLabel.width + self.orbIcon.width + spacing)) * .5f];
      [self.orbCounterLabel setOriginX:CGRectGetMaxX(self.orbIcon.frame) + spacing];
      [self.orbCounterLabel setOriginY:self.orbIcon.originY + (self.orbIcon.height - self.orbCounterLabel.height) * .5f];
    }
    else
    {
      [self.orbCounterLabel setHidden:YES];
      
      [self.orbDescriptionLabel setText:orbDesc];
      [self.orbDescriptionLabel sizeToFit];
      [self.orbDescriptionLabel setHidden:NO];
      
      // Align orb icon and description horizontally in container and vertically to each other
      [self.orbIcon setOriginX:(self.width - (self.orbDescriptionLabel.width + self.orbIcon.width + spacing)) * .5f];
      [self.orbDescriptionLabel setOriginX:CGRectGetMaxX(self.orbIcon.frame) + spacing];
      [self.orbDescriptionLabel setOriginY:self.orbIcon.originY + (self.orbIcon.height - self.orbDescriptionLabel.height) * .5f];
    }
  }
  else
  {
    [self.orbIcon setHidden:YES];
    [self.orbCounterLabel setHidden:YES];
    
    [self.orbDescriptionLabel setText:orbDesc];
    [self.orbDescriptionLabel sizeToFit];
    [self.orbDescriptionLabel setHidden:NO];
    
    // Align orb description horizontally in container
    [self.orbDescriptionLabel setOriginX:(self.width - self.orbDescriptionLabel.width) * .5f];
  }
  
  [self setOrigin:ccp(pos.x - self.bounds.size.width * .5f, MAX(pos.y - self.bounds.size.height, 5.f))];
  [self setHidden:NO];
  
  [Globals bounceView:self fadeInBgdView:nil anchorPoint:CGPointMake(.5f, 1.f) completion:^(BOOL finished) {
    if (self.parentView) [self.parentView skillPopupDisplayed];
  }];
}

- (void) hide
{
  if (self.hidden)
    return;
  
  [Globals shrinkView:self fadeOutBgdView:nil completion:^{
    [self setHidden:YES];
    [self.layer setTransform:CATransform3DIdentity];
  }];
}

@end

@implementation BattleHudView

- (void) awakeFromNib {
  self.swapView.hidden = YES;
  self.deployView.hidden = YES;
  self.bottomView.hidden = YES;
  self.elementButton.hidden = YES;
  self.battleScheduleView.hidden = YES;
  
  self.elementView.center = ccp(CGRectGetMaxX(self.elementButton.frame), self.elementView.center.y);
  
  self.waveNumLabel.shadowBlur = 1.f;
  self.waveNumLabel.gradientStartColor = [UIColor whiteColor];
  self.waveNumLabel.gradientEndColor = [UIColor colorWithWhite:233/255.f alpha:1.f];
  self.waveNumLabel.alpha = 0.f;
  
  self.swapLabel.text = [NSString stringWithFormat:@"Select a %@ to Deploy:", MONSTER_NAME];
}

- (void) removeButtons {
  [self removeSwapButtonAnimated:YES];
  [self removeDeployView];
  self.forfeitButtonView.hidden = YES;
  self.elementButton.hidden = YES;
  [self.elementView close];
}

- (void) prepareForMyTurn {
  [self displaySwapButton];
  self.forfeitButtonView.hidden = NO;
  self.elementButton.hidden = NO;
}

#define ANIMATION_TIME 0.4f

- (void) displaySwapButton {
  self.swapView.hidden = NO;
  self.swapView.center = ccp(-self.swapView.frame.size.width/2, self.swapView.center.y);
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    self.swapView.center = ccp(self.swapView.frame.size.width/2, self.swapView.center.y);
  }];
}

- (void) removeSwapButtonAnimated:(BOOL)animated {
  [UIView animateWithDuration:animated ? ANIMATION_TIME : 0.f animations:^{
    self.swapView.center = ccp(-self.swapView.frame.size.width/2, self.swapView.center.y);
  } completion:^(BOOL finished) {
    self.swapView.hidden = YES;
  }];
}

- (void) displayDeployViewToCenterX:(float)centerX cancelTarget:(id)target selector:(SEL)selector {
  self.deployView.hidden = NO;
  self.deployView.originY = self.bottomView.originY+self.bottomView.height-self.deployView.height;
  self.deployView.centerX = -self.deployView.frame.size.width/2;
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    self.deployView.center = ccp(centerX, self.deployView.center.y);
    
    self.bottomView.alpha = 0.f;
  } completion:^(BOOL finished) {
    if (finished && target) {
      self.deployCancelButton = [[UIButton alloc] initWithFrame:self.bounds];
      [self addSubview:self.deployCancelButton];
        [self.deployCancelButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
      
      [self.deployView.superview bringSubviewToFront:self.deployView];
    }
  }];
}

- (void) removeDeployView {
  if (!self.deployView.hidden && !self.deployView.layer.animationKeys.count) {
    [self.deployCancelButton removeFromSuperview];
    self.deployCancelButton = nil;
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      self.deployView.center = ccp(-self.deployView.frame.size.width/2, self.deployView.center.y);
      self.bottomView.alpha = 1.f;
    } completion:^(BOOL finished) {
      self.deployView.hidden = YES;
    }];
  }
}

- (IBAction)elementButtonClicked:(id)sender {
  [self.elementView open];
}

- (void) displayBattleScheduleView {
  
  if (self.schedulePosition.y == 0)
    self.schedulePosition = self.battleScheduleView.center;
  
  if (self.battleScheduleView.hidden) {
    self.battleScheduleView.hidden = NO;
    
    self.battleScheduleView.center = ccpAdd(self.schedulePosition, ccp(0, -100));
    [UIView animateWithDuration:0.3f animations:^{
      self.battleScheduleView.center = self.schedulePosition;
    }];
  }
}

- (void) removeBattleScheduleView {
  
  if (self.schedulePosition.y == 0)
    self.schedulePosition = self.battleScheduleView.center;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.battleScheduleView.center = ccpAdd(self.schedulePosition, ccp(0, -100));
  } completion:^(BOOL finished) {
    self.battleScheduleView.center = self.schedulePosition;
    
    if (finished) {
      self.battleScheduleView.hidden = YES;
    }
  }];
}

- (void) skillPopupDisplayed
{
  [self.skillPopupCloseButton setUserInteractionEnabled:YES];
}

- (IBAction) hideSkillPopup:(id)sender
{
  [self.skillPopupView hide];
  [self.skillPopupCloseButton setUserInteractionEnabled:NO];
}

@end
