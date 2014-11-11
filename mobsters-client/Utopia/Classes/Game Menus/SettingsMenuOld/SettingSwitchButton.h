//
//  SettingSwitchButton.h
//  Utopia
//
//  Created by Danny on 9/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingSwitchButton;

@protocol SettingSwitchButtonDelegate <NSObject>

- (void)buttonTurnedOn:(SettingSwitchButton *)button;
- (void)buttonTurnedOff:(SettingSwitchButton *)button;

@end

@interface SettingSwitchButton : UIView {
  CGPoint _initialTouch;
  BOOL isTouched;
}

@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) IBOutlet id<SettingSwitchButtonDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *onOffSwitch;
@property (nonatomic, strong) IBOutlet UILabel *onLabel;
@property (nonatomic, strong) IBOutlet UILabel *offLabel;
- (void)setOnOffPositon;
@end
