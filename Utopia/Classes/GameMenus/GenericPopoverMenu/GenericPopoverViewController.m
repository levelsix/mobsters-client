//
//  GenericPopoverViewController.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "GenericPopoverViewController.h"
#import "UIView+Coordinates.h"
#import "NSString+Sizing.h"

@implementation GenericPopoverViewController

- (instancetype) initWithWidth:(CGFloat)popoverWidth title:(NSString*)titleText body:(NSString*)bodyText
{
  self = [super init];
  if (self)
  {
    self.mainView.width = popoverWidth;
    
    _titleText = titleText;
    _bodyText = bodyText;
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.titleTextLabel.text = [_titleText uppercaseString];
  
  // Add line spacing
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  {
    paragraphStyle.lineSpacing = 4.5f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_bodyText
                                                                                         attributes:@{ NSParagraphStyleAttributeName : paragraphStyle,
                                                                                                       NSFontAttributeName : self.bodyTextLabel.font }];
    self.bodyTextLabel.attributedText = attributedString;
  }
  
  // Resize view height based on body text
  CGRect textBoundingRect = [self.bodyTextLabel.attributedText boundingRectWithSize:CGSizeMake(self.bodyTextLabel.width, MAXFLOAT)
                                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                            context:nil];
  {
    const CGFloat spacingTop = self.bodyTextLabel.originY - CGRectGetMaxY(self.titleTextLabel.frame);
    const CGFloat spacingBottom = self.mainView.height - CGRectGetMaxY(self.bodyTextLabel.frame);
    self.bodyTextLabel.height = ceilf(textBoundingRect.size.height);
    self.bodyTextLabel.originY = CGRectGetMaxY(self.titleTextLabel.frame) + spacingTop;
    
    self.mainView.height = CGRectGetMaxY(self.bodyTextLabel.frame) + spacingBottom;
  }
}

@end
