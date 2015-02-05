//
//  DonateMsgViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "DonateMsgViewController.h"

#import "Globals.h"

@interface DonateMsgViewController ()

@end

@implementation DonateMsgViewController

- (id) initWithInitialMessage:(NSString *)msg {
  if ((self = [super init])) {
    _initMsg = msg;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.msgTextView.text = _initMsg;
  
  self.headerView.layer.cornerRadius = self.mainView.layer.cornerRadius;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  self.bgdView.alpha = 0.f;
  self.mainView.originY = -self.mainView.height;
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.centerY = self.view.height/2;
    self.bgdView.alpha = 1.f;
  }];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)sendClicked:(id)sender {
  if (!_isClosing) {
    NSString *text = self.msgTextView.text;
    [self.delegate sendClickedWithMessage:text];
    [self close];
  }
}

- (IBAction)cancelClicked:(id)sender {
  [self.delegate cancelClicked];
  [self close];
}

- (void) close {
  if (!_isClosing) {
    _isClosing = YES;
    [self.msgTextView resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
      self.mainView.originY = -self.mainView.height;
      self.bgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
  }
}

#pragma mark - Keyboard Notifications

- (void) textViewDidBeginEditing:(UITextView *)textView {
  textView.text = nil;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  int maxNumLines = 3;
  
  NSMutableString *t = [NSMutableString stringWithString:textView.text];
  [t replaceCharactersInRange:range withString:text];
  
  // First check for standard '\n' (newline) type characters.
  NSUInteger numberOfLines = 0;
  for (NSUInteger i = 0; i < t.length; i++) {
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember: [t characterAtIndex: i]]) {
      numberOfLines++;
    }
  }
  
  if (numberOfLines >= maxNumLines)
    return NO;
  
  
  // Now check for word wrapping onto newline.
  NSAttributedString *t2 = [[NSAttributedString alloc]
                            initWithString:[NSMutableString stringWithString:t] attributes:@{NSFontAttributeName:textView.font}];
  
  __block NSInteger lineCount = 0;
  
  CGFloat maxWidth   = textView.frame.size.width;
  
  NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
  NSLayoutManager *lm = [[NSLayoutManager alloc] init];
  NSTextStorage   *ts = [[NSTextStorage alloc] initWithAttributedString:t2];
  [ts addLayoutManager:lm];
  [lm addTextContainer:tc];
  [lm enumerateLineFragmentsForGlyphRange:NSMakeRange(0,lm.numberOfGlyphs)
                               usingBlock:^(CGRect rect,
                                            CGRect usedRect,
                                            NSTextContainer *textContainer,
                                            NSRange glyphRange,
                                            BOOL *stop)
   {
     lineCount++;
   }];
  
  return (lineCount <= maxNumLines);
}

- (void) keyboardWillShow:(NSNotification *)n {
  NSDictionary *userInfo = [n userInfo];
  CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  CGRect relFrame = [self.view convertRect:keyboardFrame fromView:nil];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:curve];
  [UIView setAnimationDuration:animationDuration];
  
  self.mainView.centerY = relFrame.origin.y/2;
  
  [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)n {
  if (!_isClosing) {
    NSDictionary *userInfo = [n userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:animationDuration];
    
    self.mainView.centerY = self.view.height/2;
    
    [UIView commitAnimations];
  }
}

@end
