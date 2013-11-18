//
//  GachaponListViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "Globals.h"

@interface GachaponListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *bgdButton;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet BoosterPackProto *boosterPack;

@end

@interface GachaponListViewController : GenViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *listTable;
@property (nonatomic, retain) IBOutlet GachaponListCell *listCell;

- (IBAction)machineClicked:(id)sender;

@end
