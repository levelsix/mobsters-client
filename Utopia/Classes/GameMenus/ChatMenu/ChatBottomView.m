//
//  ChatBottomView.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ChatBottomView.h"
#import "cocos2d.h"
#import "Globals.h"
#import "GameState.h"

#define NUM_ROWS_DISPLAYED 2

@implementation ChatBottomLineView

- (void) awakeFromNib {
  self.monsterView.transform = CGAffineTransformMakeScale(0.45, 0.45);
}

- (void) updateForChatMessage:(id<ChatObject>)cm shouldShowDot:(BOOL)showDot scope:(ChatScope)scope{
  GameState *gs = [GameState sharedGameState];
  [self.monsterView updateForMonsterId:cm.sender.avatarMonsterId];
  self.nameLabel.text = [NSString stringWithFormat:@"%@%@: ", showDot ? @"    " : @"", cm.sender.name];
  
  TranslateLanguages displayLanguage = TranslateLanguagesNoTranslation;
  
  if (scope == ChatScopeGlobal) {
    displayLanguage = gs.globalTranslationOn ? gs.globalLanguage : TranslateLanguagesNoTranslation;
  } else if (scope == ChatScopePrivate) {
#warning I'm not sure that this userUuid is the Id i think it is
    NSNumber *savedTranslateOnNumber = [gs.privateTranslationOn valueForKey:cm.sender.userUuid];
    NSNumber *savedTranslateLanguageNumber = [gs.privateChatLanguages valueForKey:cm.sender.userUuid];
    
    TranslateLanguages savedLanguage = (TranslateLanguages)savedTranslateLanguageNumber.integerValue;
    BOOL savedTranslateOn = savedTranslateOnNumber.boolValue;

    displayLanguage = savedTranslateOn ? savedLanguage : TranslateLanguagesNoTranslation;
  }
  
  if (displayLanguage == TranslateLanguagesNoTranslation) {
    self.msgLabel.text = cm.message;
  } else if ([cm isKindOfClass:[ChatMessage class]]){
    ChatMessage *cMessage = (ChatMessage *)cm;
    for (TranslatedTextProto *ttp in cMessage.translatedTextProtos) {
      if (ttp.language == displayLanguage) {
        self.msgLabel.text = cm.message;
      }
    }
  } else {
    self.msgLabel.text = cm.message;
  }
  
  self.dotIcon.hidden = !showDot;
  
  self.msgLabel.textColor = [cm bottomViewTextColor];
  
  CGSize s = [self.nameLabel.text getSizeWithFont:self.nameLabel.font constrainedToSize:self.nameLabel.frame.size];
  CGRect r = self.msgLabel.frame;
  r.origin.x = self.nameLabel.frame.origin.x+s.width+1;
  r.size.width = self.frame.size.width-r.origin.x;
  self.msgLabel.frame = r;
}

- (NSString *) description {
  return self.msgLabel.text;
}

@end

@implementation ChatBottomView

- (void) awakeFromNib {
  self.unusedLineViews = [NSMutableArray array];
  self.currentLineViews = [NSMutableArray array];
  
  UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
  gr.direction = UISwipeGestureRecognizerDirectionLeft;
  [self addGestureRecognizer:gr];
  
  gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
  gr.direction = UISwipeGestureRecognizerDirectionRight;
  [self addGestureRecognizer:gr];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
  [self addGestureRecognizer:tap];
}

- (void) swipeLeft {
  if (_chatScope != ChatScopePrivate) {
    [self switchToScope:_chatScope+1 animated:YES];
  }
}

- (void) swipeRight {
  if (_chatScope != ChatScopeGlobal) {
    [self switchToScope:_chatScope-1 animated:YES];
  }
}

- (void) tap {
  [self.delegate bottomViewClicked];
}

#pragma mark - Open/Close view

- (void) openAnimated:(BOOL)animated {
  if (!self.isOpen) {
    float duration = animated ? 0.3f : 0.f;
    
    self.bgdView.hidden = NO;
    self.bgdView.alpha = 0.f;
    self.openedView.hidden = NO;
    
    self.openedView.center = ccp(self.openedView.center.x, self.frame.size.height+self.openedView.frame.size.height/2);
    self.closedView.center = ccp(self.closedView.center.x, self.frame.size.height-self.closedView.frame.size.height/2);
    [UIView animateWithDuration:duration animations:^{
      self.bgdView.alpha = 1.f;
      
      self.openedView.center = ccp(self.openedView.center.x, self.frame.size.height-self.openedView.frame.size.height/2);
      self.closedView.center = ccp(self.closedView.center.x, self.frame.size.height+self.closedView.frame.size.height/2);
    } completion:^(BOOL finished) {
      self.closedView.hidden = YES;
    }];
    
    self.isOpen = YES;
  }
}

- (void) closeAnimated:(BOOL)animated {
  if (self.isOpen) {
    float duration = animated ? 0.3f : 0.f;
    
    self.closedView.hidden = NO;
    
    self.openedView.center = ccp(self.openedView.center.x, self.frame.size.height-self.openedView.frame.size.height/2);
    self.closedView.center = ccp(self.closedView.center.x, self.frame.size.height+self.closedView.frame.size.height/2);
    [UIView animateWithDuration:duration animations:^{
      self.bgdView.alpha = 0.f;
      
      self.openedView.center = ccp(self.openedView.center.x, self.frame.size.height+self.openedView.frame.size.height/2);
      self.closedView.center = ccp(self.closedView.center.x, self.frame.size.height-self.closedView.frame.size.height/2);
    } completion:^(BOOL finished) {
      self.bgdView.hidden = YES;
      self.openedView.hidden = YES;
    }];
    
    self.isOpen = NO;
  }
}

- (IBAction) openClicked:(id)sender {
  [self openAnimated:YES];
}

- (IBAction) closeClicked:(id)sender {
  [self closeAnimated:YES];
}

#pragma mark - Populating fields

- (ChatBottomLineView *) getUnusedLineView {
  if (self.unusedLineViews.count > 0) {
    ChatBottomLineView *lv = self.unusedLineViews[0];
    [self.unusedLineViews removeObjectAtIndex:0];
    lv.alpha = 1.f;
    return lv;
  } else {
    [[NSBundle mainBundle] loadNibNamed:@"ChatBottomLineView" owner:self options:nil];
    
    CGRect r = self.lineView.frame;
    r.size.width = self.lineViewContainer.frame.size.width;
    self.lineView.frame = r;
    
    return self.lineView;
  }
}

- (ChatBottomLineView *) getLineViewForLineNum:(int)lineNum {
  id<ChatObject> cm = [self.delegate chatMessageForLineNum:lineNum scope:_chatScope];
  ChatBottomLineView *lv = [self getUnusedLineView];
  [lv updateForChatMessage:cm shouldShowDot:[self.delegate shouldShowUnreadDotForLineNum:lineNum scope:_chatScope] scope:_chatScope];
  [self.lineViewContainer addSubview:lv];
  return lv;
}

- (CGPoint) centerForLineView:(ChatBottomLineView *)lineView lineNum:(int)lineNum {
  if (_chatScope == ChatScopePrivate) {
    lineNum = NUM_ROWS_DISPLAYED-lineNum-1;
  } else {
    lineNum += NUM_ROWS_DISPLAYED-_numToDisplay;
  }
  CGPoint pt = ccp(self.lineViewContainer.frame.size.width/2, self.lineViewContainer.frame.size.height-(2*lineNum+1)/2.f*lineView.frame.size.height);
  return pt;
}

- (void) reloadPageControl {
  for (ChatScope i = ChatScopeGlobal; i <= ChatScopePrivate; i++) {
    NSString *filename = nil;
    if ([self.delegate shouldShowNotificationDotForScope:i]) {
      filename = @"newchatline.png";
    } else if (i == _chatScope) {
      filename = @"activechatline.png";
    } else {
      filename = @"inactivechatline.png";
    }
    
    if (filename) {
      UIImageView *iv = (UIImageView *)[self.pageControlView viewWithTag:i];
      iv.image = [Globals imageNamed:filename];
    }
  }
}

- (void) reloadData {
  while (self.currentLineViews.count > 0) {
    ChatBottomLineView *lv = [self.currentLineViews firstObject];
    [self.currentLineViews removeObject:lv];
    [lv removeFromSuperview];
    [self.unusedLineViews addObject:lv];
  }
  
  _numChats = [self.delegate numChatsAvailableForScope:_chatScope];
  _numToDisplay = MIN(_numChats, NUM_ROWS_DISPLAYED);
  
  if (_numToDisplay) {
    for (int i = 0; i < _numToDisplay; i++) {
      ChatBottomLineView *lv = [self getLineViewForLineNum:i];
      lv.center = [self centerForLineView:lv lineNum:i];
      [self.currentLineViews addObject:lv];
    }
    
    [self.emptyLabel removeFromSuperview];
    self.emptyLabel = nil;
  } else {
    [self createEmptyLabel];
  }
  
  [self reloadPageControl];
}

#pragma mark Animations

- (void) animateNewLinesInAndPhaseOutOldOnes {
  NSMutableArray *phasedOuts = [NSMutableArray array];
  for (int i = 0; i < self.currentLineViews.count; i++) {
    ChatBottomLineView *lv = self.currentLineViews[i];
    BOOL phasedOut = i >= NUM_ROWS_DISPLAYED;
    [UIView animateWithDuration:0.3f animations:^{
      lv.center = [self centerForLineView:lv lineNum:i];
      lv.alpha = phasedOut ? 0.f : 1.f;
    } completion:^(BOOL finished) {
      if (phasedOut) {
        [lv removeFromSuperview];
        [self.unusedLineViews addObject:lv];
      }
    }];
    
    if (phasedOut) {
      [phasedOuts addObject:lv];
    }
  }
  
  [self.currentLineViews removeObjectsInArray:phasedOuts];
  
  if (self.currentLineViews.count) {
    // Create a new reference so that we can deallocate it in completion block
    UILabel *label = self.emptyLabel;
    [UIView animateWithDuration:0.3f animations:^{
      label.alpha = 0.f;
    } completion:^(BOOL finished) {
      [label removeFromSuperview];
    }];
    self.emptyLabel = nil;
  }
}

- (void) reloadDataAnimated {
  int newNumChats = [self.delegate numChatsAvailableForScope:_chatScope];
  int numNew = MIN(newNumChats-_numChats, NUM_ROWS_DISPLAYED);
  _numChats = newNumChats;
  _numToDisplay = MIN(_numChats, NUM_ROWS_DISPLAYED);
  
  if (numNew > 0) {
    for (int i = numNew-1; i >= 0; i--) {
      ChatBottomLineView *lv = [self getLineViewForLineNum:i];
      lv.center = [self centerForLineView:lv lineNum:i-numNew];
      lv.alpha = 0.f;
      [self.currentLineViews insertObject:lv atIndex:0];
    }
    
    [self animateNewLinesInAndPhaseOutOldOnes];
  } else {
    // Leaving clan or private chat from someone you've talked to before..
    [self reloadData];
  }
  
  [self reloadPageControl];
}

#pragma Scope Switch

- (void) switchToScope:(ChatScope)scope animated:(BOOL)animated {
  if ([self.delegate respondsToSelector:@selector(willSwitchToScope:)]) {
    [self.delegate willSwitchToScope:scope];
  }
  
  CGPoint delta = ccp((float)scope-_chatScope, 0);
  _chatScope = scope;
  
  _numChats = [self.delegate numChatsAvailableForScope:_chatScope];
  _numToDisplay = MIN(_numChats, NUM_ROWS_DISPLAYED);
  
  float duration = animated ? 0.3f : 0.f;
  
  // Shift by delta
  for (ChatBottomLineView *lv in self.currentLineViews) {
    [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      lv.center = ccpAdd(lv.center, ccpCompMult(ccpMult(delta, -1), ccp(self.openedView.frame.size.width, 0)));
    } completion:^(BOOL finished) {
      [lv removeFromSuperview];
      [self.unusedLineViews addObject:lv];
    }];
  }
  [self.currentLineViews removeAllObjects];
  
  // Move the empty label as well
  if (self.emptyLabel) {
    // Create a new reference so that we can deallocate it in completion block
    UILabel *label = self.emptyLabel;
    [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      label.center = ccpAdd(label.center, ccpCompMult(ccpMult(delta, -1), ccp(self.openedView.frame.size.width, 0)));
    } completion:^(BOOL finished) {
      [label removeFromSuperview];
    }];
    self.emptyLabel = nil;
  }
  
  if (_numToDisplay) {
    for (int i = 0; i < _numToDisplay; i++) {
      ChatBottomLineView *lv = [self getLineViewForLineNum:i];
      lv.center = ccpAdd([self centerForLineView:lv lineNum:i], ccpCompMult(delta, ccp(self.openedView.frame.size.width, 0)));
      
      [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        lv.center = [self centerForLineView:lv lineNum:i];
      } completion:nil];
      
      [self.currentLineViews addObject:lv];
    }
  } else {
    [self createEmptyLabel];
    
    CGPoint center = self.emptyLabel.center;
    self.emptyLabel.center = ccpAdd(center, ccpCompMult(delta, ccp(self.openedView.frame.size.width, 0)));
    
    [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.emptyLabel.center = center;
    } completion:nil];
  }
  
  [self performSelector:@selector(reloadPageControl) withObject:nil afterDelay:duration];
}

- (void) createEmptyLabel {
  [self.emptyLabel removeFromSuperview];
  
  CGRect r = CGRectZero;
  r.size.width = self.openedView.frame.size.width;
  r.size.height = self.lineViewContainer.frame.size.height;
  NiceFontLabel14B *label = [[NiceFontLabel14B alloc] initWithFrame:r];
  label.font = [UIFont systemFontOfSize:12.f];
  [label awakeFromNib];
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.8f];
  label.shadowOffset = CGSizeMake(0, 1);
  [self.lineViewContainer addSubview:label];
  
  CGPoint center = ccp(self.openedView.frame.size.width/2, self.lineViewContainer.frame.size.height/2);
  label.center = center;
  label.text = [self.delegate emptyStringForScope:_chatScope];
  self.emptyLabel = label;
}

@end
