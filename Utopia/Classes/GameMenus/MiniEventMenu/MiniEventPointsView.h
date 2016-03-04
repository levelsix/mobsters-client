//
//  MiniEventPointsView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniEventManager.h"

@class THLabel;

@interface MiniEventPointsView : UIView <MiniEventInfoViewProtocol, UITableViewDataSource>
{
  NSMutableArray* _actionList;
}

@property (nonatomic, retain) IBOutlet UIImageView* eventInfoImage;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoName;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoDesc;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoTimeLeft;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoPointsEearned;
@property (nonatomic, retain) IBOutlet UITableView* eventActionList;

@end
