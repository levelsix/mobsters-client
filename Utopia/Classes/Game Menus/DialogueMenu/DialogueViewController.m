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
#import "SoundEngine.h"

@implementation DialogueViewController

- (id) initWithDialogueProto:(DialogueProto *)dialogue {
  return [self initWithDialogueProto:dialogue useSmallBubble:NO];
}

- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble {
  return [self initWithDialogueProto:dialogue useSmallBubble:smallBubble buttonText:nil];
}

- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble buttonText:(NSString *)buttonText {
  if ((self = [super init])) {
    self.dialogue = dialogue;
    _useSmallBubble = smallBubble;
    _buttonText = buttonText;
    self.view.hidden = YES;
  }
  return self;
}

- (void) extendDialogue:(DialogueProto *)dialogue {
  DialogueProto_Builder *bldr = [DialogueProto builderWithPrototype:self.dialogue];
  [bldr addAllSpeechSegment:dialogue.speechSegmentList];
  self.dialogue = bldr.build;
}

- (void) viewDidLoad {
  if (_buttonText) {
    self.buttonLabel.text = _buttonText;
    
    [self.speechBubble addSubview:self.buttonView];
    self.buttonView.center = ccp(self.speakerLabel.superview.center.x, self.speechBubble.frame.size.height-2);
    
    CGRect r = self.speechBubble.frame;
    r.size.height = CGRectGetMaxY(self.buttonView.frame);
    self.speechBubble.frame = r;
    
    r = self.speakerLabel.superview.frame;
    r.size.height = CGRectGetMinY(self.buttonView.frame);
    self.speakerLabel.superview.frame = r;
  } else {
    self.buttonView.hidden = YES;
  }
  self.fbButtonView.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  self.speechBubble.layer.anchorPoint = ccp(0.f, 0.41758);
  self.speechBubble.center = ccpAdd(self.speechBubble.center, ccp(-self.speechBubble.frame.size.width/2,
                                                                  -self.speechBubble.frame.size.height*(0.5-self.speechBubble.layer.anchorPoint.y)));
  
  self.bottomGradient.alpha = 0.f;
  
  [self animateNext];
}

- (void) setDialogueLabelText:(NSString *)text {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.2];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
  self.dialogueLabel.attributedText = attributedString;
}

- (void) animateNext {
  if (_isAnimating) return;
  
  self.view.hidden = NO;
  _isAnimating = YES;
  if (_curIndex < self.dialogue.speechSegmentList.count) {
    int thisIndex = _curIndex;
    
    DialogueProto_SpeechSegmentProto *oldSS = _curIndex > 0 ? self.dialogue.speechSegmentList[_curIndex-1] : nil;
    DialogueProto_SpeechSegmentProto *curSS = self.dialogue.speechSegmentList[_curIndex];
    
    if (oldSS.isLeftSide == curSS.isLeftSide && [oldSS.speaker isEqualToString:curSS.speaker]) {
      [self animateBubbleOutCompletion:^{
        if ([self.delegate respondsToSelector:@selector(dialogueViewController:willDisplaySpeechAtIndex:)]) {
          [self.delegate dialogueViewController:self willDisplaySpeechAtIndex:thisIndex];
        }
        
        self.speakerLabel.text = curSS.speaker;
        [self setDialogueLabelText:curSS.speakerText];
        [self animateBubbleIn];
      }];
    } else {
      void (^anim)(void) = ^{
        if ([self.delegate respondsToSelector:@selector(dialogueViewController:willDisplaySpeechAtIndex:)]) {
          [self.delegate dialogueViewController:self willDisplaySpeechAtIndex:thisIndex];
        }
        
        NSString *img = [curSS.speakerImage stringByAppendingString:@"Big.png"];
        UIColor *color = self.blackOutSpeakers ? [UIColor colorWithWhite:0.f alpha:1.f] : nil;
        [Globals imageNamed:img withView:self.leftImageView maskedColor:color indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
        
        self.speakerLabel.text = curSS.speaker;
        [self setDialogueLabelText:curSS.speakerText];
        
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
      if ([self.delegate respondsToSelector:@selector(dialogueViewControllerFinished:)]) {
        [self.delegate dialogueViewControllerFinished:self];
      }
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
    
    [UIView animateWithDuration:0.4f animations:^{
      self.bottomGradient.alpha = 0.f;
    }];
  }
}

- (void) showFbButtonView {
  self.speechBubbleImage.image = [Globals imageNamed:@"zarkbubble.png"];
  
  CGRect r = self.speechBubble.frame;
  r.size = self.speechBubbleImage.image.size;
  self.speechBubble.frame = r;
  
  [self.speechBubble addSubview:self.fbButtonView];
  self.fbButtonView.center = ccp(self.speakerLabel.superview.center.x, self.speechBubble.frame.size.height-2);
  self.fbButtonView.hidden = NO;
  self.fbButtonSpinner.hidden = YES;
  
  
  r = self.speechBubble.frame;
  r.size.height = CGRectGetMaxY(self.fbButtonView.frame);
  self.speechBubble.frame = r;
  
  r = self.speakerLabel.superview.frame;
  r.size.height = CGRectGetMinY(self.fbButtonView.frame);
  self.speakerLabel.superview.frame = r;
  
  r = self.speakerLabel.frame;
  r.origin.y -= 2;
  self.speakerLabel.frame = r;
  
  r = self.speechBubbleLine.frame;
  r.origin.y -= 4;
  self.speechBubbleLine.frame = r;
  
  r = self.dialogueLabel.frame;
  r.origin.y += 1;
  self.dialogueLabel.frame = r;
}

- (void) beginFbSpinning {
  self.fbButtonLabel.hidden = YES;
  self.fbButtonSpinner.hidden = NO;
  [self.fbButtonSpinner startAnimating];
  self.view.userInteractionEnabled = NO;
}

- (void) endFbSpinning {
  self.fbButtonLabel.hidden = NO;
  self.fbButtonSpinner.hidden = YES;
  self.view.userInteractionEnabled = YES;
}

#define IMAGE_BEGIN_SCALE .55
#define IMAGE_END_SCALE 1.f

- (void) animateIn:(BOOL)isLeftSide {
  if (isLeftSide) {
    self.view.transform = CGAffineTransformIdentity;
    self.dialogueLabel.transform = CGAffineTransformIdentity;
    self.speakerLabel.transform = CGAffineTransformIdentity;
    self.buttonView.transform = CGAffineTransformIdentity;
  } else {
    self.view.transform = CGAffineTransformMakeScale(-1, 1);
    self.dialogueLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.speakerLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.buttonView.transform = CGAffineTransformMakeScale(-1, 1);
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
    [self animateBubbleIn];
  }];
}

- (void) fadeOutBottomGradient {
  [UIView animateWithDuration:0.3f animations:^{
    // This will only do anything on first animation
    self.bottomGradient.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.bottomGradient.hidden = YES;
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
  
  [SoundEngine dialogueBoxOpen];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  _isAnimating = NO;
  
  self.speechBubble.transform = CGAffineTransformIdentity;
  
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

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.buttonView.hidden) {
    [self animateNext];
  }
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate dialogueViewControllerButtonClicked:self];
}

@end
