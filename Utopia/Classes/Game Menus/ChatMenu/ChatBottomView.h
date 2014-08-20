//
//  ChatBottomView.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapBotView.h"
#import "MonsterCardView.h"
#import "UserData.h"

typedef enum {
  ChatScopeGlobal = 1,
  ChatScopeClan,
  ChatScopePrivate
} ChatScope;

@interface ChatBottomLineView : UIView

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UIImageView *dotIcon;

- (void) updateForChatMessage:(ChatMessage *)cm shouldShowDot:(BOOL)showDot;

@end

@protocol ChatBottomViewDelegate <MapBotViewDelegate>

- (int) numChatsAvailableForScope:(ChatScope)scope;
- (NSString *) emptyStringForScope:(ChatScope)scope;
- (ChatMessage *) chatMessageForLineNum:(int)lineNum scope:(ChatScope)scope;
- (BOOL) shouldShowUnreadDotForLineNum:(int)lineNum scope:(ChatScope)scope;
- (void) bottomViewClicked;
- (BOOL) shouldShowNotificationDotForScope:(ChatScope)scope;
- (void) willSwitchToScope:(ChatScope)scope;

@end

@interface ChatBottomView : MapBotView {
  int _numChats;
  int _numToDisplay;
}

@property (nonatomic, retain) IBOutlet ChatBottomLineView *lineView;
@property (nonatomic, retain) NSMutableArray *unusedLineViews;
@property (nonatomic, retain) NSMutableArray *currentLineViews;

@property (nonatomic, retain) IBOutlet UIView *lineViewContainer;
@property (nonatomic, retain) IBOutlet UIView *pageControlView;

@property (nonatomic, retain) IBOutlet UIView *closedView;
@property (nonatomic, retain) IBOutlet UIView *openedView;

@property (nonatomic, retain) UILabel *emptyLabel;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) ChatScope chatScope;

@property (nonatomic, assign) id<ChatBottomViewDelegate> delegate;

- (void) openAnimated:(BOOL)animated;
- (void) closeAnimated:(BOOL)animated;

- (void) reloadData;
- (void) reloadDataAnimated;

@end
