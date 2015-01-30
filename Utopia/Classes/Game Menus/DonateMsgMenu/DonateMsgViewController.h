//
//  DonateMsgViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DonateMsgDelegate <NSObject>

- (void) sendClickedWithMessage:(NSString *)message;
- (void) cancelClicked;

@end

@interface DonateMsgViewController : UIViewController <UITextViewDelegate> {
  NSString *_initMsg;
  
  BOOL _isClosing;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) IBOutlet UITextView *msgTextView;

@property (nonatomic, assign) id<DonateMsgDelegate> delegate;

- (id) initWithInitialMessage:(NSString *)msg;

@end
