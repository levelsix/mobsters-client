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
#import "ChatBottomView.h"

@interface ChatMainView : PopupShadowView

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *allowedViews;

@end

@protocol ChatViewControllerDelegate <NSObject>

- (void) chatViewControllerDidChangeScope:(ChatScope)scope;
- (void) chatViewControllerDidClose:(id)cvc;

@end

@interface ChatViewController : UIViewController <TabBarDelegate, UITextFieldDelegate, ChatViewDelegate> {
  BOOL _passedThreshold;
  
  NSString *_muteUserUuid;
  NSString *_muteName;
  
  BOOL _isEditing;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet ButtonTabBar *topBar;

@property (nonatomic, retain) IBOutlet GlobalChatView *globalChatView;
@property (nonatomic, retain) IBOutlet ClanChatView *clanChatView;
@property (nonatomic, retain) IBOutlet PrivateChatView *privateChatView;

@property (nonatomic, retain) IBOutlet BadgeIcon *clanBadgeIcon;
@property (nonatomic, retain) IBOutlet BadgeIcon *privateBadgeIcon;

@property (nonatomic, retain) IBOutlet UIView *topLiveHelpView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet ChatPopoverView *popoverView;

@property (nonatomic, retain) NSTimer *updateTimer;

@property (nonatomic, assign) id<ChatViewControllerDelegate> delegate;

- (void) openWithConversationForUserUuid:(NSString *)userUuid name:(NSString *)name;

@end
