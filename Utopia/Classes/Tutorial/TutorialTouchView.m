//
//  TutorialTouchView.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialTouchView.h"

@implementation TutorialTouchView

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.responders = [NSMutableArray array];
  }
  return self;
}

- (void) addResponder:(UIResponder *)responder {
  [self.responders addObject:responder];
}

- (void) removeResponder:(UIResponder *)responder {
  [self.responders removeObject:responder];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *cp = [self.responders copy];
  for (UIResponder *resp in cp) {
    [resp touchesBegan:touches withEvent:event];
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *cp = [self.responders copy];
  for (UIResponder *resp in cp) {
    [resp touchesEnded:touches withEvent:event];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *cp = [self.responders copy];
  for (UIResponder *resp in cp) {
    [resp touchesMoved:touches withEvent:event];
  }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *cp = [self.responders copy];
  for (UIResponder *resp in cp) {
    [resp touchesCancelled:touches withEvent:event];
  }
}

@end
