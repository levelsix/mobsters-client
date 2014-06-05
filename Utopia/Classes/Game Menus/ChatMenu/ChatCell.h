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

@interface ChatCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;

@property (nonatomic, retain) IBOutlet CircleMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
// This is used for the popover to align correctly
@property (nonatomic, retain) IBOutlet UIView *bubbleAlignView;

@property (nonatomic, retain) ChatMessage *chatMessage;

- (void) updateForChat:(ChatMessage *)msg showsClanTag:(BOOL)showsClanTag;

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

