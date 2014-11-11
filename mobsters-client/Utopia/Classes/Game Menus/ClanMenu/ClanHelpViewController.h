//
//  ClanHelpViewController.h
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupSubViewController.h"

#import "ClanHelp.h"

@interface ClanHelpCell : UITableViewCell

@property (nonatomic, assign) IBOutlet CircleMonsterView *userIcon;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *actionLabel;
@property (nonatomic, assign) IBOutlet UILabel *numHelpsLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, assign) IBOutlet UIView *helpButtonView;
@property (nonatomic, assign) IBOutlet UIView *helpedView;

@property (nonatomic, retain) id<ClanHelp> clanHelp;

@end

@interface ClanHelpViewController : PopupSubViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *helpTable;
@property (nonatomic, retain) IBOutlet UILabel *noHelpsLabel;

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;

@property (nonatomic, retain) IBOutlet UIView *helpAllView;

@property (nonatomic, retain) NSArray *helpsArray;

@end
