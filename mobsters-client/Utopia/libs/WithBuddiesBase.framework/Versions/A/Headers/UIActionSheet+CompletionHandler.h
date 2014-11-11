//
//  UIActionSheet+CompletionHandler.h
//  WithBuddiesCore
//
//  Created by odyth on 7/5/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (CompletionHandler) <UIActionSheetDelegate>

@property (nonatomic, copy) void(^completionHandler)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@end
