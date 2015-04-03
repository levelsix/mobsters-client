//
//  ChatView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatObject.h"
#import "ChatCell.h"
#import "ClanHelp.h"

//#define GLOBAL_LANGUAGE_PREFERENCES @"GlobalLanguagePreferences"
//#define PRIVATE_LANGUAGE_PREFERENCES @"PrivateLanguagePreferences"

typedef enum {
  PrivateChatModeAllMessages = 1,
  PrivateChatModeAttackLog,
  PrivateChatModeDefenseLog,
}PrivateChatViewMode;

@protocol LanguageSelectorProtocol <NSObject>

- (void) flagClicked:(TranslateLanguages)language;
- (void) translateChecked:(BOOL)checked;


@end

@interface ChatLanguageSelector : UIView {
  BOOL _closing;
}

@property (nonatomic, assign) id<LanguageSelectorProtocol> delegate;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *flagButtons;
@property (nonatomic, assign) IBOutlet UIImageView *selectBox;
@property (nonatomic, assign) IBOutlet UIImageView *checkMark;
@property (nonatomic, assign) IBOutlet UIImageView *rightBgEdge;
@property (nonatomic, assign) IBOutlet UILabel *descriptionLabel;

- (void) updateForLanguage:(TranslateLanguages)language markChecked:(BOOL)markChecked;
- (void) openAtPoint:(CGPoint)pt markChecked:(BOOL)markChecked curLanguage:(TranslateLanguages)curLanguage;
- (void) close;

@end

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

- (void) profileClicked:(NSString *)userUuid;
- (void) beginPrivateChatWithUserUuid:(NSString *)userUuid name:(NSString *)name;
- (void) muteClicked:(NSString *)userUuid name:(NSString *)name;
- (void) viewedPrivateChat;
- (void) hideTopLiveHelp;

//- (void) lockLanguageButtonWithFlag:(NSString *)flagImageName;
//- (void) unlockLanguageButton;
//- (void) setLanguageCheckMark:(BOOL)checked;
//- (void) hideLanguageButton:(BOOL)hide;

@end

@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ChatPopoverDelegate, LanguageSelectorProtocol> {
  ChatCell *_testCell;
  TranslateLanguages _curLanguage;
  id<ChatObject> _clickedMsg;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) IBOutlet ChatCell *chatCell;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet ChatPopoverView *popoverView;
@property (nonatomic, retain) IBOutlet ChatLanguageSelector *languageSelectorView;

@property (nonatomic, weak) IBOutlet id<ChatViewDelegate> delegate;

@property (nonatomic, retain) NSArray *chats;

@property (nonatomic, assign) CGRect originalBottomViewRect;

@property (nonatomic, assign) BOOL allowAutoScroll;

@property (nonatomic, retain) IBOutlet UIButton *flagButton;
@property (nonatomic, retain) IBOutlet UIImageView *flagCheckImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *flagSpinner;

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
@property (nonatomic, retain) IBOutlet UILabel *joinClanLabel;
@property (nonatomic, retain) IBOutlet UIView *joinClanButtonView;

@property (nonatomic, retain) IBOutlet UIView *helpAllView;
@property (nonatomic, retain) IBOutlet UILabel *helpCountLabel;

@property (nonatomic, retain) MinimumClanProto *clan;

@property (nonatomic, retain) NSMutableArray *helpsArray;

- (void) updateForChats:(NSArray *)chats andClan:(MinimumClanProto *)clan animated:(BOOL)animated;

- (IBAction) helpAllClicked:(id)sender;

@end

@interface PrivateChatView : ChatView {
  BOOL _isLoading;
  PrivateChatViewMode _chatMode;
  id<ChatObject> _clickedCell;
  CGPoint _originalDefenceTabPosition;
}

@property (nonatomic, retain) NSString *curUserUuid;

@property (nonatomic, retain) IBOutlet UITableView *listTable;
@property (nonatomic, retain) IBOutlet PrivateChatAttackLogCell *battleListCell;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *emptyListLabel;
@property (nonatomic, retain) IBOutlet UILabel *noPostsLabel;

@property (nonatomic, retain) UIView *topLiveHelpView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) NSArray *privateChatList;
@property (nonatomic, retain) NSMutableArray *displayedChatList;
@property (nonatomic, retain) NSMutableArray *baseChats;

@property (nonatomic, retain) NSMutableArray *unrespondedChatMessages;

@property (nonatomic, retain) IBOutlet UIButton *allMessagesTabButton;
@property (nonatomic, retain) IBOutlet UIButton *defensiveLogTabButton;
@property (nonatomic, retain) IBOutlet UIButton *offensiveLogTabButton;
@property (nonatomic, retain) IBOutlet UILabel *unreadDefenseLog;

- (void) addPrivateChat:(PrivateChatPostProto *)pcpp;
- (void) updateForPrivateChatList:(NSArray *)privateChats;
- (void) loadListViewAnimated:(BOOL)animated;
- (void) loadConversationViewAnimated:(BOOL)animated;
- (void) openConversationWithUserUuid:(NSString *)userUuid name:(NSString *)name animated:(BOOL)animated;
- (IBAction)backClicked:(id)sender;

@end
