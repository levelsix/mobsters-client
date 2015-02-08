//
//  PrivateMessageNotificationViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 1/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"
#import "HudNotificationController.h"
#import "NibUtils.h"
#import "ChatBottomView.h"

@interface PrivateMessageNotificationView : TouchableSubviewsView

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;
@property (nonatomic, retain) IBOutlet UIButton *button;

- (void) animateIn:(dispatch_block_t)completion;
- (void) animateOut:(dispatch_block_t)completion;
- (void) updateWithString:(NSString *)title description:(NSString *)description color:(UIColor *)color;
- (void) updateWithString:(NSString *)title description:(NSString *)description;

@end

@interface PrivateMessageNotificationViewController : OmnipresentViewController <TopBarNotification> {
  dispatch_block_t _completion;
  NotificationPriority _priority;
  CGFloat _avatarOffSet;
  CGFloat _avatarViewWidth;
  ChatMessage *_messageFromSingleUser;
}

- (id) initWithMessages:(NSArray *)messages isImmediate:(BOOL)isImmediate;

@property (nonatomic, retain) IBOutlet PrivateMessageNotificationView *notificationView;

@end
