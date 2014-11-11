//
//  UIAlertView+CompletionHandler.h
//  WithBuddiesCore
//
//  Created by odyth on 7/5/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (CompletionHandler) <UIAlertViewDelegate>

@property (nonatomic, copy) void(^completionHandler)(UIAlertView *alertView, NSInteger buttonIndex, NSString* textInput);
@property (nonatomic, copy) BOOL(^promptValidation)(UITextField *textField, NSRange range, NSString *replacementString);

-(void) showPromptWithValidation:(BOOL (^)(UITextField *textField, NSRange range, NSString *replacementString))promptValidation
                      completion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex, NSString* textInput))completionHandler;

@end
