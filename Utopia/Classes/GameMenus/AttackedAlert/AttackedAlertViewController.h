//
//  AttackedAlertViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "ChatCell.h"
#import "HudNotificationController.h"

@interface AttackedAlertViewController : UIViewController <TopBarNotification>{
  int _oilLost;
  int _cashLost;
  int _rankLost;
  dispatch_block_t _completion;
  NSArray *_curDefenses;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;
@property (nonatomic, retain) IBOutlet UIView *resultsContainerView;
@property (nonatomic, retain) IBOutlet UIView *titleView;

@property (nonatomic, retain) IBOutlet UILabel *cashLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet THLabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rankIcon;

@property (nonatomic, retain) IBOutlet UITableView *alertsTable;

@end

@interface AttackAlertCell : PrivateChatListCell

@end
