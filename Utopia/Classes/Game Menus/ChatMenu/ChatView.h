//
//  ChatView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"

@protocol ChatPopoverDelegate <NSObject>

- (void) profileClicked;
- (void) messageClicked;
- (void) muteClicked;

@end

@interface ChatPopoverView : UIView

@property (nonatomic, assign) id<ChatPopoverDelegate> delegate;

- (void) openAtPoint:(CGPoint)pt;
- (void) close;

@end



@protocol ChatViewDelegate <NSObject>

- (void) profileClicked:(int)userId;
- (void) beginPrivateChatWithUserId:(int)userId name:(NSString *)name;
- (void) muteClicked:(int)userId name:(NSString *)name;
- (void) viewedPrivateChat;

@end

@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ChatPopoverDelegate> {
  CGRect msgLabelInitialFrame;
  UIFont *msgLabelFont;
  
  ChatMessage *_clickedMsg;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) IBOutlet ChatCell *chatCell;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet ChatPopoverView *popoverView;

@property (nonatomic, weak) IBOutlet id<ChatViewDelegate> delegate;

@property (nonatomic, retain) NSArray *chats;

@property (nonatomic, assign) CGRect originalBottomViewRect;

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated;

- (IBAction)sendChatClicked:(id)sender;

@end

@interface GlobalChatView : ChatView

@end

@interface ClanChatView : ChatView

@property (nonatomic, retain) IBOutlet UIImageView *shieldIcon;
@property (nonatomic, retain) IBOutlet UILabel *clanLabel;

@property (nonatomic, retain) IBOutlet UIView *noClanView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) MinimumClanProto *clan;

- (void) updateForChats:(NSArray *)chats andClan:(MinimumClanProto *)clan animated:(BOOL)animated;

@end

@interface PrivateChatView : ChatView {
  BOOL _isLoading;
}

@property (nonatomic, assign) int curUserId;

@property (nonatomic, retain) IBOutlet UITableView *listTable;
@property (nonatomic, retain) IBOutlet PrivateChatListCell *listCell;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *emptyListLabel;
@property (nonatomic, retain) IBOutlet UILabel *noPostsLabel;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) NSArray *privateChatList;

- (void) addPrivateChat:(PrivateChatPostProto *)pcpp;
- (void) updateForPrivateChatList:(NSArray *)privateChats;
- (void) loadListViewAnimated:(BOOL)animated;
- (void) loadConversationViewAnimated:(BOOL)animated;
- (void) openConversationWithUserId:(int)userId name:(NSString *)name animated:(BOOL)animated;
- (IBAction)backClicked:(id)sender;

@end
