//
//  DialogueViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "DialogueViewController.h"
#import <cocos2d.h>
#import "CAKeyframeAnimation+AHEasing.h"
#import "Globals.h"

@implementation DialogueViewController

- (id) initWithDialogueProto:(DialogueProto *)dialogue {
  if ((self = [super init])) {
    self.dialogue = dialogue;
    self.view.hidden = YES;
  }
  return self;
}

- (void) viewDidAppear:(BOOL)animated {
  self.speechBubble.layer.anchorPoint = ccp(0.01, 0.407);
  self.speechBubble.center = ccpAdd(self.speechBubble.center, ccp(-self.speechBubble.frame.size.width/2, 0));
  
  self.bottomGradient.alpha = 0.f;
  
  [self animateNext];
}

- (void) animateNext {
  self.view.hidden = NO;
  _isAnimating = YES;
  if (_curIndex < self.dialogue.speechSegmentList.count) {
    if ([self.delegate respondsToSelector:@selector(dialogueViewController:willDisplaySpeechAtIndex:)]) {
      [self.delegate dialogueViewController:self willDisplaySpeechAtIndex:_curIndex];
    }
    
    DialogueProto_SpeechSegmentProto *oldSS = _curIndex > 0 ? self.dialogue.speechSegmentList[_curIndex-1] : nil;
    DialogueProto_SpeechSegmentProto *curSS = self.dialogue.speechSegmentList[_curIndex];
    
    if (oldSS.isLeftSide == curSS.isLeftSide && [oldSS.speaker isEqualToString:curSS.speaker]) {
      [self animateBubbleOutCompletion:^{
        self.dialogueLabel.text = curSS.speakerText;
        [self animateBubbleIn];
      }];
    } else {
      void (^anim)(void) = ^{
        NSString *img = [curSS.speaker stringByAppendingString:@"Big.png"];
        UIColor *color = self.blackOutSpeakers ? [UIColor colorWithWhite:0.f alpha:1.f] : nil;
        [Globals imageNamed:img withView:self.leftImageView maskedColor:color indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
        
        self.dialogueLabel.text = curSS.speakerText;
        
        [self animateIn:curSS.isLeftSide];
      };
      
      if (_curIndex > 0) {
        [self animateOut:anim];
      } else {
        anim();
      }
    }
    
    _curIndex++;
  } else {
    [self animateOut:^{
      [self.delegate dialogueViewControllerFinished:self];
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
    
    [UIView animateWithDuration:0.4f animations:^{
      self.bottomGradient.alpha = 0.f;
    }];
  }
}

#define IMAGE_BEGIN_SCALE .55
#define IMAGE_END_SCALE .70

- (void) animateIn:(BOOL)isLeftSide {
  if (isLeftSide) {
    self.view.transform = CGAffineTransformIdentity;
    self.dialogueLabel.transform = CGAffineTransformIdentity;
  } else {
    self.view.transform = CGAffineTransformMakeScale(-1, 1);
    self.dialogueLabel.transform = CGAffineTransformMakeScale(-1, 1);
  }
  
  CGPoint pt = self.leftImageView.center;
  self.leftImageView.center = ccpAdd(pt, ccp(-self.leftImageView.frame.size.width, self.leftImageView.frame.size.height/3));
  self.speechBubble.alpha = 0.f;
  self.leftImageView.transform = CGAffineTransformMakeScale(IMAGE_BEGIN_SCALE, IMAGE_BEGIN_SCALE);
  
  [UIView animateWithDuration:0.3f animations:^{
    self.leftImageView.transform = CGAffineTransformMakeScale(IMAGE_END_SCALE, IMAGE_END_SCALE);
    self.leftImageView.center = pt;
    
    // This will only do anything on first animation
    self.bottomGradient.alpha = 1.f;
  } completion:^(BOOL finished) {
    if (finished) {
      [self animateBubbleIn];
    }
  }];
}

- (void) animateOut:(void (^)(void))completion {
  [self animateBubbleOutCompletion:^{
    CGPoint pt = self.leftImageView.center;
    [UIView animateWithDuration:0.15f animations:^{
      self.leftImageView.center = ccpAdd(pt, ccp(-self.leftImageView.frame.size.width, self.leftImageView.frame.size.height/3));
      self.leftImageView.transform = CGAffineTransformMakeScale(IMAGE_BEGIN_SCALE, IMAGE_BEGIN_SCALE);
    } completion:^(BOOL finished) {
      self.leftImageView.transform = CGAffineTransformIdentity;
      self.leftImageView.center = pt;
      
      if (completion) {
        completion();
      }
    }];
  }];
}

- (void) animateBubbleIn {
  float duration = 0.3f;
  CAKeyframeAnimation *key = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
  NSArray *arr = @[@-17.86, @-13.84, @-10.3, @-6.85, @0, @1.54, @5.92, @7.89, @2.07, @0, @0.64, @2.22, @0];
  NSMutableArray *v = [NSMutableArray array];
  for (NSNumber *n in arr) {
    [v addObject:@(n.floatValue/180.f*M_PI)];
  }
  key.values = v;
  key.duration = duration;
  [self.speechBubble.layer addAnimation:key forKey:@"rotate"];
  
  key = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  key.values = @[@.2454, @.3585, @.4714, @.5714, @.7375, @.8192, @.9423, @1, @1, @1, @1, @1, @1];
  key.duration = duration;
  key.delegate = self;
  [self.speechBubble.layer addAnimation:key forKey:@"scale"];
  
  self.speechBubble.alpha = 0.f;
  [UIView animateWithDuration:duration/2 animations:^{
    self.speechBubble.alpha = 1.f;
  }];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  _isAnimating = NO;
  
  if ([self.delegate respondsToSelector:@selector(dialogueViewController:didDisplaySpeechAtIndex:)]) {
    [self.delegate dialogueViewController:self didDisplaySpeechAtIndex:_curIndex-1];
  }
}

- (void) animateBubbleOutCompletion:(void (^)(void))completion {
  [UIView animateWithDuration:0.17f animations:^{
    self.speechBubble.transform = CGAffineTransformMakeScale(0.f, 0.f);
    self.speechBubble.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.speechBubble.transform = CGAffineTransformIdentity;
    if (completion) {
      completion();
    }
  }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!_isAnimating) {
    [self animateNext];
  }
}

@end
