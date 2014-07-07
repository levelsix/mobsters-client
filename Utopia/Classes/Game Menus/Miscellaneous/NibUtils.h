//
//  NibUtils.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"
#import "Protocols.pb.h"
#import "MonsterCardView.h"

typedef enum {
  kButton1 = 1,
  kButton2 = 1 << 1,
  kButton3 = 1 << 2,
  kButton4 = 1 << 3,
  kButton5 = 1 << 4
} BarButton;

@interface NiceFontLabelS : UILabel

@property (nonatomic, assign) float strokeSize;
@property (nonatomic, retain) UIColor *strokeColor;

@end

@interface NiceFontLabel : UILabel
@end

@interface NiceFontLabelB : THLabel
@end

@interface NiceFontLabel2 : UILabel
@end

@interface NiceFontLabel2B : THLabel
@end

@interface NiceFontLabel3 : UILabel
@end

@interface NiceFontLabel4 : UILabel
@end

@interface NiceFontLabel5 : UILabel
@end

@interface NiceFontLabel6 : UILabel
@end

@interface NiceFontLabel7 : UILabel
@end

@interface NiceFontLabel7B : THLabel
@end

@interface NiceFontLabel8 : UILabel
@end

@interface NiceFontLabel8B : THLabel
@end

@interface NiceFontLabel8S : THLabel
@end

@interface NiceFontLabel8WS : THLabel
@end

@interface NiceFontLabel9 : UILabel
@end

@interface NiceFontLabel9B : THLabel
@end

@interface NiceFontLabel9S : THLabel
@end

@interface NiceFontLabel10 : UILabel
@end

@interface NiceFontLabel10B : THLabel
@end

@interface NiceFontLabel10S : THLabel
@end

@interface NiceFontLabel11 : UILabel
@end

@interface NiceFontLabel12 : UILabel
@end

@interface NiceFontLabel12B : THLabel
@end

@interface NiceFontLabel12S : THLabel
@end

@interface NiceFontLabel13 : UILabel
@end

@interface NiceFontLabel13S : THLabel
@end

@interface NiceFontLabel14 : UILabel
@end

@interface NiceFontLabel14B : THLabel
@end

@interface NiceFontLabel14S : THLabel
@end

@interface NiceFontLabel14WS : THLabel
@end

@interface NiceFontLabel15 : UILabel
@end

@interface NiceFontLabel16 : UILabel
@end

@interface NiceFontLabel16B : THLabel
@end

@interface NiceFontLabel17 : UILabel
@end

@interface SoundButton : UIButton {
  BOOL _allowAnimate;
}

- (void) playSound;

@end

@interface CloseButton : SoundButton

@end

@interface UpgradeButton : SoundButton

@end

@interface GeneralButton : SoundButton

@end

@interface NiceFontButton : GeneralButton
@end

@interface NiceFontButton2 : GeneralButton
@end

@interface NiceFontButton3 : GeneralButton
@end

@interface NiceFontButton8 : GeneralButton
@end

@interface NiceFontButton9 : GeneralButton
@end

@interface NiceFontButton10 : GeneralButton
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

@interface NiceFontTextField2 : UITextField

@end

@interface NiceFontTextField9 : UITextField

@end

@interface NiceFontTextField17 : UITextField

@end

@interface NiceFontTextView : UITextView

@end

@interface NiceFontTextView2 : UITextView

@end

@interface NiceFontTextView9 : UITextView

@end

@interface NiceFontTextView17 : UITextView

@end

@interface FlipImageView : UIImageView

@end

@interface VerticalFlipImageView : UIImageView

@end

@interface DoubleFlipImageView : UIImageView

@end

@interface FlipButton : UIButton

@end

@interface RotateLabel8 : NiceFontLabel8

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

@interface CircularProgressBar : UIView

@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) float percentage;

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

@interface MaskedButton : GeneralButton

// Will take snapshot of view if it is not a uiimageView
@property (nonatomic, assign) IBOutlet UIView *baseImage;

- (void) remakeImage;

@end

@interface DeployCardButton : MaskedButton

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

@interface ButtonTabBar : UIView

@property (nonatomic, retain) IBOutlet UIView *selectedView;

@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;

@property (nonatomic, retain) IBOutlet UIImageView *icon1;
@property (nonatomic, retain) IBOutlet UIImageView *icon2;
@property (nonatomic, retain) IBOutlet UIImageView *icon3;

@property (nonatomic, retain) UIColor *inactiveTextColor;
@property (nonatomic, retain) UIColor *inactiveShadowColor;
@property (nonatomic, retain) UIColor *activeTextColor;
@property (nonatomic, retain) UIColor *activeShadowColor;

@property (nonatomic, assign) IBOutlet id<TabBarDelegate> delegate;

- (void) clickButton:(int)button;
- (IBAction) buttonClicked:(id)sender;
- (void) button:(int)button shouldBeHidden:(BOOL)hidden;

@end

@class NumTransitionLabel;

@protocol NumTransitionLabelDelegate <NSObject>

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number;

@optional
- (void) labelReachedGoalNum:(UILabel *)label;

@end

@interface NumTransitionLabel : NiceFontLabel8B

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

@interface BadgeIcon : UIView

@property (nonatomic, retain) IBOutlet UILabel *badgeLabel;
@property (nonatomic, assign) NSInteger badgeNum;

@end

@interface TouchableSubviewsView : UIView

@end

@interface LeagueView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *leagueBgd;
@property (nonatomic, strong) IBOutlet UIImageView *leagueIcon;
@property (nonatomic, strong) IBOutlet UILabel *leagueLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankLabel;
@property (nonatomic, strong) IBOutlet UILabel *rankQualifierLabel;
@property (nonatomic, strong) IBOutlet UILabel *placeLabel;

- (void) updateForUserLeague:(UserPvpLeagueProto *)upvp ribbonSuffix:(NSString *)ribbonSuffix;

@end

@interface PopupShadowView : UIView

@end

@interface SplitImageProgressBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *leftCap;
@property (nonatomic, retain) IBOutlet UIImageView *rightCap;
@property (nonatomic, retain) IBOutlet UIImageView *middleBar;

@property (nonatomic, assign) float percentage;
@property (nonatomic, assign) BOOL isRightToLeft;

@end

@interface EmbeddedNibView : UIView

@end
