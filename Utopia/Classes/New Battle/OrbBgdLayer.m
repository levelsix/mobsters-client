//
//  OrbBgdLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OrbBgdLayer.h"
#import "cocos2d.h"

@implementation OrbBgdLayer

- (id) initWithGridSize:(CGSize)gridSize {
  if ((self = [super init])) {
    for (int i = 0; i < gridSize.width; i++) {
      for (int j = 0; j < gridSize.height; j++) {
        NSString *fileName = (i+j)%2==0 ? @"lightsquare.png" : @"darksquare.png";
        CCSprite *square = [CCSprite spriteWithImageNamed:fileName];
        
        [self addChild:square];
        square.position = ccp((i+0.5)*square.contentSize.width, (j+0.5)*square.contentSize.height);
        
        self.contentSize = CGSizeMake(square.position.x+square.contentSize.width/2, square.position.y+square.contentSize.height/2);
      }
    }
    
    [self assembleBorder];
  }
  return self;
}

- (void) assembleBorder {
  CCSprite *leftBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *rightBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *botBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *topBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *blCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *brCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *tlCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *trCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  
  float borderWidth = leftBorder.contentSize.width;
  CGSize cornerSize = blCorner.contentSize;
  
  blCorner.position = ccp(-borderWidth, -borderWidth);
  blCorner.anchorPoint = ccp(0, 0);
  
  brCorner.position = ccp(_contentSize.width+borderWidth, -borderWidth);
  brCorner.flipX = YES;
  brCorner.anchorPoint = ccp(1, 0);
  
  tlCorner.position = ccp(-borderWidth, _contentSize.height+borderWidth);
  tlCorner.flipY = YES;
  tlCorner.anchorPoint = ccp(0, 1);
  
  trCorner.position = ccp(_contentSize.width+borderWidth, _contentSize.height+borderWidth);
  trCorner.flipX = YES;
  trCorner.flipY = YES;
  trCorner.anchorPoint = ccp(1, 1);
  
  float borderScaleX = _contentSize.width-2*(cornerSize.width-borderWidth);
  float borderScaleY = _contentSize.height-2*(cornerSize.height-borderWidth);
  leftBorder.scaleY = borderScaleY; leftBorder.anchorPoint = ccp(1, 0.5);
  rightBorder.scaleY = borderScaleY; rightBorder.anchorPoint = ccp(0, 0.5);
  botBorder.scaleY = borderScaleX; botBorder.rotation = 90; botBorder.anchorPoint = ccp(0, 0.5);
  topBorder.scaleY = borderScaleX; topBorder.rotation = 90; topBorder.anchorPoint = ccp(1, 0.5);
  
  leftBorder.position = ccp(0, self.contentSize.height/2);
  rightBorder.position = ccp(self.contentSize.width, self.contentSize.height/2);
  botBorder.position = ccp(self.contentSize.width/2, 0);
  topBorder.position = ccp(self.contentSize.width/2, self.contentSize.height);
  
  [self addChild:leftBorder z:100];
  [self addChild:rightBorder z:100];
  [self addChild:botBorder z:100];
  [self addChild:topBorder z:100];
  [self addChild:blCorner z:100];
  [self addChild:brCorner z:100];
  [self addChild:tlCorner z:100];
  [self addChild:trCorner z:100];
}

@end
