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

@property (nonatomic, retain) IBOutlet UIImageView* eventInfoBackground;
@property (nonatomic, retain) IBOutlet UIImageView* eventInfoImage;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoName;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoDesc;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoEndsIn;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoTimeLeft;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoMyPoints;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoPointsEearned;
@property (nonatomic, retain) IBOutlet UITableView* eventActionsList;

@end
