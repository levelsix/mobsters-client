
//
//  SettingSwitchButton.m
//  Utopia
//
//  Created by Danny on 9/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "SettingSwitchButton.h"
#import <QuartzCore/QuartzCore.h>

#define MOVE_DISTANCE 38.0f
@implementation SettingSwitchButton

- (void)awakeFromNib {
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOn)];
  swipe.direction = UISwipeGestureRecognizerDirectionRight;
  [self addGestureRecognizer:swipe];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOff)];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self addGestureRecognizer:swipe];
}

- (void)setOnOffPositon {
  if (self.isOn) {
    self.onOffSwitch.center = CGPointMake(self.onOffSwitch.center.x+MOVE_DISTANCE, self.onOffSwitch.center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x+MOVE_DISTANCE, self.offLabel.center.y);
    self.onLabel.center = CGPointMake(self.onLabel.center.x+MOVE_DISTANCE, self.onLabel.center.y);
  }
  else {
    self.onOffSwitch.center = CGPointMake(self.onOffSwitch.center.x, self.onOffSwitch.center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x, self.offLabel.center.y);
    self.onLabel.center = CGPointMake(self.onLabel.center.x, self.onLabel.center.y);
  }
}

- (void) turnOn {
  if (self.isOn) return;
  self.isOn = YES;
  [UIView animateWithDuration:0.15f animations:^{
    self.onOffSwitch.center = CGPointMake(self.onOffSwitch.center.x+MOVE_DISTANCE, self.onOffSwitch.center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x+MOVE_DISTANCE, self.offLabel.center.y);
    self.onLabel.center = CGPointMake(self.onLabel.center.x+MOVE_DISTANCE, self.onLabel.center.y);
  }];
  [self.delegate buttonTurnedOn:self];
}

- (void) turnOff {
  if (!self.isOn) return;
  self.isOn = NO;
  [UIView animateWithDuration:0.15f animations:^{
    self.onOffSwitch.center = CGPointMake(self.onOffSwitch.center.x-MOVE_DISTANCE, self.onOffSwitch.center.y);
    self.offLabel.center = CGPointMake(self.offLabel.center.x-MOVE_DISTANCE, self.offLabel.center.y);
    self.onLabel.center = CGPointMake(self.onLabel.center.x-MOVE_DISTANCE, self.onLabel.center.y);
  }];
  [self.delegate buttonTurnedOff:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  _initialTouch = pt;
  isTouched = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  isTouched = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (isTouched) {
    if (self.isOn) {
      [self turnOff];
    }
    else {
      [self turnOn];
    }
  }
  isTouched = NO;
}

@end
