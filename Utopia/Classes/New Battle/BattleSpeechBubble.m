//
//  BattleSpeechBubble.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleSpeechBubble.h"

@implementation BattleSpeechBubble

+ (id) speechBubbleWithText:(NSString *)text {
  return [[self alloc] initWithText:text];
}

- (id) initWithText:(NSString *)text {
  if ((self = [super initWithImageNamed:@"bubbleleft.png"])) {
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"" fontName:@"Gotham-Medium" fontSize:8.f];
    [self addChild:label z:1];
    label.anchorPoint = ccp(0, 0.5);
    label.color = [CCColor colorWithRed:17.f/255.f green:90.f/255.f blue:100.f/255.f alpha:1.f];
    label.position = ccp(5, self.contentSize.height/2+1);
    self.label = label;
    
    CCSprite *right = [CCSprite spriteWithImageNamed:@"bubbleright.png"];
    [self addChild:right];
    right.anchorPoint = ccp(0,0);
    self.rightBubble = right;
    
    CCSprite *mid = [CCSprite spriteWithImageNamed:@"bubblemiddle.png"];
    [self addChild:mid];
    mid.anchorPoint = ccp(0,0);
    self.midBubble = mid;
    
    self.text = text;
    [self updateLabelText:@""];
    
    self.anchorPoint = ccp(0.7, 0);
    
    label.texture.antialiased = YES;
    self.texture.antialiased = YES;
    mid.texture.antialiased = YES;
    right.texture.antialiased = YES;
  }
  return self;
}

- (void) updateLabelText:(NSString *)newText {
  self.label.string = newText;
  
  self.midBubble.scaleX = MAX(1, self.label.contentSize.width-self.contentSize.width+self.label.position.x*2-self.rightBubble.contentSize.width);
  self.midBubble.position = ccp(self.contentSize.width, 0);
  self.rightBubble.position = ccp(self.contentSize.width+self.midBubble.contentSize.width*self.midBubble.scaleX, 0);
}

- (void) beginLabelAnimation {
  CCActionCallBlock *a = [CCActionCallBlock actionWithBlock:^{
    _curLetter++;
    if (_curLetter <= self.text.length) {
      NSString *str = [self.text substringWithRange:NSMakeRange(0, _curLetter)];
      [self updateLabelText:str];
    }
  }];
  CCActionSequence *seq = [CCActionSequence actions:a, [CCActionDelay actionWithDuration:0.03f], nil];
  CCActionRepeat *rep = [CCActionRepeat actionWithAction:seq times:self.text.length];
  [self runAction:rep];
}

@end
