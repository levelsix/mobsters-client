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
#import "GameState.h"
#import "SoundEngine.h"

@implementation DialogueView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.allowClickThrough) {
    [self.delegate dialogueViewPointInsideChecked];
    return NO;
  }
  return [super pointInside:point withEvent:event];
}

@end

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
    _useSmallBubble = NO;//smallBubble;
    _buttonText = buttonText;
  }
  return self;
}

- (id) initWithBattleItemName:(BattleItemProto *)bip instruction:(NSString *)str {
  if ((self = [super init])) {
    _battleItem = bip;
    _battleItemInstruction = str;
  }
  return self;
}

- (void) extendDialogue:(DialogueProto *)dialogue {
  DialogueProto_Builder *bldr = [DialogueProto builderWithPrototype:self.dialogue];
  [bldr addAllSpeechSegment:dialogue.speechSegmentList];
  self.dialogue = bldr.build;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  if (_buttonText) {
    self.buttonLabel.text = _buttonText;
    self.buttonLabel.strokeColor = [UIColor colorWithRed:52/255.f green:108/255.f blue:4/255.f alpha:1.f];
    self.buttonLabel.shadowBlur = 0.9f;
    self.buttonLabel.strokeSize = 1.f;
    self.buttonLabel.gradientEndColor = [UIColor colorWithRed:1.f green:1.f blue:215/255.f alpha:1.f];
    self.buttonLabel.gradientStartColor = [UIColor whiteColor];
    
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
  
  if (_battleItem) {
    
    DialogueProto_SpeechSegmentProto_Builder *bldr = [DialogueProto_SpeechSegmentProto builder];
    bldr.isLeftSide = YES;
    bldr.speaker = _battleItem.name;
    bldr.speakerText = _battleItemInstruction;
    
    [Globals imageNamed:_battleItem.imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.dialogue = [[[DialogueProto builder] addSpeechSegment:bldr.build] build];
    
    self.itemSpeechBubble.centerY = self.speechBubble.centerY;
    
    // Different rocks and leaves
    {
      for (UIView *sv in self.bottomGradient.subviews) {
        [sv removeFromSuperview];
      }
      
      UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"minileaves.png"]];
      [self.bottomGradient addSubview:img];
      img.originY = self.bottomGradient.height-img.height+10.f;
      img.originX = -42;
      
      img = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"minirocks.png"]];
      [self.bottomGradient addSubview:img];
      img.originY = self.bottomGradient.height-img.height+10.f;
      img.originX = -42;
      
      self.leftImageView.image = [Globals imageNamed:@"girl2.png"];
      self.leftImageView.originX = 3.f;
      
      if ([Globals isSmallestiPhone]) {
        self.itemSpeechBubbleImage.highlighted = YES;
        
        self.itemSpeechBubble.width = self.itemSpeechBubbleImage.highlightedImage.size.width;
        
        self.itemIcon.superview.hidden = YES;
        
        self.itemNameLabel.originX = self.itemIcon.superview.originX+3.f;
        self.itemNameLabel.originY -= 6.f;
        self.itemInstructionLabel.originY -= 3.f;
        self.itemInstructionLabel.originX = self.itemNameLabel.originX;
        self.itemInstructionLabel.width = self.itemInstructionLabel.superview.width-2*self.itemInstructionLabel.originX;
        
        self.itemSpeechBubble.centerX = 106.f;
        self.itemSpeechBubble.centerY = self.itemSpeechBubble.superview.height-35.f;
      } else {
        self.itemSpeechBubble.centerX = 162.f;
        self.itemSpeechBubble.centerY = self.itemSpeechBubble.superview.height-39.f;
      }
    }
    
    self.speechBubble.hidden = YES;
    
    self.speechBubble = self.itemSpeechBubble;
    self.speakerLabel = self.itemNameLabel;
    self.dialogueLabel = self.itemInstructionLabel;
    
    self.speechBubble.layer.anchorPoint = ccp(0.f, 0.4917);
  } else {
    self.itemSpeechBubble.hidden = YES;
    
    self.speechBubble.layer.anchorPoint = ccp(0.f, 0.41758);
  }
  
  self.speechBubble.center = ccpAdd(self.speechBubble.center, ccp(-self.speechBubble.frame.size.width/2,
                                                                  -self.speechBubble.frame.size.height*(0.5-self.speechBubble.layer.anchorPoint.y)));
  
  self.view.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.bottomGradient.alpha = 0.f;
  
  [self animateNext];
}

- (void) setDialogueLabelText:(NSString *)text {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:2.6];
  [paragraphStyle setAlignment:self.dialogueLabel.textAlignment];
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
    
    if (oldSS.isLeftSide == curSS.isLeftSide && [oldSS.speaker isEqualToString:curSS.speaker] && !self.paused) {
      [self animateBubbleOutCompletion:^{
        if ([self.delegate respondsToSelector:@selector(dialogueViewController:willDisplaySpeechAtIndex:)]) {
          [self.delegate dialogueViewController:self willDisplaySpeechAtIndex:thisIndex];
        }
        
        if (curSS.hasSpeakerImage && ![oldSS.speakerImage isEqualToString:curSS.speakerImage]) {
          NSString *img = [curSS.speakerImage stringByAppendingString:@"Big.png"];
          UIColor *color = self.blackOutSpeakers ? [UIColor colorWithWhite:0.f alpha:1.f] : nil;
          [Globals imageNamed:img withView:self.leftImageView maskedColor:color indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
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
        
        if (curSS.hasSpeakerImage) {
          NSString *img = [curSS.speakerImage stringByAppendingString:@"Big.png"];
          UIColor *color = self.blackOutSpeakers ? [UIColor colorWithWhite:0.f alpha:1.f] : nil;
          [Globals imageNamed:img withView:self.leftImageView maskedColor:color indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
        }
        
        self.speakerLabel.text = curSS.speaker;
        [self setDialogueLabelText:curSS.speakerText];
        
        [self animateIn:curSS.isLeftSide];
      };
      
      if (_curIndex > 0 && !self.paused) {
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
    
    [self fadeOutBottomGradient];
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
  self.leftImageView.alpha = 1.f;
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
    
    [self fadeOutBottomGradient];
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
  
  BOOL isGood = CGAffineTransformIsIdentity(self.view.transform);
  [SoundEngine dialogueBoxOpenIsGood:isGood];
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
    self.speechBubble.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    self.speechBubble.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.speechBubble.transform = CGAffineTransformIdentity;
    if (completion) {
      completion();
    }
  }];
}

- (void) pauseAndHideSpeakers {
  [UIView animateWithDuration:.3f animations:^{
    self.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self animateOut:nil];
  }];
  self.paused = YES;
}

- (void) continueAndRevealSpeakers {
  self.leftImageView.alpha = 0.f;
  [UIView animateWithDuration:.3f animations:^{
    self.view.alpha = 1.f;
  }];
  [self animateNext];
  self.paused = NO;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.buttonView.hidden && !self.paused) {
    [self animateNext];
  }
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate dialogueViewControllerButtonClicked:self];
}

- (void) dialogueViewPointInsideChecked {
  [self animateNext];
}

- (void) allowClickThrough {
  [(DialogueView *)self.view setAllowClickThrough:YES];
}

- (void) disallowClickThrough {
  [(DialogueView *)self.view setAllowClickThrough:NO];
}

@end
