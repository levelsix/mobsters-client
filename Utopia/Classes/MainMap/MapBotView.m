//
//  MapBotView.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MapBotView.h"
#import "cocos2d.h"
#import "Globals.h"

@implementation MapBotViewButton

- (void) awakeFromNib {
  self.actionLabel.shadowBlur = 0.53f;
  self.actionLabel.strokeSize = 0.9f;
  self.actionLabel.shadowOffset = CGSizeMake(0, 0.6f);
  self.actionLabel.strokeColor = [UIColor colorWithWhite:51/255.f alpha:1.f];
  self.actionLabel.gradientStartColor = [UIColor whiteColor];
  self.actionLabel.gradientEndColor = [UIColor colorWithWhite:233/255.f alpha:1.f];
}

+ (id) button {
  return [[NSBundle mainBundle] loadNibNamed:@"MapBotViewButton" owner:nil options:nil][0];
}

+ (id) sellButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingsell.png" actionText:[NSString stringWithFormat:@"Sell %@s", MONSTER_NAME] config:MapBotViewButtonSell];
  return button;
}

+ (id) bonusSlotsButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingbonusslots.png" actionText:@"Bonus Slots" config:MapBotViewButtonBonusSlots];
  return button;
}

+ (id) healButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingheal.png" actionText:[NSString stringWithFormat:@"Heal %@s", MONSTER_NAME] config:MapBotViewButtonHeal];
  return button;
}

+ (id) enhanceButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingenhance.png" actionText:@"Enhance" config:MapBotViewButtonEnhance];
  return button;
}

+ (id) evolveButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingevolve.png" actionText:@"Evolve" config:MapBotViewButtonEvolve];
  return button;
}

+ (id) teamButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingmanage.png" actionText:@"Manage Team" config:MapBotViewButtonTeam];
  return button;
}

+ (id) miniJobsButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingminijobs.png" actionText:@"Mini Jobs" config:MapBotViewButtonMiniJob];
  return button;
}

+ (id) infoButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildinginfo.png" actionText:@"Info" config:MapBotViewButtonInfo];
  return button;
}

+ (id) joinClanButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingsquad.png" actionText:@"Squads" config:MapBotViewButtonJoinClan];
  return button;
}

+ (id) clanHelpButton {
  MapBotViewButton *button = [self button];
  [button.bgdButton setImage:[Globals imageNamed:@"buildinggethelpbutton.png"] forState:UIControlStateNormal];
  [button.bgdButton setImage:[Globals imageNamed:@"buildinggethelpbuttonpressed.png"] forState:UIControlStateHighlighted];
  
  button.actionLabel.gradientEndColor = [UIColor colorWithHexString:@"fff6e8"];
  button.actionLabel.strokeColor = [UIColor colorWithHexString:@"7e2f00"];
  button.actionLabel.shadowColor = [UIColor colorWithRed:113/255.f green:45/255.f blue:0.f alpha:0.68f];
  
  button.actionIcon.centerY -= 2;
  
  [button updateWithImageName:@"buildinggethelp.png" actionText:@"Get Help!" config:MapBotViewButtonClanHelp];
  return button;
}

+ (id) removeButtonWithResourceType:(ResourceType)type removeCost:(int)removeCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingremove.png" actionText:@"Remove" config:MapBotViewButtonRemove];
  [button updateTopLabelForResourceType:type cost:removeCost];
  return button;
}

+ (id) upgradeButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingupgrade.png" actionText:@"Upgrade" config:MapBotViewButtonUpgrade];
  [button updateTopLabelForResourceType:type cost:buildCost];
  return button;
}

+ (id) fixButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"buildingfix.png" actionText:@"Fix" config:MapBotViewButtonFix];
  [button updateTopLabelForResourceType:type cost:buildCost];
  return button;
}

+ (id) speedupButtonWithGemCost:(int)gemCost {
  MapBotViewButton *button = [[NSBundle mainBundle] loadNibNamed:@"MapBotViewSpeedupButton" owner:nil options:nil][0];
  [button updateWithImageName:nil actionText:@"Speed Up!" config:MapBotViewButtonSpeedup];
  
  button.actionLabel.gradientEndColor = [UIColor colorWithHexString:@"f8e7ff"];
  button.actionLabel.strokeColor = [UIColor colorWithHexString:@"3d006c"];
  button.actionLabel.shadowColor = [UIColor colorWithRed:113/255.f green:45/255.f blue:0.f alpha:0.68f];
  
  THLabel *topLabel = nil;
  if (gemCost) {
    [button updateTopLabelForResourceType:ResourceTypeGems cost:gemCost];
    button.freeLabel.hidden = YES;
    
    //topLabel = button.topLabel;
  } else {
    //button.topLabel.superview.hidden = YES;
    
    button.actionIcon.hidden = YES;
    topLabel = button.freeLabel;
  }
  
  topLabel.gradientStartColor = button.actionLabel.gradientStartColor;
  topLabel.gradientEndColor = button.actionLabel.gradientEndColor;
  topLabel.strokeColor = button.actionLabel.strokeColor;
  topLabel.shadowColor = button.actionLabel.shadowColor;
  topLabel.strokeSize = button.actionLabel.strokeSize;
  topLabel.shadowOffset = button.actionLabel.shadowOffset;
  topLabel.shadowBlur = button.actionLabel.shadowBlur;
  
  return button;
}

- (void) updateWithImageName:(NSString *)imageName actionText:(NSString *)actionText config:(MapBotViewButtonConfig)config {
  if (imageName) [Globals imageNamed:imageName withView:self.actionIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.actionLabel.text = actionText;
  self.topLabel.superview.hidden = YES;
  self.config = config;
}

- (void) updateTopLabelForResourceType:(ResourceType)type cost:(int)cost {
  self.topLabel.text = [@" " stringByAppendingString:[Globals commafyNumber:cost]];
  [Globals adjustViewForCentering:self.topLabel.superview withLabel:self.topLabel];
  
  if (type == ResourceTypeCash) {
    self.topLabel.textColor = [UIColor colorWithRed:106/255.f green:181/255.f blue:0.f alpha:1.f];
  } else if (type == ResourceTypeOil) {
    self.topLabel.textColor = [UIColor colorWithRed:205/255.f green:167/255.f blue:27/255.f alpha:1.f];
  }
  
  self.cashIcon.hidden = type != ResourceTypeCash;
  self.oilIcon.hidden = type != ResourceTypeOil;
  
  self.topLabel.strokeSize = 1.f;
  
  self.topLabel.superview.hidden = NO;
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate mapBotViewButtonSelected:self];
}

@end

@implementation MapBotView

#define ANIMATION_SPEED 0.175f
#define ANIMATION_DELAY 0.085f

- (void) awakeFromNib {
  self.animateViews = [self.animateViews sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
    if (obj1.frame.origin.x < obj2.frame.origin.x) {
      return NSOrderedAscending;
    } else if (obj1.frame.origin.x > obj2.frame.origin.x) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  if (!self.animateViews) {
    self.animateViews = [NSArray array];
  }
}

- (void) update {
  if ([self.delegate respondsToSelector:@selector(updateMapBotView:)]) {
    [self.delegate updateMapBotView:self];
  }
}

- (void) animateIn:(void (^)())block {
  [self update];
  
  self.bgdView.alpha = 0.f;
  [UIView animateWithDuration:ANIMATION_SPEED+ANIMATION_DELAY*self.animateViews.count delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.bgdView.alpha = 1.f;
  } completion:nil];
  
  if (self.animateViews.count) {
    for (int i = 0; i < self.animateViews.count; i++) {
      UIView *v = [self.animateViews objectAtIndex:i];
      v.alpha = 0.f;
      v.center = ccp(v.center.x, v.superview.frame.size.height);
      
      BOOL isLast = self.animateViews.count-1 == i;
      [UIView animateWithDuration:ANIMATION_SPEED delay:ANIMATION_DELAY*i options:UIViewAnimationOptionCurveEaseInOut animations:^{
        v.alpha = 1.f;
        v.center = ccp(v.center.x, v.superview.frame.size.height-v.frame.size.height/2);
      } completion:^(BOOL finished) {
        if (block && isLast && finished) {
          block();
        }
      }];
    }
  } else {
    if (block) {
      block();
    }
  }
}

- (void) animateOut:(void (^)())block {
  [UIView animateWithDuration:ANIMATION_SPEED+ANIMATION_DELAY*self.animateViews.count delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.bgdView.alpha = 0.f;
  } completion:nil];
  
  if (self.animateViews.count) {
    for (int i = 0; i < self.animateViews.count; i++) {
      UIView *v = [self.animateViews objectAtIndex:i];
      BOOL isLast = self.animateViews.count-1 == i;
      [UIView animateWithDuration:ANIMATION_SPEED delay:ANIMATION_DELAY*i options:UIViewAnimationOptionCurveEaseInOut animations:^{
        v.alpha = 0.f;
        v.center = ccp(v.center.x, v.superview.frame.size.height);
      } completion:^(BOOL finished) {
        if (block && isLast && finished) {
          block();
        }
      }];
    }
  } else {
    if (block) {
      block();
    }
  }
}

- (void) addAnimateViewsToContainerView:(NSArray *)views {
  NSArray *arr = self.containerView.subviews;
  for (UIView *v in arr) {
    [v removeFromSuperview];
  }
  NSMutableArray *newAnim = [self.animateViews mutableCopy];
  [newAnim removeObjectsInArray:arr];
  
  float spaceBetween = 3.f;
  float curX = 0.f;
  for (UIView *v in views) {
    v.center = ccp(curX+v.frame.size.width/2, self.containerView.frame.size.height/2);
    curX += v.frame.size.width+spaceBetween;
    [self.containerView addSubview:v];
    
    [newAnim addObject:v];
  }
  self.animateViews = newAnim;
  
  CGRect r = self.containerView.frame;
  r.size.width = curX-spaceBetween;
  r.origin.x = self.containerView.superview.frame.size.width/2-r.size.width/2;
  self.containerView.frame = r;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if ([super pointInside:point withEvent:event]) {
    for (UIView *v in self.animateViews) {
      if (!v.hidden && v.userInteractionEnabled && [v pointInside:[self convertPoint:point toView:v] withEvent:event]) {
        return YES;
      }
    }
  }
  return NO;
}

@end