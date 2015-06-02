//
//  ProgressBar.m
//  Utopia
//
//  Created by Rob Giusti on 6/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "CCProgressBar.h"

@implementation CCProgressBar

- (id)initBarWithPrefix:(NSString *)prefix background:(NSString *)background {
  if ((self = [super initWithImageNamed:background])) {
    [self setupWithPrefix:prefix];
  }
  return self;
}

- (void) setupWithPrefix:(NSString*)prefix {
  self.prefix = prefix;
  
  self.leftCap = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"cap.png"]];
  self.rightCap = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"cap.png"]];
  self.middleBar = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"middle.png"]];
  
  [self addChild:self.leftCap];
  [self addChild:self.rightCap];
  [self addChild:self.middleBar];
  
  self.leftCap.anchorPoint = ccp(0, 0);
  self.rightCap.anchorPoint = ccp(0, 0);
  self.middleBar.anchorPoint = ccp(0, 0);
  
  CGRect r = self.leftCap.textureRect;
  r.size.width = 2;
  [self.leftCap setTextureRect:r rotated:NO untrimmedSize:self.leftCap.contentSize];
  
  self.rightCap.flipX = YES;
  self.rightCap.position = ccp(self.contentSize.width, 0);
  self.middleBar.position = ccp(self.leftCap.contentSize.width, 0);
  self.middleBar.scaleX = (self.contentSize.width-self.leftCap.contentSize.width-self.rightCap.contentSize.width)/self.middleBar.contentSize.width;
}

- (void) updateForPercentage:(float)percentage {
  self.percentage = clampf(percentage, 0, 1);
  
  float totalWidth = _percentage*self.contentSize.width;
  CGRect r;
  
  r = self.leftCap.textureRect;
  r.size.width = MIN(totalWidth/2, self.leftCap.contentSize.width);
  [self.leftCap setTextureRect:r rotated:NO untrimmedSize:self.leftCap.contentSize];
  
  r = self.rightCap.textureRect;
  r.size.width = self.leftCap.textureRect.size.width;
  [self.rightCap setTextureRect:r rotated:NO untrimmedSize:self.rightCap.contentSize];
  
  self.middleBar.position = ccp(self.leftCap.textureRect.size.width, 0);
  self.middleBar.scaleX = MAX(0, ((self.contentSize.width*self.percentage)-self.leftCap.textureRect.size.width-self.rightCap.textureRect.size.width)/self.middleBar.contentSize.width);
  
  self.rightCap.position = ccp(self.contentSize.width*self.percentage-self.rightCap.textureRect.size.width, 0);
}

@end