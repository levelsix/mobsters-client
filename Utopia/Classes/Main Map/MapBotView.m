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

+ (id) button {
  return [[NSBundle mainBundle] loadNibNamed:@"MapBotViewButton" owner:nil options:nil][0];
}

+ (id) sellButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Sell Mobsters" config:MapBotViewButtonSell];
  return button;
}

+ (id) bonusSlotsButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Bonus Slots" config:MapBotViewButtonBonusSlots];
  return button;
}

+ (id) healButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Heal Mobsters" config:MapBotViewButtonHeal];
  return button;
}

+ (id) enhanceButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Enhance" config:MapBotViewButtonEnhance];
  return button;
}

+ (id) evolveButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Evolve" config:MapBotViewButtonEvolve];
  return button;
}

+ (id) teamButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Manage Team" config:MapBotViewButtonTeam];
  return button;
}

+ (id) miniJobsButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Mini Jobs" config:MapBotViewButtonMiniJob];
  return button;
}

+ (id) infoButton {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Info" config:MapBotViewButtonInfo];
  return button;
}

+ (id) removeButtonWithResourceType:(ResourceType)type removeCost:(int)removeCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Remove" config:MapBotViewButtonRemove];
  [button updateTopLabelForResourceType:type cost:removeCost];
  return button;
}

+ (id) upgradeButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Upgrade" config:MapBotViewButtonUpgrade];
  [button updateTopLabelForResourceType:type cost:buildCost];
  return button;
}

+ (id) fixButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost {
  MapBotViewButton *button = [self button];
  [button updateWithImageName:@"" actionText:@"Fix" config:MapBotViewButtonFix];
  [button updateTopLabelForResourceType:type cost:buildCost];
  return button;
}

+ (id) speedupButtonWithGemCost:(int)gemCost {
  MapBotViewButton *button = [[NSBundle mainBundle] loadNibNamed:@"MapBotViewSpeedupButton" owner:nil options:nil][0];
  [button updateWithImageName:@"" actionText:@"Finish Now" config:MapBotViewButtonSpeedup];
  [button updateTopLabelForResourceType:ResourceTypeGems cost:gemCost];
  button.topLabel.strokeSize = 0.f;
  return button;
}

- (void) updateWithImageName:(NSString *)imageName actionText:(NSString *)actionText config:(MapBotViewButtonConfig)config {
  [Globals imageNamed:imageName withView:self.actionIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.actionLabel.text = actionText;
  self.topLabel.superview.hidden = YES;
  self.config = config;
  
  self.actionLabel.strokeSize = 1.f;
  self.actionLabel.shadowBlur = 0.9f;
}

- (void) updateTopLabelForResourceType:(ResourceType)type cost:(int)cost {
  self.topLabel.text = [Globals commafyNumber:cost];
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
  
  float spaceBetween = 0.f;
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