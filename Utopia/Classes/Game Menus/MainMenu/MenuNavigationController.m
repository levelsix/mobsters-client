//
//  MenuNavigationController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/19/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MenuNavigationController.h"
#import "cocos2d.h"
#import "Globals.h"

static float imgHeight = 42.f;

@implementation CustomNavBar

- (id) init {
  if ((self = [super init])) {
    self.clipsToBounds = NO;
    self.alpha = 0.5;
  }
  return self;
}

- (void) insertSubview:(UIView *)view atIndex:(NSInteger)index {
  if (self.bgdView) {
    NSInteger idx = [self.subviews indexOfObject:self.bgdView];
    if (idx != NSNotFound) {
      [super insertSubview:view atIndex:MAX(idx+1, index)];
    } else {
      [super insertSubview:view atIndex:index];
    }
  } else {
    [super insertSubview:view atIndex:index];
  }
}

- (void) layoutSubviews {
  [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
  UIImage *image = [UIImage imageNamed:@"menutopbar.png"];
  imgHeight = image.size.height;
  [image drawInRect:CGRectMake(0, 0, self.frame.size.width, imgHeight)];
  
  [self setTitleVerticalPositionAdjustment:0.f forBarMetrics:UIBarMetricsDefault];
  
  UIFont *font = [UIFont fontWithName:@"Ziggurat-HTF-Black" size:13.f];
  UIColor *color = [UIColor colorWithWhite:1.f alpha:1.f];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        font, NSFontAttributeName,
                        color, NSForegroundColorAttributeName,
                        nil];
  [self setTitleTextAttributes:dict];
}

- (CGSize) sizeThatFits:(CGSize)size {
  CGSize newSize = CGSizeMake(self.frame.size.width,imgHeight);
  return newSize;
}

@end

static const CGFloat kNewGachaNavBarHeight = 46.f;

@implementation NewGachaNavBar

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  for (UIView* view in self.subviews)
    if ([view isKindOfClass:[CoinBar class]])
      [view setFrame:CGRectMake(0, 0, self.frame.size.width, kNewGachaNavBarHeight)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(self.frame.size.width, kNewGachaNavBarHeight);
}

@end

@implementation MenuNavigationController

- (id) init
{
  self = [super initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
  if (self) {
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  }
  return self;
}

@end

@implementation NewGachaNavigationController

- (id) init
{
  self = [super initWithNavigationBarClass:[NewGachaNavBar class] toolbarClass:nil];
  if (self) {
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  }
  return self;
}

@end
