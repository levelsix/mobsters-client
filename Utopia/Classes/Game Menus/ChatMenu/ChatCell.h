//
//  ChatCell.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface ChatCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *nameButton;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;

@property (nonatomic, retain) IBOutlet UIImageView *shieldIcon;
@property (nonatomic, retain) IBOutlet UIButton *clanButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) ChatMessage *chatMessage;

- (void) updateForChat:(ChatMessage *)msg;

@end

@interface PrivateChatListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *msgLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unreadIcon;

@property (nonatomic, strong) PrivateChatPostProto *privateChat;

- (void) updateForPrivateChat:(PrivateChatPostProto *)privateChat;

@end

