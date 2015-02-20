//
//  RequestPushNotificationViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "RequestPushNotificationViewController.h"
#import "Globals.h"
#import "GameState.h"

#define GREEN @"DEFFC2"
#define GREY @"C5C5C5"

@implementation RequestPushNotificationView

- (void) initFonts {
  self.cancelLabel.gradientStartColor = [UIColor whiteColor];
  self.cancelLabel.gradientEndColor = [UIColor colorWithHexString:GREY];
  self.cancelLabel.strokeSize = 1.f;
  self.cancelLabel.shadowBlur = 0.5f;
  
  self.acceptLabel.gradientStartColor = [UIColor whiteColor];
  self.acceptLabel.gradientEndColor = [UIColor colorWithHexString:GREEN];
  self.acceptLabel.strokeSize = 1.f;
  self.acceptLabel.shadowBlur = 0.5f;
  
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.paragragh.text];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.5];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.paragragh.text length])];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = [gs monsterWithId:gl.miniTutorialConstants.guideMonsterId];
  self.nameLabel.text = mp.displayName;
}

- (void) updateWithString:(NSString *) description {
  if(description) {
    self.paragragh.text = description;
  }
}

@end

@implementation RequestPushNotificationViewController

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.requestView fadeInBgdView:self.bgView];
}

- (id) initWithMessage:(NSString *) message {
  if ((self = [super init])) {
    _message = message;
  }
  return self;
}

- (void) viewDidLoad {
  RequestPushNotificationView *view = (RequestPushNotificationView *)self.view;
  [view updateWithString:_message];
  [view initFonts];
}

- (IBAction)clickedAccept:(id)sender {
  //close this popup after opening the confirm popup
  [Globals registerUserForPushNotifications];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:[Globals userConfimredPushNotificationsKey]];
  [self close];
  
}

- (IBAction)clickedCancel:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.requestView fadeOutBgdView:self.bgView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}
@end
