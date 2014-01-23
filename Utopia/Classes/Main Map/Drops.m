//
//  SilverStack.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Drops.h"
#import "GameMap.h"
#import "Globals.h"
#import "GameState.h"

#define RECT_LEEWAY 10

@implementation Drop

- (id) initWithFile:(NSString *)file {
  if ((self = [super initWithImageNamed:file])) {
    // Set isTouchEnabled to YES so that gesture recognizers will ignore
    self.userInteractionEnabled = YES;
  }
  return self;
}

- (BOOL) hitTestWithWorldPos:(CGPoint)pt {
  CGRect rect = CGRectInset(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), -RECT_LEEWAY, -RECT_LEEWAY);
  
  pt = [self convertToNodeSpace:pt];
  
  if (CGRectContainsPoint(rect, pt)) {
    return YES;
  }
  return NO;
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!_clicked) {
    CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    return [self hitTestWithWorldPos:pt];
  }
  return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CCNode *n = self.parent;
  if ([n isKindOfClass:[GameMap class]]) {
//    GameMap *map = (GameMap *)self.parent;
//    [map pickUpDrop:self];
    _clicked = YES;
  }
}

@end

@implementation SilverStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  if ((self = [super initWithFile:@"coinstack.png"])) {
    amount = amt;
  }
  return self;
}

@end

@implementation GoldStack

@synthesize amount;

- (id) initWithAmount:(int)amt {
  NSString *file = amt == 1 ? @"pickupgold.png" : @"smallgoldstack.png";
  if ((self = [super initWithFile:file])) {
    amount = amt;
  }
  return self;
}

@end
