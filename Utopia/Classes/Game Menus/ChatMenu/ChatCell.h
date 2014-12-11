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
#import "ChatObject.h"

@interface ChatCell : UITableViewCell {
  BOOL _bubbleColorChanged;
  UIColor *_initLabelColor;
}

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
- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier;

- (void) updateBubbleImagesWithPrefix:(NSString *)prefix;

- (id) dequeueChatSubview:(NSString *)identifier;

@end

@interface PrivateChatListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unreadIcon;

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, strong) id<ChatObject> privateChat;

- (void) updateForPrivateChat:(id<ChatObject>)privateChat;

@end

@interface ChatClanHelpView : UIView

@property (nonatomic, assign) IBOutlet UILabel *numHelpsLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, assign) IBOutlet UIButton *helpButton;
@property (nonatomic, assign) IBOutlet UIView *helpButtonView;
@property (nonatomic, assign) IBOutlet UIView *helpedView;

- (void) updateForClanHelp:(id)clanHelp;

- (void) flip;
- (void) unflip;

@end

@interface ChatBonusSlotRequestView : UIView

@property (nonatomic, assign) IBOutlet UIButton *helpButton;

- (void) updateForRequest:(RequestFromFriend *)req;

@end

@interface ChatMonsterView : EmbeddedNibView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityTag;

@end

@interface ChatBattleHistoryView : UIView {
  CGRect _initAvengeFrame;
}

@property (nonatomic, retain) IBOutlet UIImageView *topDivider;
@property (nonatomic, retain) IBOutlet UIImageView *botDivider;
@property (nonatomic, retain) IBOutlet UIButton *avengeButton;
@property (nonatomic, retain) IBOutlet UIButton *revengeButton;

@property (nonatomic, retain) IBOutlet UILabel *avengeTimeLabel;

@property (nonatomic, retain) IBOutlet UIView *cashView;
@property (nonatomic, retain) IBOutlet UIView *oilView;
@property (nonatomic, retain) IBOutlet UIView *rankView;

@property (nonatomic, retain) IBOutlet UILabel *cashLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UILabel *noChangeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rankIcon;

@property (nonatomic, retain) IBOutletCollection(ChatMonsterView) NSArray *monsterViews;

- (void) updateForPvpHistoryProto:(PvpHistoryProto *)pvp;

@end

@interface ChatClanAvengeView : UIView

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet UIButton *attackButton;
@property (nonatomic, assign) IBOutlet UIButton *profileButton;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (void) updateForClanAvenging:(PvpClanAvenging *)ca;
- (void) updateTimeForClanAvenging:(PvpClanAvenging *)ca;

@end
