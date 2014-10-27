//
//  TutorialNameViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialNameViewController.h"
#import "GameState.h"
#import "Globals.h"

@implementation TutorialNameViewController

- (id) initWithName:(NSString *)name {
  if ((self = [super init])) {
    self.initialName = name;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.mainView.layer.cornerRadius = 6.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.nameTextField.text = self.initialName;
  [self.nameTextField becomeFirstResponder];
  
  self.bgdView.alpha = 0.f;
  CGPoint center = self.mainView.center;
  self.mainView.center = ccp(center.x, -self.mainView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.bgdView.alpha = 1.f;
    self.mainView.center = center;
  }];
}

- (IBAction)closeClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  NSString *name = self.nameTextField.text;
  if ([gl validateUserName:name]) {
    [self.delegate nameChosen:name];
    
    [self.nameTextField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
      self.bgdView.alpha = 0.f;
      self.mainView.center = ccp(self.mainView.center.x, -self.mainView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }];
  }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  if ([string rangeOfString:@"\n"].length == 0) {
    NSString *oldStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *str = [oldStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str.length <= gl.maxNameLength) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self closeClicked:nil];
  return NO;
}

@end
