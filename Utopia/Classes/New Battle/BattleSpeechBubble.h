//
//  BattleSpeechBubble.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface BattleSpeechBubble : CCSprite {
  int _curLetter;
}

@property (nonatomic, retain) CCSprite *midBubble;
@property (nonatomic, retain) CCSprite *rightBubble;
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) NSString *text;

+ (id) speechBubbleWithText:(NSString *)text;
- (void) beginLabelAnimation;

@end
