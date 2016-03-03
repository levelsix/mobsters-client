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
#import "SoundEngine.h"

@implementation ShadowBlurLabel

@dynamic shadowBlur, strokeSize, strokeColor, gradientStartColor, gradientEndColor;

- (void) awakeFromNib {
  if (self.shadowBlur == 0) {
    self.shadowBlur = 0.9f;
  }
}

@end

@implementation NiceFontLabelS

- (void) awakeFromNib {
  self.strokeColor = [UIColor blackColor];
}

- (void) setText:(NSString *)text {
//  [super setText:text];
  self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSStrokeWidthAttributeName : [NSNumber numberWithFloat:-self.strokeSize],
                                                                                     NSStrokeColorAttributeName : self.strokeColor}];
}

@end

@implementation NiceFontLabel

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:[Globals font] size:self.font.pointSize+2];
}

@end

@implementation NiceFontLabelB

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:[Globals font] size:self.font.pointSize+2];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel2

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Medium" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel2R

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  int rSize = [Globals isiPhone6] || [Globals isiPhone6Plus] ? 1 : 0;
  self.font = [UIFont fontWithName:@"Gotham-Medium" size:self.font.pointSize+rSize];
}

@end

@implementation NiceFontLabel2B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Medium" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
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
  // Changed from Aller to Whitney
  self.font = [UIFont fontWithName:@"Whitney-SemiboldItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel6

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Klavika Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel7

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-UltraItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel7B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-UltraItalic" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel8

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel8B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel8T

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel8S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel8WS

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.font.pointSize];
  self.strokeSize = 1.f;
  self.strokeColor = [UIColor whiteColor];
}

@end

@implementation NiceFontLabel9

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel9T

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel9R

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  int rSize = [Globals isiPhone6] || [Globals isiPhone6Plus] ? 1 : 0;
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize+rSize];
}

@end

@implementation NiceFontLabel9B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel9S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel10

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamBlack" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel10R

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  int rSize = [Globals isiPhone6] || [Globals isiPhone6Plus] ? 1 : 0;
  self.font = [UIFont fontWithName:@"GothamBlack" size:self.font.pointSize+rSize];
}

@end

@implementation NiceFontLabel10B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamBlack" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel10S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamBlack" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel10T

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamBlack" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel11

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamMedium-Italic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel12

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel12T

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel12R

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  int rSize = [Globals isiPhone6] || [Globals isiPhone6Plus] ? 1 : 0;
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.font.pointSize+rSize];
}

@end

@implementation NiceFontLabel12B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel12S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel13

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black-Italic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel13B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black-Italic" size:self.font.pointSize];
  self.shadowBlur = 0.9f;
}

@end

@implementation NiceFontLabel13S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Ziggurat-HTF-Black-Italic" size:self.font.pointSize];
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel14

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Black" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel14T

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Black" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel14B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Black" size:self.font.pointSize];
  self.shadowBlur = 1.2f;
}

@end

@implementation NiceFontLabel14S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Black" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel14WS

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Black" size:self.font.pointSize];
  self.strokeSize = 0.5f;
  self.strokeColor = [UIColor whiteColor];
}

@end

@implementation NiceFontLabel15

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel16

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Semibold" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel16B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-Semibold" size:self.font.pointSize];
  self.shadowBlur = 1.2f;
}

@end

@implementation NiceFontLabel17

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Whitney-SemiboldItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel18

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamNarrow-Ultra" size:self.font.pointSize];
}

@end

@implementation NiceFontLabel18B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamNarrow-Ultra" size:self.font.pointSize];
  self.shadowBlur = 1.2f;
}

@end

@implementation NiceFontLabel18S

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"GothamNarrow-Ultra" size:self.font.pointSize];
  self.strokeSize = 1.f;
  self.strokeColor = [UIColor blackColor];
}

@end

@implementation NiceFontLabel19B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Titillium-Black" size:self.font.pointSize];
  self.shadowBlur = 1.2f;
}

@end

@implementation NiceFontLabel20B

- (void) awakeFromNib {
  [Globals adjustFontSizeForUILabel:self];
  self.font = [UIFont fontWithName:@"Titillium-BoldUpright" size:self.font.pointSize];
  self.shadowBlur = 1.2f;
}

@end

@implementation NiceFontButton

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:[Globals font] size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton2

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton3

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Klavika Bold" size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton8

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton9

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Gotham-Bold" size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton9R

- (void) awakeFromNib {
  [super awakeFromNib];
  int rSize = [Globals isiPhone6] || [Globals isiPhone6Plus] ? 1 : 0;
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Gotham-Bold" size:self.titleLabel.font.pointSize+rSize];
}

@end

@implementation NiceFontButton10

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"GothamBlack" size:self.titleLabel.font.pointSize];
}

@end

@implementation NiceFontButton12

- (void) awakeFromNib {
  [super awakeFromNib];
  [Globals adjustFontSizeForSize:self.titleLabel.font.pointSize withUIView:self];
  self.titleLabel.font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:self.titleLabel.font.pointSize];
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
  CGSize size = [self.placeholder getSizeWithFont:self.font constrainedToSize:rect.size];
  rect.origin.y = rect.size.height/2-size.height/2;
  rect.size = size;
  
  UIColor *c = [UIColor colorWithWhite:0.5f alpha:1.f];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, c, NSForegroundColorAttributeName, nil];
  NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self.placeholder attributes:dict];
  [attr drawInRect:rect];
}

@end

@implementation NiceFontTextField2

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:@"Aller-BoldItalic" size:self.font.pointSize];
}

@end

@implementation NiceFontTextField9

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontTextField17

- (void) awakeFromNib {
  self.font =  [UIFont fontWithName:@"Whitney-SemiboldItalic" size:self.font.pointSize];
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

@implementation NiceFontTextView9

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"Gotham-Bold" size:self.font.pointSize];
}

@end

@implementation NiceFontTextView17

- (void) awakeFromNib {
  self.font = [UIFont fontWithName:@"Whitney-SemiboldItalic" size:self.font.pointSize];
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

@implementation DoubleFlipImageView

- (void) awakeFromNib {
  self.transform = CGAffineTransformMakeScale(-1, -1);
}

@end

@implementation FlipButton

- (void) awakeFromNib {
  self.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
}

@end

@implementation RotateLabel8

- (void) awakeFromNib {
  [super awakeFromNib];
  self.superview.transform = CGAffineTransformMakeRotation(-M_PI_2);
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

void undoDelayOnScrollViewHierarchy(UIView *v) {
  if ([v isKindOfClass:[UIScrollView class]]) {
    [(UIScrollView *)v setDelaysContentTouches:NO];
  }
  for (UIView *sv in v.subviews) {
    undoDelayOnScrollViewHierarchy(sv);
  }
}

@implementation CancellableTableView

- (void) awakeFromNib {
  undoDelayOnScrollViewHierarchy(self);
}

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end

@implementation CancellableScrollView

- (void) awakeFromNib {
  undoDelayOnScrollViewHierarchy(self);
}

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
  return YES;
}

@end

@implementation CancellableCollectionView

- (void) awakeFromNib {
  undoDelayOnScrollViewHierarchy(self);
}

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
  
  self.alpha = 0.f;
  [UIView animateWithDuration:0.15f animations:^{
    self.alpha = 1.f;
  } completion:^(BOOL finished) {
    _isDisplayingLoadingView = YES;
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
  } else {
    [self removeFromSuperview];
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
  [super awakeFromNib];
  [self remakeImage];
}

- (void) remakeImage {
  if (self.baseImage) {
    UIImage *img = nil;
    if ([self.baseImage isKindOfClass:[UIImageView class]]) {
      img = [(UIImageView *)self.baseImage image];
    } else {
      // In case this button is inside the view
      self.hidden = YES;
      img = [Globals snapShotView:self.baseImage];
      self.hidden = NO;
    }
    [self setImage:[Globals maskImage:img withColor:[UIColor colorWithWhite:0.f alpha:0.4f]] forState:UIControlStateHighlighted];
  } else {
    [self setImage:nil forState:UIControlStateHighlighted];
  }
}

@end

@implementation DeployCardButton

- (void) playSound {
  [SoundEngine puzzleSwapCharacterChosen];
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
      
      [SoundEngine generalButtonClick];
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
      
      [SoundEngine generalButtonClick];
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

@implementation ButtonTabBar

- (void) awakeFromNib {
  if (!self.inactiveTextColor && !self.activeTextColor) {
    self.inactiveTextColor = [UIColor colorWithRed:8/255.f green:114/255.f blue:161/255.f alpha:1.f];
    self.activeTextColor = [UIColor colorWithRed:19/255.f green:170/255.f blue:238/255.f alpha:1.f];
  }
  
  self.icon1.userInteractionEnabled = NO;
  self.icon2.userInteractionEnabled = NO;
  self.icon3.userInteractionEnabled = NO;
  
  [self clickButton:1];
}

- (UIButton *) getButton:(int)button {
  return (UIButton *)[self viewWithTag:button];
}

- (void) clickButton:(int)button {
  if (!self.label1.highlightedTextColor) {
    UIColor *inactiveText = self.inactiveTextColor;
    UIColor *inactiveShadow = self.inactiveShadowColor;
    self.label1.textColor = inactiveText;
    self.label1.shadowColor = inactiveShadow;
    self.label2.textColor = inactiveText;
    self.label2.shadowColor = inactiveShadow;
    self.label3.textColor = inactiveText;
    self.label3.shadowColor = inactiveShadow;
  } else {
    self.label1.highlighted = NO;
    self.label2.highlighted = NO;
    self.label3.highlighted = NO;
  }
  
  self.icon1.highlighted = NO;
  self.icon2.highlighted = NO;
  self.icon3.highlighted = NO;
  
  UILabel *label = nil;
  UIImageView *icon = nil;
  if (button == 1) {
    label = self.label1;
    icon = self.icon1;
  } else if (button == 2) {
    label = self.label2;
    icon = self.icon2;
  } else if (button == 3) {
    label = self.label3;
    icon = self.icon3;
  }
  if (label) {
    UIView *buttonView = [self viewWithTag:button];
    CGPoint center = [self.selectedView.superview convertPoint:buttonView.center fromView:buttonView.superview];
    self.selectedView.center = ccp(center.x, self.selectedView.center.y);
    self.selectedView.hidden = NO;
  } else {
    self.selectedView.hidden = YES;
  }
  
  for (int i = 1; i <= 3; i++) {
    UIButton *b = (UIButton *)[self viewWithTag:i];
    b.enabled = i != button;
  }
  
  // Check if it has a highlightedTextColor before highlighting.
  if (!label.highlightedTextColor) {
    label.textColor = self.activeTextColor;
    label.shadowColor = self.activeShadowColor;
  } else {
    label.highlighted = YES;
  }
  icon.highlighted = YES;
}

- (IBAction) buttonClicked:(id)sender {
  NSInteger tag = [(UIView *)sender tag];
  if (tag == 1) {
    if ([self.delegate respondsToSelector:@selector(button1Clicked:)]) {
      [self.delegate button1Clicked:self];
    }
  } else if (tag == 2) {
    if ([self.delegate respondsToSelector:@selector(button2Clicked:)]) {
      [self.delegate button2Clicked:self];
    }
  } else if (tag == 3) {
    if ([self.delegate respondsToSelector:@selector(button3Clicked:)]) {
      [self.delegate button3Clicked:self];
    }
  }
}

- (void) button:(int)button shouldBeHidden:(BOOL)hidden {
  UILabel *label = nil;
  UIImageView *icon = nil;
  if (button == 1) {
    label = self.label1;
    icon = self.icon1;
  } else if (button == 2) {
    label = self.label2;
    icon = self.icon2;
  } else if (button == 3) {
    label = self.label3;
    icon = self.icon3;
  }
  label.hidden = hidden;
  icon.hidden = hidden;
  [[self viewWithTag:button] setHidden:hidden];
}

@end

@implementation NewGachaTabBar

- (void) awakeFromNib {
  if (!_inactiveTextColors && !_activeTextColors) {
    _inactiveTextColors = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor whiteColor], [UIColor whiteColor], nil];
    _activeTextColors = [NSArray arrayWithObjects:
                         [UIColor colorWithRed:35.f/255.f green:139.f/255.f blue:255.f/255.f alpha:1.f],
                         [UIColor colorWithRed:255.f/255.f green:0.f/255.f blue:138.f/255.f alpha:1.f],
                         [UIColor whiteColor], nil];
    self.inactiveShadowColor = [UIColor colorWithWhite:0.f alpha:.5f];
    self.activeShadowColor = nil;
  }
  
  if      ([Globals isSmallestiPhone])  self.icon1.highlightedImage = [UIImage imageNamed:@"4basicgrabgachatabactive.png"];
  else if ([Globals isiPhone6])         self.icon1.highlightedImage = [UIImage imageNamed:@"6basicgrabgachatabactive.png"];
  else if ([Globals isiPhone6Plus])     self.icon1.highlightedImage = [UIImage imageNamed:@"6plusbasicgrabgachatabactive.png"];
  else if (![Globals isiPad])           self.icon1.highlightedImage = [UIImage imageNamed:@"5basicgrabgachatabactive.png"];
  
  self.rightTabShadow.transform = CGAffineTransformMakeScale(-1.f, 1.f);
  
  [self clickButton:1];
}

- (void) clickButton:(int)button {
  UIImageView* icon = nil;
  UILabel* label = nil;
  switch (button) {
    case 1:
      icon = self.icon1;
      label = self.label1;
      break;
    case 2:
      icon = self.icon2;
      label = self.label2;
      break;
    case 3:
      icon = self.icon3;
      label = self.label3;
      break;
      
    default:
      return;
  }
  
  self.label1.textColor = _inactiveTextColors[0];
  self.label1.shadowColor = self.inactiveShadowColor;
  self.label2.textColor = _inactiveTextColors[1];
  self.label2.shadowColor = self.inactiveShadowColor;
  self.label3.textColor = _inactiveTextColors[2];
  self.label3.shadowColor = self.inactiveShadowColor;
  
  self.icon1.highlighted = NO;
  self.icon2.highlighted = NO;
  self.icon3.highlighted = NO;
  
  icon.highlighted = YES;
  label.textColor = _activeTextColors[button - 1];
  label.shadowColor = self.activeShadowColor;
  
  for (int i = 1; i <= 3; ++i) {
    UIButton* b = (UIButton*)[self viewWithTag:i];
    if (b) b.enabled = (i != button);
  }
}

- (void) button:(int)button shouldBeHidden:(BOOL)hidden {
  switch (button) {
    case 1:
      self.tab1.hidden = hidden;
      break;
    case 2:
      self.tab2.hidden = hidden;
      break;
    case 3:
      // We really just expect the third tab to be hidden or not...
      self.tab3.hidden = hidden;
      if (hidden) {
        self.rightTabShadow.originX = self.tab3.originX;
        self.width = CGRectGetMaxX(self.rightTabShadow.frame);
      }
      self.originX = (self.superview.width - self.width) * .5f;
      break;
      
    default:
      return;
  }
}

@end

@implementation NumTransitionLabel

- (void) instaMoveToNum:(uint64_t)num {
  _currentNum = num;
  _goalNum = num;
  [self.transitionDelegate updateLabel:self forNumber:_currentNum];
}

- (void) transitionToNum:(uint64_t)num {
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
    int64_t diff = _goalNum - _currentNum;
    int64_t change = 0;
    if (diff > 0) {
      change = MAX((int)(0.08*diff), 1.f);
    } else if (diff < 0) {
      change = MIN((int)(0.08*diff), -1.f);
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
  CGSize size = [string getSizeWithFont:self.label.font constrainedToSize:self.label.frame.size];
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
  [SoundEngine generalButtonClick];
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
  self.alpha = 0.f;
  self.badgeNum = 0;
  self.userInteractionEnabled = NO;
}

- (void) setBadgeNum:(NSInteger)badgeNum {
  [UIView animateWithDuration:0.2f animations:^{
    [self instantlySetBadgeNum:badgeNum];
  }];
}

- (void) instantlySetBadgeNum:(NSInteger)badgeNum
{
  _badgeNum = badgeNum;
  
  if (_badgeNum > 0) {
    self.badgeLabel.text = [NSString stringWithFormat:@"%d", (int)_badgeNum];
    self.alpha = 1.f;
  } else {
    self.alpha = 0.f;
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
    if (!foundView.hidden && foundView.alpha != 0.f && foundView.userInteractionEnabled &&
        [foundView pointInside:[self convertPoint:point toView:foundView] withEvent:event]) {
      return YES;
    }
  }
  return NO;
}

@end

#pragma mark - Sound buttons

@implementation SoundButton

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self awakeFromNib];
  }
  return self;
}

- (void) awakeFromNib {
  [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchDown];
  
  //  [self addTarget:self action:@selector(getSmaller) forControlEvents:UIControlEventTouchDown];
  //  [self addTarget:self action:@selector(getBigger) forControlEvents:UIControlEventTouchUpInside];
  //  [self addTarget:self action:@selector(getSmaller) forControlEvents:UIControlEventTouchDragEnter];
  //  [self addTarget:self action:@selector(getBigger) forControlEvents:UIControlEventTouchDragExit];
  //  [self addTarget:self action:@selector(getBigger) forControlEvents:UIControlEventTouchCancel];
  //  self.adjustsImageWhenHighlighted = NO;
}

- (void) buttonClicked {
  if (!self.dontPlaySound) {
    [self playSound];
  }
}

- (void) playSound {
  NSLog(@"Implement this..");
}

- (void) animateButton {
  if (self.highlighted) {
    [self getSmaller];
  } else {
    [self getBigger];
  }
}

//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//  CGFloat boundsExtension = 100.0f;
//  CGRect outerBounds = CGRectInset(self.bounds, -1 * boundsExtension, -1 * boundsExtension);
//
//  BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:self]);
//  BOOL previousTouchInside = CGRectContainsPoint(outerBounds, [touch previousLocationInView:self]);
//  if (touchOutside)
//  {
//    if (previousTouchInside) {
//      NSLog(@"Sending UIControlEventTouchDragExit");
//      [self sendActionsForControlEvents:UIControlEventTouchDragExit];
//    } else {
//      [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
//    }
//  } else {
//    if (!previousTouchInside) {
//      NSLog(@"Sending UIControlEventTouchDragEnter");
//      [self sendActionsForControlEvents:UIControlEventTouchDragEnter];
//    } else {
//      [self sendActionsForControlEvents:UIControlEventTouchDragInside];
//    }
//  }
//  return YES;//[super continueTrackingWithTouch:touch withEvent:event];
//}

- (void) getSmaller {
  [UIView animateWithDuration:0.1 animations:^{
    self.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
  }];
}

- (void) getBigger {
  [UIView animateWithDuration:0.1 animations:^{
    self.transform = CGAffineTransformIdentity;
  }];
}

@end

@implementation CloseButton

- (void) playSound {
  [SoundEngine closeButtonClick];
}

@end

@implementation UpgradeButton

- (void) playSound {
  [SoundEngine structUpgradeClicked];
}

@end

@implementation CollectButton

- (void) playSound {
  [SoundEngine secretGiftCollectClicked];
}

@end

@implementation GemsButton

- (void) playSound {
  [SoundEngine itemSelectUseGems];
}

@end

@implementation ItemSelectButton

- (void) playSound {
  if (_type == ItemTypeItemOil) {
    [SoundEngine itemSelectUseOil];
  } else if (_type == ItemTypeItemCash) {
    [SoundEngine itemSelectUseCash];
  } else if (_type == ItemTypeSpeedUp) {
    [SoundEngine itemSelectUseSpeedup];
  }
}

@end

@implementation GeneralButton

- (void) playSound {
  [SoundEngine generalButtonClick];
}

@end

@implementation LeagueView

- (void) updateForUserLeague:(UserPvpLeagueProto *)upvp ribbonSuffix:(NSString *)ribbonSuffix {
  
  GameState *gs = [GameState sharedGameState];
  PvpLeagueProto *pvp = [gs leagueForId:upvp.leagueId];
  if (!upvp && gs.staticLeagues.count > 0) {
    pvp = gs.staticLeagues[0];
    //upvp = [[[[UserPvpLeagueProto builder] setLeagueId:pvp.leagueId] setRank:pvp.numRanks] build];
  }
  
  NSString *league = pvp.imgPrefix;
  int rank = upvp ? upvp.rank : 100;
  [Globals imageNamed:[league stringByAppendingString:ribbonSuffix] withView:self.leagueBgd greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  [Globals imageNamed:[league stringByAppendingString:[Globals isiPad] ? @"big.png" : @"icon.png"] withView:self.leagueIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  self.leagueLabel.text = pvp.leagueName;
  self.rankLabel.text = [Globals commafyNumber:rank];
  self.rankQualifierLabel.text = [Globals qualifierStringForNumber:rank];
  
  CGSize size = [self.rankLabel.text getSizeWithFont:self.rankLabel.font constrainedToSize:self.rankLabel.frame.size];
  CGRect r = self.rankQualifierLabel.frame;
  r.origin.x = self.rankLabel.frame.origin.x+size.width+5;
  self.rankQualifierLabel.frame = r;
  
  r = self.placeLabel.frame;
  r.origin.x = self.rankQualifierLabel.frame.origin.x;
  self.placeLabel.frame = r;
  
  //float leftSide = CGRectGetMaxX(self.rankLabel.frame)-size.width;
  //size = [self.placeLabel.text getSizeWithFont:self.placeLabel.font];
  //float rightSide = CGRectGetMinX(self.placeLabel.frame)+size.width;
  //float midX = leftSide+(rightSide-leftSide)/2;
  
  //float distFromCenter = midX-self.rankLabel.superview.frame.size.width/2;
  //CGPoint curCenter = self.rankLabel.superview.center;
  //self.rankLabel.superview.center = ccp(curCenter.x-distFromCenter, curCenter.y);
}

@end

@implementation PopupShadowView

- (void) awakeFromNib {
  self.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOpacity = 0.8;
  self.layer.shadowOffset = CGSizeMake(0, 1);
  self.layer.shadowRadius = 2.f;
}

@end

@implementation SplitImageProgressBar

- (void) awakeFromNib {
  [super awakeFromNib];
  
  self.leftCap.contentMode = UIViewContentModeLeft;
  self.rightCap.contentMode = UIViewContentModeLeft;
  self.middleBar.contentMode = UIViewContentModeScaleToFill;
  
  self.rightCap.transform = CGAffineTransformMakeScale(-1, 1);
  
  self.leftCap.centerY = self.height/2;
  self.rightCap.centerY = self.height/2;
  self.middleBar.centerY = self.height/2;
  
  [self setPercentage:1.f];
}

- (void) setPercentage:(float)percentage {
  _percentage = clampf(percentage, 0.f, 1.f);
  
  // Always add 2 pixels because edges of caps are usually empty
  float totalWidth = (int)roundf(_percentage*(self.frame.size.width-2))+2;
  if (_percentage < .001f) totalWidth = 0.f;
  CGRect r;
  
  r = self.leftCap.frame;
  r.size.width = MIN(ceilf(totalWidth/2), self.leftCap.image.size.width);
  self.leftCap.frame = r;
  
  r = self.rightCap.frame;
  r.size.width = self.leftCap.frame.size.width;
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.origin.x = totalWidth-r.size.width;
  } else {
    r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  }
  self.rightCap.frame = r;
  
  r = self.middleBar.frame;
  r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.size.width = self.rightCap.frame.origin.x-r.origin.x;
  } else {
    r.size.width = 0;
  }
  self.middleBar.frame = r;
  
  if (self.isRightToLeft) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
  } else {
    self.transform = CGAffineTransformIdentity;
  }
}

- (void) animateToPercentage:(float)percentage duration:(float)duration completion:(dispatch_block_t)completion {
  _basePercentage = self.percentage;
  _finalPercentage = percentage;
  _duration = duration;
  _completion = completion;
  _timePassed = 0;
  _shouldStopAnimating = NO;
  
  CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateBar:)];
  [link setFrameInterval:1];
  [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) stopAnimation {
  _shouldStopAnimating = YES;
}

- (void) updateBar:(CADisplayLink *)link {
  if (!_shouldStopAnimating) {
    _timePassed += link.duration;
    float timePerc = clampf(_timePassed/_duration, 0.f, 1.f);
    self.percentage = _basePercentage + (_finalPercentage-_basePercentage)*timePerc;
    
    if (timePerc >= 1.f) {
      [link invalidate];
      
      if (_completion) {
        _completion();
      }
    }
  } else {
    [link invalidate];
  }
}

@end

@implementation EmbeddedNibView

- (id) init {
  if ((self = [super init])) {
    self.autoresizesSubviews = NO;
    self.frame = [self loadNib];
    self.autoresizesSubviews = YES;
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self loadNib];
  }
  return self;
}

- (CGRect) loadNib {
  UIView *oldContainer = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
  
  for (UIView *v in oldContainer.subviews) {
    [self addSubview:v];
  }
  
  self.backgroundColor = [UIColor clearColor];
  
  return oldContainer.frame;
}

@end

@implementation ShrinkOnlyImageView

- (void) awakeFromNib {
  [super awakeFromNib];
  
  _origFrame = self.frame;
  
  self.contentMode = UIViewContentModeScaleAspectFit;
}

- (void) setImage:(UIImage *)image {
  [super setImage:image];
  
  self.frame = _origFrame;
  
  // Don't increase size of smaller images so need to shrink the view
  if (self.image) {
    CGSize s = self.image.size;
    if (s.height < _origFrame.size.height && s.width < _origFrame.size.width) {
      CGPoint center = self.center;
      self.size = s;
      self.center = center;
    }
  }
}

@end
