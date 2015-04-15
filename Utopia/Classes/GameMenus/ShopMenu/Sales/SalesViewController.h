//
//  SalesViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"
#import "PopupSubViewController.h"
#import "SalesMenuDelegate.h"

@interface SalesViewController : PopupSubViewController <SalesMenuDelegate> {
  BOOL _isLoading;
  BOOL _allVcsLoaded;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSArray *viewControllers;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@end
