//
//  PrivateMessageNotificationViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 1/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PrivateMessageNotificationViewController.h"
#import "ChatObject.h"
#import "MonsterCardView.h"
#import "ChatBottomView.h"

#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

//#define LOWEST_LABEL_BOT_POINT 20.f
#define FIRST_AVATAR_OFFSET 14.f
#define TEXT_BUFFER_FROM_AVATAR 21.f
#define MAX_AVATAR_COUNT 5
#define AVATAR_VERTICAL_OFFSET 2.f

#define RED @"FF5A00"
#define GREEN @"A5F200"

@implementation PrivateMessageNotificationView

- (void) updateWithString:(NSString *)title description:(NSString *)description color:(UIColor *)color {
  [self updateWithString:title description:description];
  self.botLabel.textColor = color;
}

- (void) updateWithString:(NSString *)title description:(NSString *)description {
  [self.topLabel setText:title];
  [self.botLabel setText:description];
}

- (void) animateIn:(dispatch_block_t)completion {
  CGPoint pt = self.center;
  self.center = ccp(self.center.x, -self.frame.size.height/2);
  [UIView animateWithDuration:.56f
                        delay:0.f
       usingSpringWithDamping:0.79f
        initialSpringVelocity:3.f
                      options:UIViewAnimationOptionCurveLinear animations:^{
                        self.center = pt;
                      } completion:^(BOOL finished) {
                        if (completion) {
                          completion();
                        }
                      }];
}

- (void) animateOut:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.3f animations:^{
    self.center = ccp(self.center.x, -self.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    if (completion) {
      completion();
    }
  }];
}

@end


@implementation PrivateMessageNotificationViewController

- (id) initWithClanGifts:(NSArray *)userClanGifts isImmediate:(BOOL)isImmediate {
  _avatarOffSet = FIRST_AVATAR_OFFSET;
  
  if ((self = [super init])) {
    [[NSBundle mainBundle] loadNibNamed:@"PrivateMessageNotificationView" owner:self options:nil];
    
    UserClanGiftProto *ucgp = [userClanGifts firstObject];
    _messageFromSingleUser = (ChatMessage*)ucgp;
    
    if (userClanGifts.count > 1) {
      [self.notificationView updateWithString:ucgp.otherUser.name description:[NSString stringWithFormat:@"Sent you %d gifts!",(int)userClanGifts.count] color:[UIColor colorWithHexString:GREEN]];
    } else {
      [self.notificationView updateWithString:ucgp.otherUser.name description:@"Sent you a gift!" color:[UIColor colorWithHexString:GREEN]];
    }
    
    [self addAvatarWithMonsterId:ucgp.otherUser.avatarMonsterId];
    
    [self.notificationView.textView setOrigin:CGPointMake(_avatarOffSet+TEXT_BUFFER_FROM_AVATAR,0.f)];
    [self.notificationView.textView setWidth: self.view.width-_avatarOffSet+FIRST_AVATAR_OFFSET];
    
    _priority = isImmediate ? NotificationPriorityImmediate : NotificationPriorityRegular;
  }
  return self;
}

- (id) initWithMessages:(NSArray *)allMessages isImmediate:(BOOL)isImmediate {
  GameState *gs = [GameState sharedGameState];
  _avatarOffSet = FIRST_AVATAR_OFFSET;

  if ((self = [super init])) {
    [[NSBundle mainBundle] loadNibNamed:@"PrivateMessageNotificationView" owner:self options:nil];
    
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    for(ChatMessage *message in allMessages) {
      [messageDict setObject:message forKey:message.sender.userUuid];
    }
    //message list compressed to only have 1 message from each user
    NSArray *messages = [messageDict allValues];
    
    if(messages.count == 1) {
      
      id<ChatObject> chat = [messages firstObject];
      if ([chat isKindOfClass:[PvpHistoryProto class] ] ) {
        PvpHistoryProto *php = [messages firstObject];
        _messageFromSingleUser = (ChatMessage *)chat;
        
        NSString *result = [NSString stringWithFormat:@"%@ you in battle", php.userWon ? @"Lost to" : @"Defeated"];
        UIColor *textColor = php.userWon ? [UIColor colorWithHexString:GREEN] : [UIColor colorWithHexString:RED];
        
        [self.notificationView updateWithString:php.otherUser.name description:result color:textColor];
        [self addAvatarWithMonsterId:php.otherUser.avatarMonsterId];
        
      } else if ([chat isKindOfClass:[UserClanGiftProto class]]) {
        UserClanGiftProto *ucgp = [messages firstObject];
        _messageFromSingleUser = (ChatMessage*)chat;
        
        [self.notificationView updateWithString:ucgp.otherUser.name description:@"Sent you a gift!" color:[UIColor colorWithHexString:GREEN]];
        [self addAvatarWithMonsterId:ucgp.otherUser.avatarMonsterId];
      } else {
        PrivateChatPostProto *pcpp = [messages firstObject];
        _messageFromSingleUser = pcpp;
        
        NSString *userUuid = pcpp.sender.userUuid;
        TranslateLanguages languageToDisplay = [gs translateOnForUser:userUuid] ? [gs languageForUser:userUuid] : TranslateLanguagesNoTranslation;
        
        ChatMessage *cm = [pcpp makeChatMessage];
        
        NSString *displayMessage = [cm getContentInLanguage:languageToDisplay isTranslated:NULL translationExists:NULL];
        [self.notificationView updateWithString:pcpp.sender.name description:displayMessage color:[UIColor colorWithHexString:@"FFFFFF"]];
        
        //pass anything through owner because there are no outlets
        [self addAvatarWithMonsterId:pcpp.sender.avatarMonsterId];
      }
      
    } else if (messages.count > 1){
      
      NSString *description;
      
      if(messages.count >= 3) {
        description = [NSString stringWithFormat:@"You have new messages from %@, %@, and %d other.", [(ChatMessage *)messages[0] sender].name, [(ChatMessage *)messages[1] sender].name, (int)messages.count-2];
      } else {
        description = [NSString stringWithFormat:@"You have new messages from %@ and %@.", [(ChatMessage *)messages[0] sender].name, [(ChatMessage *)messages[1] sender].name];
      }
      
      NSString *title = [NSString stringWithFormat:@"%d New Messages", (int)allMessages.count];
      [self.notificationView updateWithString:title description:description];
      
      int numAvatars = 0;
      for (ChatMessage *message in messages) {
        if(numAvatars >= MAX_AVATAR_COUNT) {
          break;
        }
        numAvatars++;
        [self addAvatarWithMonsterId:message.sender.avatarMonsterId];
      }
    }
    
    [self.notificationView.textView setOrigin:CGPointMake(_avatarOffSet+TEXT_BUFFER_FROM_AVATAR,0.f)];
    [self.notificationView.textView setWidth: self.view.width-_avatarOffSet+FIRST_AVATAR_OFFSET];
    _priority = isImmediate ? NotificationPriorityImmediate : NotificationPriorityRegular;
     
  }
  return self;
}

- (CircleMonsterView *) addAvatarWithMonsterId:(int)monsterId {
  CircleMonsterView *avatar = [[NSBundle mainBundle] loadNibNamed:@"CircleMonsterView" owner:self options:nil][0];
  [avatar updateForMonsterId:monsterId];
  [self.notificationView addSubview:avatar];
  
  avatar.center = ccp(_avatarOffSet+avatar.width/2, (self.notificationView.frame.size.height/2)+AVATAR_VERTICAL_OFFSET);
  _avatarOffSet = avatar.center.x;
  return avatar;
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  [self displayView];
  
  // Have to use height because omnipresent views don't have proper orientation
  //commenting out becasue does nothing?
//  self.notificationView.center = ccp(self.relativeFrame.size.width/2, 9999999);
  
  _completion = completion;
  
  [self.notificationView animateIn:^{
    [self performSelector:@selector(end) withObject:nil afterDelay:3.f];
  }];
}

//- (void) viewDidLoad {
//  [super viewDidLoad];
//  
//  [self.view addSubview:self.notificationView];
//}

- (void) endAbruptly {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  [self end];
}

- (void) end {
  [self.notificationView animateOut:^{
    [self removeView];
    
    if (_completion) {
      _completion();
      _completion = nil;
    }
  }];
}

- (NotificationPriority) priority {
  return _priority;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeTop;
}

- (IBAction)notificationClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  
  if (_messageFromSingleUser) {
    [gvc openPrivateChatWithUserUuid:_messageFromSingleUser.otherUser.userUuid name:_messageFromSingleUser.otherUser.name];
  } else {
    [gvc openChatWithScope:ChatScopePrivate];
  }
  
  [self endAbruptly];
}

@end
