//
//  RequestPushNotificationViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"

@interface RequestPushNotificationView : TouchableSubviewsView
@property (nonatomic, retain) IBOutlet UILabel *paragragh;
@property (nonatomic, retain) IBOutlet THLabel *cancelLabel;
@property (nonatomic, retain) IBOutlet THLabel *acceptLabel;

- (void) initFonts;

@end

@interface RequestPushNotificationViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIView *requestView;
@property (nonatomic, retain) IBOutlet UIView *BGView;

- (id) initWithMessage:(NSString *) message;
@end
