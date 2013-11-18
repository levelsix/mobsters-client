//
//  ChatView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"

@protocol ChatViewDelegate <NSObject>

- (void) profileClicked:(int)userId;
- (void) clanClicked:(MinimumClanProto *)clan;

@end

@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
  CGRect msgLabelInitialFrame;
  UIFont *msgLabelFont;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) IBOutlet ChatCell *chatCell;

@property (nonatomic, weak) IBOutlet id<ChatViewDelegate> delegate;

@property (nonatomic, retain) NSArray *chats;

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated;

- (IBAction)sendChatClicked:(id)sender;
- (IBAction)nameClicked:(id)sender;
- (IBAction)clanClicked:(id)sender;

@end

@interface GlobalChatView : ChatView

@end

@interface ClanChatView : ChatView

@property (nonatomic, retain) IBOutlet UIImageView *shieldIcon;
@property (nonatomic, retain) IBOutlet UILabel *clanLabel;

@property (nonatomic, retain) IBOutlet UILabel *noClanLabel;
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) MinimumClanProto *clan;

- (void) updateForChats:(NSArray *)chats andClan:(MinimumClanProto *)clan;

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

@property (nonatomic, retain) NSArray *privateChatList;

- (void) addPrivateChat:(PrivateChatPostProto *)pcpp;
- (void) updateForPrivateChatList:(NSArray *)privateChats;
- (void) loadListViewAnimated:(BOOL)animated;
- (void) loadConversationViewAnimated:(BOOL)animated;
- (void) openConversationWithUserId:(int)userId animated:(BOOL)animated;
- (IBAction)backClicked:(id)sender;

@end
