//
//  RequestsBattleTableController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClanInfoViewController.h"
#import "RequestsViewController.h"

@interface RequestsBattleCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *resultLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIButton *revengeButton;
@property (nonatomic, retain) IBOutletCollection(ClanTeamMonsterView) NSArray *monsterViews;
@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *cashLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankChangeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rankIcon;

@property (nonatomic, retain) IBOutlet UIView *lootLostView;
@property (nonatomic, retain) IBOutlet UIView *revengeButtonView;

@property (nonatomic, retain) PvpHistoryProto *battleHistory;

@end

@interface RequestsBattleTableController : NSObject <RequestsTableController> {
  RequestsBattleCell *_curClickedCell;
}

@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *noRequestsLabel;

@property (nonatomic, retain) IBOutlet RequestsBattleCell *requestCell;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) NSMutableArray *battles;

@end
