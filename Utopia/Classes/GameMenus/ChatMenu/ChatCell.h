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

#import "TeamViewController.h"

#import "MonsterSelectViewController.h"
#import "TeamDonateMonstersFiller.h"

@interface ChatCell : UITableViewCell {
  BOOL _bubbleColorChanged;
  UIColor *_initMsgLabelColor;
  UIColor *_initMsgLabelHighlightedColor;
  UIColor *_initTimeLabelColor;
  
  float _initialMsgLabelWidth;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
// This is used for the popover to align correctly
@property (nonatomic, retain) IBOutlet UIView *bubbleAlignView;

@property (nonatomic, retain) IBOutlet UILabel *translationDescription;
@property (nonatomic, retain) IBOutlet UIButton *untranslateButton;

@property (nonatomic, retain) IBOutlet UIView *currentChatSubview;

@property (nonatomic, retain) NSMutableDictionary *chatSubviews;

- (void) updateForMessage:(NSString *)message showsClanTag:(BOOL)showsClanTag translatedTo:(TranslateLanguages)translatedTo chatMessage:(ChatMessage *)chatMessage showTranslateButton:(BOOL)showTranslateButton;
- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier;
- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier translatedTo:(TranslateLanguages)translatedTo untranslate:(BOOL)untranslate;

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

- (void) updateForPrivateChat:(id<ChatObject>)privateChat language:(TranslateLanguages)language;

@end

@interface PrivateChatAttackLogCell : PrivateChatListCell
@property (nonatomic, retain) IBOutlet UIImageView *chatDivider;

@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *cashLabel;

@property (nonatomic, retain) IBOutlet UILabel *avengedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avengedCheck;

@property (nonatomic, retain) IBOutlet UILabel *revengedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *revengeCheck;

@property (nonatomic, retain) IBOutlet UIView *selectedSubViewBackGround;
- (void) updateForPrivateChat:(id<ChatObject>)privateChat language:(TranslateLanguages)language;

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
@property (nonatomic, retain) IBOutlet UIImageView *dividerLine;

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

@property (nonatomic, retain) IBOutlet UIImageView *avengeCheck;
@property (nonatomic, retain) IBOutlet UILabel *avengedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *revengeCheck;
@property (nonatomic, retain) IBOutlet UILabel *revengedLabel;


@property (nonatomic, retain) IBOutletCollection(ChatMonsterView) NSArray *monsterViews;

- (void) updateForPvpHistoryProto:(PvpHistoryProto *)pvp;
- (void) updateTimeForPvpHistoryProto:(PvpHistoryProto *)pvp;

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

@interface ChatTeamDonateView : UIView

@property (nonatomic, assign) IBOutlet UILabel *powerLimitLabel;
@property (nonatomic, assign) IBOutlet UIButton *donateButton;

@property (nonatomic, assign) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, assign) IBOutlet UILabel *monsterLabel;
@property (nonatomic, assign) IBOutlet UILabel *donatorNameLabel;

@property (nonatomic, assign) IBOutlet UIView *filledView;
@property (nonatomic, assign) IBOutlet UIView *emptyView;

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *donateSpinner;
@property (nonatomic, assign) IBOutlet UILabel *donateLabel;

- (void) updateForTeamDonation:(ClanMemberTeamDonationProto *)donation;

@end
