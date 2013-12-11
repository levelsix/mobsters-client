//
//  ChatViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"

@interface ChatMainView : UIView

@property (nonatomic, retain) IBOutlet UIView *insideView;
@property (nonatomic, retain) IBOutlet UIView *openButton;

@end

@protocol ChatTopBarDelegate <NSObject>

- (void) button1Clicked;
- (void) button2Clicked;
- (void) button3Clicked;

@end

@interface ChatTopBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *selectedView;

@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;

@property (nonatomic, assign) IBOutlet id<ChatTopBarDelegate> delegate;

- (void) clickButton:(int)button;
- (IBAction) buttonClicked:(id)sender;

@end

@interface ChatViewController : UIViewController <ChatTopBarDelegate, UITextFieldDelegate, ChatViewDelegate> {
  BOOL _passedThreshold;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *arrow;
@property (nonatomic, retain) IBOutlet ChatTopBar *topBar;

@property (nonatomic, retain) IBOutlet GlobalChatView *globalChatView;
@property (nonatomic, retain) IBOutlet ClanChatView *clanChatView;
@property (nonatomic, retain) IBOutlet PrivateChatView *privateChatView;

@property (nonatomic, assign) BOOL isOpen;

- (void) open;
- (void) openWithConversationForUserId:(int)userId;
- (void) closeAnimated:(BOOL)animated;

@end
