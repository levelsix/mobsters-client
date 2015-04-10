//
//  GenericPopoverViewController.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopoverViewController.h"

@interface GenericPopoverViewController : PopoverViewController
{
  NSString* _titleText;
  NSString* _bodyText;
}

@property (nonatomic, retain) IBOutlet UILabel* titleTextLabel;
@property (nonatomic, retain) IBOutlet UILabel* bodyTextLabel;

- (instancetype) initWithWidth:(CGFloat)popoverWidth title:(NSString*)titleText body:(NSString*)bodyText;

@end
