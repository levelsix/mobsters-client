//
//  NibUtils.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  kButton1 = 1,
  kButton2 = 1 << 1,
  kButton3 = 1 << 2,
  kButton4 = 1 << 3,
  kButton5 = 1 << 4
} BarButton;

@interface NiceFontLabel : UILabel 
@end

@interface NiceFontButton : UIButton
@end

@interface NiceFontButton2 : UIButton
@end

@interface LabelButton : UIButton {
  UILabel *_label;
  NSString *_text;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *text;

@end

@interface NiceFontTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, assign) id<UITextFieldDelegate> otherDelegate;

@end

@interface NiceFontTextField : UITextField

@end

@interface NiceFontTextView : UITextView

@end

@interface NiceFontTextView2 : UITextView

@end

@interface FlipImageView : UIImageView

@end

@interface VerticalFlipImageView : UIImageView

@end

@interface FlipButton : UIButton

@end

@interface ServerImageView : UIImageView 

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *highlightedPath;

@end

@interface ServerButton : UIButton 

@property (nonatomic, retain) NSString *path;

@end

@interface RopeView : UIView

@end

@interface TutorialGirlImageView : UIImageView

@end

@interface CancellableTableView : UITableView
@end

@interface CancellableScrollView : UIScrollView
@end

@interface MonsterButton : UIImageView

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int enhancePercent;
@property (nonatomic, retain) UIImageView *darkOverlay;

- (void) monsterClicked;

@end

@interface EnhancementLevelIcon : UIImageView

@property (nonatomic, assign) int level;

@end

@interface ProgressBar : UIImageView

@property (nonatomic, assign) float percentage;
@property (nonatomic, assign) BOOL isReverse;

@end

@interface LoadingView : UIView {
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

- (void) display:(UIView *)view;
- (void) stop;

@end

@interface TravelingLoadingView : LoadingView

@property (nonatomic, retain) IBOutlet UILabel *label;

@end

@class SwitchButton;

@protocol SwitchButtonDelegate <NSObject>

- (void) switchButtonWasTurnedOn:(SwitchButton *)b;
- (void) switchButtonWasTurnedOff:(SwitchButton *)b;

@end

@interface SwitchButton : UIView {
  CGPoint _initialTouch;
}

@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, retain) IBOutlet UIImageView *handle;
@property (nonatomic, retain) UIImageView *darkHandle;

@property (nonatomic, assign) IBOutlet id<SwitchButtonDelegate> delegate;

- (void) turnOn;
- (void) turnOff;

@end

@interface AutoScrollingScrollViewDelegate : UIView <UIScrollViewDelegate>

@end

@interface AutoScrollingScrollView : CancellableScrollView {
  BOOL _movingLeft;
}

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) float maxX;

@end

@interface MaskedButton : UIButton

@property (nonatomic, assign) IBOutlet UIImageView *baseImage;

- (void) remakeImage;

@end

@protocol TabBarDelegate <NSObject>

@optional
- (void) button1Clicked:(id)sender;
- (void) button2Clicked:(id)sender;
- (void) button3Clicked:(id)sender;
- (void) button4Clicked:(id)sender;

@end

@interface FlipTabBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  
  int _clickedButtons;
}

@property (nonatomic, assign) IBOutlet UIView *button1;
@property (nonatomic, assign) IBOutlet UIView *button2;
@property (nonatomic, assign) IBOutlet UILabel *label1;
@property (nonatomic, assign) IBOutlet UILabel *label2;
@property (nonatomic, assign) IBOutlet UIImageView *bgdImage;

@property (nonatomic, assign) IBOutlet id<TabBarDelegate> delegate;

- (void) clickButton:(BarButton)button;
- (void) unclickButton:(BarButton)button;

@end

@class NumTransitionLabel;

@protocol NumTransitionLabelDelegate <NSObject>

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number;

@optional
- (void) labelReachedGoalNum:(UILabel *)label;

@end

@interface NumTransitionLabel : NiceFontLabel

@property (nonatomic, weak) IBOutlet id<NumTransitionLabelDelegate> transitionDelegate;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readonly) int currentNum;
@property (nonatomic, readonly) int goalNum;

- (void) instaMoveToNum:(int)num;
- (void) transitionToNum:(int)num;

@end

@class UnderlinedLabelView;

@protocol UnderlinedLabelDelegate <NSObject>

- (void) labelClicked:(UnderlinedLabelView *)label;

@end

@interface UnderlinedLabelView : UIView

@property (nonatomic, assign) IBOutlet UILabel *label;
@property (nonatomic, strong) UIView *underlineView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) IBOutlet id<UnderlinedLabelDelegate> delegate;

- (void)setString:(NSString *)string isEnabled:(BOOL)isEnabled;

@end

@interface CheckboxView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *checkmark;
@property (nonatomic, assign) int isChecked;

@end
