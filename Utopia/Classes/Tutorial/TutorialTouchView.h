//
//  TutorialTouchView.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialTouchView : UIView

@property (nonatomic, retain) NSMutableArray *responders;

- (void) addResponder:(UIResponder *)responder;
- (void) removeResponder:(UIResponder *)responder;

@end
