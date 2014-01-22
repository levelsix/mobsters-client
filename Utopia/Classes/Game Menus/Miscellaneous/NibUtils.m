//
//  LabelButton.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Globals.h"
#import "GameState.h"

@implementation NiceFontLabel

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:[Globals font] size:self.font.pointSize+2];
}

@end

@implementation NiceFontLabel2

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Medium" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel3

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Book" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel4

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Akko-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel5

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Aller-BoldItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontButton

- (void) awakeFromNib {
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:[Globals font] size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton2

- (void) awakeFromNib {
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:self.titleLabel.font.pointSize];
}

@end

@implementation LabelButton

@synthesize label = _label;
@synthesize text = _text;

- (void) awakeFromNib {
  [super awakeFromNib];
  _label = [[UILabel alloc] initWithFrame:self.bounds];
  _label.backgroundColor = [UIColor clearColor];
  _label.textAlignment = NSTextAlignmentCenter;
  _label.textColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:200/255.f alpha:1];
  _label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
  _label.shadowOffset = CGSizeMake(0, 1.f);
  _label.adjustsFontSizeToFitWidth = NO;
  _label.highlightedTextColor = [_label.textColor colorWithAlphaComponent:0.5f];
  [self addSubview:_label];
  [Globals adjustFontSizeForUIViewWithDefaultSize:_label];
  
  if (_text) {
    _label.text = _text;
  }
}

- (void) setText:(NSString *)text {
  _text = text;
  _label.text = text;
}

- (void) setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  if (enabled) {
    _label.highlighted = NO;
  } else {
    _label.highlighted = YES;
  }
}

@end

@implementation NiceFontTextField

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:[Globals font] size:self.font.pointSize];
}

- (void) drawPlaceholderInRect:(CGRect)rect {
  CGSize size = [self.placeholder sizeWithFont:self.font constrainedToSize:rect.size];
  rect.origin.y = rect.size.height/2-size.height/2;
  rect.size = size;
  
  UIColor *c = [UIColor colorWithWhite:0.5f alpha:1.f];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.font, UITextAttributeFont, c, UITextAttributeTextColor, nil];
  NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self.placeholder attributes:dict];
  [attr drawInRect:rect];
}

@end

@implementation NiceFontTextView

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:[Globals font] size:self.font.pointSize];
}

@end

@implementation NiceFontTextView2

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"SanvitoPro-Semibold" size:self.font.pointSize];
}

@end

@implementation FlipImageView

- (void) awakeFromNib {
  self.transform = CGAffineTransformMakeScale(-1, 1);
}

@end

@implementation VerticalFlipImageView

- (void) awakeFromNib {
  self.transform = CGAffineTransformMakeScale(1, -1);
}

@end

@implementation FlipButton

- (void) awakeFromNib {
  self.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
}

@end

@implementation ServerImageView

@synthesize path, highlightedPath;

- (void) awakeFromNib {
  if (path) {
    self.image = [Globals imageNamed:path];
  }
  if (highlightedPath) {
    self.highlightedImage = [Globals imageNamed:highlightedPath];
  }
}

@end

@implementation ServerButton

@synthesize path;

- (void) awakeFromNib {
  [self setImage:[Globals imageNamed:path] forState:UIControlStateNormal] ;
}

@end

@implementation RopeView

- (void) awakeFromNib {
  self.backgroundColor = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
}

@end

@implementation TutorialGirlImageView

- (void) awakeFromNib {
  self.contentMode = UIViewContentModeScaleToFill;
  NSString *imageName = @"goodgirltall.png";
  self.image = [Globals imageNamed:imageName];
}

@end

@implementation CancellableTableView

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end

@implementation CancellableScrollView

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end

@implementation EnhancementLevelIcon

@synthesize level;

- (void) setLevel:(int)l {
  if (level != l) {
    level = l;
    
    if (level > 0 && level <= 3) {
      [Globals imageNamed:[NSString stringWithFormat:@"enhancelvl%d.png", l] withView:self maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    } else {
      self.image = nil;
    }
  }
}

@end

@implementation ProgressBar

@synthesize percentage;

- (void) awakeFromNib {
  self.isReverse = NO;
  self.clipsToBounds = YES;
}

- (void) setIsReverse:(BOOL)isReverse {
  _isReverse = isReverse;
  self.contentMode = isReverse ? UIViewContentModeRight : UIViewContentModeLeft;
}

- (void) setPercentage:(float)p {
  percentage = clampf(p, 0.f, 1.f);
  CGSize imgSize = self.image.size;
  
  CGRect rect = self.frame;
  rect.size.width = imgSize.width * percentage;
  
  if (_isReverse) {
    rect.origin.x = CGRectGetMaxX(rect)-rect.size.width;
  }
  
  self.frame = rect;
}

@end

@implementation CircularProgressBar

- (void) setPercentage:(float)p {
  _percentage = clampf(p, 0.f, 1.f);
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGFloat innerRadiusRatio = 0.f; //Adjust as needed
  
  //Construct the path:
  CGMutablePathRef path = CGPathCreateMutable();
  CGFloat startAngle = -M_PI_2;
  CGFloat endAngle = -M_PI_2 - self.percentage * M_PI * 2;
  CGFloat outerRadius = CGRectGetWidth(self.bounds) * 0.5f - 1.0f;
  CGFloat innerRadius = outerRadius * innerRadiusRatio;
  CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  CGPathAddArc(path, NULL, center.x, center.y, innerRadius, startAngle, endAngle, true);
  CGPathAddArc(path, NULL, center.x, center.y, outerRadius, endAngle, startAngle, false);
  CGPathCloseSubpath(path);
  CGContextAddPath(ctx, path);
  CGPathRelease(path);
  
  //Draw the image, clipped to the path:
  CGContextSaveGState(ctx);
  CGContextClip(ctx);
  [self.image drawInRect:self.bounds];
  CGContextRestoreGState(ctx);
}

@end

@implementation LoadingView

@synthesize darkView, actIndView;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
  self.darkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void) display:(UIView *)view {
  [self.actIndView startAnimating];
  
  [view addSubview:self];
  self.frame = view.bounds;
  _isDisplayingLoadingView = YES;
  
  self.alpha = 0.f;
  [UIView animateWithDuration:0.15f animations:^{
    self.alpha = 1.f;
  }];
}

- (void) stop {
  if (_isDisplayingLoadingView) {
    [UIView animateWithDuration:0.15f animations:^{
      self.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.actIndView stopAnimating];
      [self removeFromSuperview];
      _isDisplayingLoadingView = NO;
    }];
  }
}

@end

@implementation TravelingLoadingView

@end

@implementation SwitchButton

@synthesize handle, darkHandle, isOn;

- (void) awakeFromNib {
  isOn = YES;
  
  darkHandle = [[UIImageView alloc] initWithFrame:handle.bounds];
  [handle addSubview:darkHandle];
  darkHandle.image = [Globals maskImage:handle.image withColor:[UIColor colorWithWhite:0.f alpha:0.2f]];
  darkHandle.hidden = YES;
  
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOn)];
  swipe.direction = UISwipeGestureRecognizerDirectionRight;
  [self addGestureRecognizer:swipe];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnOff)];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self addGestureRecognizer:swipe];
}

- (void) turnOn {
  self.isOn = YES;
  [self.delegate switchButtonWasTurnedOn:self];
}

- (void) turnOff {
  self.isOn = NO;
  [self.delegate switchButtonWasTurnedOff:self];
}

- (void) setIsOn:(BOOL)i {
  isOn = i;
  
  CGRect r = handle.frame;
  float oldX = r.origin.x;
  r.origin.x = isOn ? self.frame.size.width-r.size.width : 0;
  float dur = ABS(oldX-r.origin.x)/self.frame.size.width*0.3f;
  
  [handle.layer removeAllAnimations];
  [UIView animateWithDuration:dur delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    handle.frame = r;
  } completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  self.darkHandle.hidden = NO;
  _initialTouch = pt;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  CGRect r = handle.frame;
  float maxX = self.frame.size.width-r.size.width;
  float originalX = isOn ? maxX : 0;
  float diff = pt.x-_initialTouch.x;
  float newX = clampf(originalX+diff, 0.f, maxX);
  r.origin.x = newX;
  handle.frame = r;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  float dist = ccpDistance(pt, _initialTouch);
  
  self.darkHandle.hidden = YES;
  
  if (dist > 10.f) {
    if (handle.center.x < self.frame.size.width/2) {
      if (!self.isOn) {
        [self turnOn];
      } else {
        [self turnOff];
      }
    } else {
      if (self.isOn) {
        [self turnOff];
      } else {
        [self turnOn];
      }
    }
  } else {
    if (self.isOn) {
      [self turnOff];
    } else {
      [self turnOn];
    }
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkHandle.hidden = YES;
  self.isOn = isOn;
}

@end

@implementation AutoScrollingScrollView

#define AUTOSCROLLDUR 0.25f
#define AUTOSCROLLX 5

- (void) setMaxX:(float)maxX {
  _maxX = maxX;
  self.contentOffset = ccp(0,0);
  _movingLeft = NO;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:AUTOSCROLLDUR-0.05f target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void) setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    _timer = timer;
  }
}

- (void) onTimer {
  if (self.contentOffset.x <= 0 && self.contentOffset.x+self.frame.size.width >= self.maxX-AUTOSCROLLX) {
    return;
  }
  
  float h = self.contentOffset.x+(_movingLeft ? -1 : 1)*AUTOSCROLLX;
  if (!_movingLeft && h+self.frame.size.width > self.maxX) {
    _movingLeft = YES;
  } else if (_movingLeft && h < 0) {
    _movingLeft = NO;
  }
  [UIView animateWithDuration:AUTOSCROLLDUR delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
    [self setContentOffset:CGPointMake(h, 0) animated:NO];
  } completion:nil];
}

@end

@implementation MaskedButton

- (void) awakeFromNib {
  [self remakeImage];
}

- (void) remakeImage {
  if (self.baseImage) {
    UIImage *img = nil;
    if ([self.baseImage isKindOfClass:[UIImageView class]]) {
      img = [(UIImageView *)self.baseImage image];
    } else {
      self.hidden = YES;
      img = [Globals snapShotView:self.baseImage];
      self.hidden = NO;
    }
    [self setImage:[Globals maskImage:img withColor:[UIColor colorWithWhite:0.f alpha:0.4f]] forState:UIControlStateHighlighted];
  } else {
    [self setImage:nil forState:UIControlStateNormal];
  }
}

@end

@implementation FlipTabBar

@synthesize button1, button2;

- (void) awakeFromNib {
  [self clickButton:kButton1];
  [self unclickButton:kButton2];
}

- (void) clickButton:(BarButton)button {
  switch (button) {
    case kButton1:
      self.bgdImage.transform = CGAffineTransformIdentity;
      _clickedButtons |= kButton1;
      break;
      
    case kButton2:
      self.bgdImage.transform = CGAffineTransformMakeScale(-1, 1);
      _clickedButtons |= kButton2;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(BarButton)button {
  switch (button) {
    case kButton1:
      self.bgdImage.transform = CGAffineTransformMakeScale(-1, 1);
      _clickedButtons &= ~kButton1;
      break;
      
    case kButton2:
      self.bgdImage.transform = CGAffineTransformIdentity;
      _clickedButtons &= ~kButton2;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (!(_clickedButtons & kButton1) && [button1 pointInside:pt withEvent:nil]) {
    _trackingButton1 = YES;
    [self clickButton:kButton1];
  }
  
  pt = [touch locationInView:button2];
  if (!(_clickedButtons & kButton2) && [button2 pointInside:pt withEvent:nil]) {
    _trackingButton2 = YES;
    [self clickButton:kButton2];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
    } else {
      [self unclickButton:kButton2];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:button1];
  if (_trackingButton1) {
    if (CGRectContainsPoint(CGRectInset(button1.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton1];
      [self unclickButton:kButton2];
      [self.delegate button1Clicked:self];
    } else {
      [self unclickButton:kButton1];
    }
  }
  
  pt = [touch locationInView:button2];
  if (_trackingButton2) {
    if (CGRectContainsPoint(CGRectInset(button2.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kButton2];
      [self unclickButton:kButton1];
      [self.delegate button2Clicked:self];
    } else {
      [self unclickButton:kButton2];
    }
  }
  
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kButton1];
  [self unclickButton:kButton2];
  _trackingButton1 = NO;
  _trackingButton2 = NO;
}

@end

@implementation NumTransitionLabel

//- (void) awakeFromNib {
//  [Globals adjustFontSizeForUILabel:self];
//  self.font = [UIFont fontWithName:[Globals font] size:self.font.pointSize+2];
//  self.strokeSize = 1.f;
//  self.strokePosition = THLabelStrokePositionOutside;
//  self.strokeColor = [UIColor blackColor];
//}

- (void) instaMoveToNum:(int)num {
  _currentNum = num;
  _goalNum = num;
  [self.transitionDelegate updateLabel:self forNumber:_currentNum];
}

- (void) transitionToNum:(int)num {
  if (num != _currentNum) {
    _goalNum = num;
    if (!self.timer) {
      self.timer = [NSTimer timerWithTimeInterval:0.04 target:self selector:@selector(moveToNextNum) userInfo:nil repeats:YES];
      [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [self moveToNextNum];
  } else {
    [self.transitionDelegate updateLabel:self forNumber:_currentNum];
    if ([self.transitionDelegate respondsToSelector:@selector(labelReachedGoalNum:)]) {
      [self.transitionDelegate labelReachedGoalNum:self];
    }
  }
}

- (void) moveToNextNum {
  if (_currentNum != _goalNum) {
    int diff = _goalNum - _currentNum;
    int change = 0;
    if (diff > 0) {
      change = MAX((int)(0.1*diff), 1);
    } else if (diff < 0) {
      change = MIN((int)(0.1*diff), -1);
    }
    
    _currentNum += change;
    [self.transitionDelegate updateLabel:self forNumber:_currentNum];
  } else {
    if ([self.transitionDelegate respondsToSelector:@selector(labelReachedGoalNum:)]) {
      [self.transitionDelegate labelReachedGoalNum:self];
    }
    [self.timer invalidate];
    self.timer = nil;
  }
}

@end

@implementation UnderlinedLabelView

- (void) awakeFromNib {
  self.underlineView = [[UIView alloc] initWithFrame:CGRectZero];
  [self addSubview:self.underlineView];
  
  self.button = [[UIButton alloc] initWithFrame:self.bounds];
  [self addSubview:self.button];
  [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setString:(NSString *)string isEnabled:(BOOL)isEnabled {
  CGSize size = [string sizeWithFont:self.label.font constrainedToSize:self.label.frame.size];
  self.label.text = string;
  self.underlineView.frame = CGRectMake(0, 0, size.width, 1);
  // Have to use size.height/3 because half seems too much
  self.underlineView.center = CGPointMake(self.label.center.x, self.label.center.y+size.height/3+1);
  self.underlineView.backgroundColor = self.label.textColor;
  
  self.button.hidden = YES;
  self.label.hidden = NO;
  self.underlineView.hidden = !isEnabled;
  
  UIView *view = self;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.button.hidden = NO;
  self.label.hidden = YES;
  //  self.underlineView.hidden = YES;
  
  [self.button setImage:image forState:UIControlStateNormal];
  
  self.button.userInteractionEnabled = isEnabled;
}

- (IBAction)buttonClicked:(id)sender {
  [self.delegate labelClicked:self];
}

@end

@implementation CheckboxView

- (void) awakeFromNib {
  _isChecked = !self.checkmark.hidden;
}

- (void) setIsChecked:(int)isChecked {
  _isChecked = isChecked;
  self.checkmark.hidden = !isChecked;
}

- (IBAction)boxClicked:(id)sender {
  self.isChecked = !self.isChecked;
}

@end

@implementation BadgeIcon

- (void) awakeFromNib {
  self.badgeNum = 0;
}

- (void) setBadgeNum:(int)badgeNum {
  _badgeNum = badgeNum;
  
  if (_badgeNum > 0) {
    self.badgeLabel.text = [NSString stringWithFormat:@"%d", _badgeNum];
    self.hidden = NO;
  } else {
    self.hidden = YES;
  }
}

@end

@implementation TouchableSubviewsView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (![super pointInside:point withEvent:event]) {
    return NO;
  }
  
  // Allow all subviews to receive touch.
  for (UIView * foundView in self.subviews) {
    if (!foundView.hidden && [foundView pointInside:[self convertPoint:point toView:foundView] withEvent:event]) {
      return YES;
    }
  }
  return NO;
}

@end
