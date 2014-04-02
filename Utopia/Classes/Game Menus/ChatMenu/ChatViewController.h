//
//  ChatViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import "NibUtils.h"

@interface ChatMainView : UIView

@property (nonatomic, retain) IBOutlet UIView *insideView;
@property (nonatomic, retain) IBOutlet UIView *openButton;

@end

@interface ChatTopBar : ButtonTopBar

@end

@interface ChatViewController : UIViewController <TabBarDelegate, UITextFieldDelegate, ChatViewDelegate> {
  BOOL _passedThreshold;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *arrow;
@property (nonatomic, retain) IBOutlet ChatTopBar *topBar;

@property (nonatomic, retain) IBOutlet GlobalChatView *globalChatView;
@property (nonatomic, retain) IBOutlet ClanChatView *clanChatView;
@property (nonatomic, retain) IBOutlet PrivateChatView *privateChatView;

@property (nonatomic, retain) IBOutlet BadgeIcon *clanBadgeIcon;
@property (nonatomic, retain) IBOutlet BadgeIcon *privateBadgeIcon;
@property (nonatomic, retain) IBOutlet BadgeIcon *overallBadgeIcon;

@property (nonatomic, assign) BOOL isOpen;

- (void) open;
- (void) openWithConversationForUserId:(int)userId;
- (void) closeAnimated:(BOOL)animated;

@end
