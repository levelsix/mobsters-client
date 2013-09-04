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

static float imgHeight = 40.f;

@implementation CustomNavBar

- (void)drawRect:(CGRect)rect {
  UIImage *image = [UIImage imageNamed:@"menutopbar.png"];
  imgHeight = image.size.height;
  [image drawInRect:CGRectMake(0, 0, self.frame.size.width, imgHeight)];
  [self setTitleVerticalPositionAdjustment:-3.f forBarMetrics:UIBarMetricsDefault];
  
  UIFont *font = [UIFont fontWithName:[Globals font] size:24.f];
  UIColor *color = [UIColor colorWithWhite:0.f alpha:0.8f];
  UIColor *shadow = [UIColor colorWithWhite:1.f alpha:0.5f];
  NSValue *offset = [NSValue valueWithUIOffset:UIOffsetMake(0, 1)];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        font, UITextAttributeFont,
                        color, UITextAttributeTextColor,
                        shadow, UITextAttributeTextShadowColor,
                        offset, UITextAttributeTextShadowOffset,
                        nil];
  [self setTitleTextAttributes:dict];
}

- (void) setFrame:(CGRect)frame {
  frame.size.height = imgHeight;
  [super setFrame:frame];
}

@end

@implementation MenuNavigationController

- (id) init
{
  self = [super initWithNavigationBarClass:[CustomNavBar class] toolbarClass:nil];
  if (self) {
    [self.view insertSubview:[[[UIImageView alloc] initWithImage:[Globals imageNamed:@"mainmenubg.png"]] autorelease] atIndex:0];
  }
  return self;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  [super pushViewController:viewController animated:animated];
  self.navigationBar.frame = CGRectMake(0, 0, self.navigationBar.frame.size.width, imgHeight);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  self.navigationBar.frame = CGRectMake(0, 0, self.navigationBar.frame.size.width, imgHeight);
}

@end
