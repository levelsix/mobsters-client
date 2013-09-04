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

@interface NiceFontLabel2 : UILabel 
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

@interface NiceFontLabel8 : UILabel
@end

@interface NiceFontLabel9 : UILabel
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

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NiceFontTextFieldDelegate *nfDelegate;

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

@interface EquipButton : UIImageView

@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int enhancePercent;
@property (nonatomic, retain) UIImageView *darkOverlay;

- (void) equipClicked;

@end

@interface EquipLevelIcon : UIImageView

@property (nonatomic, assign) int level;

@end

@interface EnhancementLevelIcon : UIImageView

@property (nonatomic, assign) int level;

@end

@interface ProgressBar : UIImageView

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
