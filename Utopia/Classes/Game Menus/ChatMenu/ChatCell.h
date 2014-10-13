//
//  ChatCell.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "MonsterCardView.h"
#import "NibUtils.h"

@interface ChatCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
// This is used for the popover to align correctly
@property (nonatomic, retain) IBOutlet UIView *bubbleAlignView;

@property (nonatomic, retain) IBOutlet UIView *currentChatSubview;

@property (nonatomic, retain) NSMutableDictionary *chatSubviews;

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag;
- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag chatSubview:(UIView *)view identifier:(NSString *)identifier;
- (id) dequeueChatSubview:(NSString *)identifier;

@end

@interface PrivateChatListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unreadIcon;

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, strong) PrivateChatPostProto *privateChat;

- (void) updateForPrivateChat:(PrivateChatPostProto *)privateChat;

@end

@interface ChatClanHelpView : UIView

@property (nonatomic, assign) IBOutlet UILabel *numHelpsLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, assign) IBOutlet UIButton *helpButton;
@property (nonatomic, assign) IBOutlet UIView *helpButtonView;
@property (nonatomic, assign) IBOutlet UIView *helpedView;

- (void) updateForClanHelp:(id)clanHelp;

@end
