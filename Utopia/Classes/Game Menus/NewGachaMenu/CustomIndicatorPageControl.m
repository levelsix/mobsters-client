//
//  CustomIndicatorPageControl.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "CustomIndicatorPageControl.h"

@implementation CustomIndicatorPageControl

-(id)initWithCoder:(NSCoder*)aDecoder
{
  if(self = [super initWithCoder:aDecoder])
  {
    self.activeImage = [UIImage imageNamed:@"gachaactivedot.png"];
    self.inactiveImage = [UIImage imageNamed:@"gachainactivedot.png"];
  }
  return self;
}

-(void)updateDots
{
   for (int i = 0; i < [self.subviews count]; ++i)
   {
     UIView* dotView = [self.subviews objectAtIndex:i];
     if (dotView.subviews && dotView.subviews.count == 1)
     {
       UIImageView* customDot = [dotView.subviews objectAtIndex:0];
       [customDot setImage:(i == self.currentPage) ? self.activeImage : self.inactiveImage];
     }
     else
     {
       UIImageView* customDot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dotView.frame.size.width, dotView.frame.size.height)];
       [customDot setImage:(i == self.currentPage) ? self.activeImage : self.inactiveImage];
       [dotView addSubview:customDot];
     }
   }
}

-(void)setCurrentPage:(NSInteger)page
{
  [super setCurrentPage:page];
  
  [self updateDots];
}

@end
