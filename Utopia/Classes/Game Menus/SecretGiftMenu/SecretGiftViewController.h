//
//  SecretGiftViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Protocols.pb.h"

#import "NibUtils.h"

@interface SecretGiftViewController : UIViewController

@property (nonatomic, strong) IBOutlet THLabel *congratsLabel;
@property (nonatomic, strong) IBOutlet THLabel *receivedLabel;
@property (nonatomic, strong) IBOutlet UILabel *itemNameLabel;
@property (nonatomic, strong) IBOutlet THLabel *iconLabel;
@property (nonatomic, strong) IBOutlet UIImageView *itemIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, strong) UserItemSecretGiftProto *secretGift;

- (id) initWithSecretGift:(UserItemSecretGiftProto *)sg;

@end
