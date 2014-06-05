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

@interface ChatTopBar : ButtonTopBar

@end

@interface ChatMainView : PopupShadowView

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *allowedViews;

@end

@interface ChatViewController : UIViewController <TabBarDelegate, UITextFieldDelegate, ChatViewDelegate> {
  BOOL _passedThreshold;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet ButtonTopBar *topBar;

@property (nonatomic, retain) IBOutlet GlobalChatView *globalChatView;
@property (nonatomic, retain) IBOutlet ClanChatView *clanChatView;
@property (nonatomic, retain) IBOutlet PrivateChatView *privateChatView;

@property (nonatomic, retain) IBOutlet BadgeIcon *clanBadgeIcon;
@property (nonatomic, retain) IBOutlet BadgeIcon *privateBadgeIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet ChatPopoverView *popoverView;

- (void) openWithConversationForUserId:(int)userId name:(NSString *)name;

@end
