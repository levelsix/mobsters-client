//
//  MSWindow.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookWebViewDelegate : NSObject <UIWebViewDelegate>

@property (nonatomic, assign) id<UIWebViewDelegate> realDelegate;

@end

@interface MSWindow : UIWindow

@property (nonatomic, assign) BOOL silentlyAcceptFacebookRequests;
@property (nonatomic, retain) NSMutableArray *facebookDelegates;

@end
