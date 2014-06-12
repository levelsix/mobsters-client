//
//  ClanBrowseViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "Globals.h"

typedef enum {
  kBrowseAll,
  kBrowseSearch
} ClanBrowseState;

@interface BrowseSearchCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UITextField *textField;

@end

@interface BrowseClanCell : UITableViewCell

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;
@property (nonatomic, assign) IBOutlet UILabel *topLabel;
@property (nonatomic, assign) IBOutlet UILabel *membersLabel;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) IBOutlet UIView *buttonView;
@property (nonatomic, assign) IBOutlet UILabel *buttonLabel;
@property (nonatomic, assign) IBOutlet UIButton *redButton;
@property (nonatomic, assign) IBOutlet UIImageView *iconImage;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;

@end

@interface ClanBrowseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  BOOL isSearching;
  BOOL _reachedEnd;
}

@property (nonatomic, assign) ClanBrowseState state;
@property (nonatomic, retain) NSMutableArray *clanList;
@property (nonatomic, retain) IBOutlet UITableView *browseClansTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet BrowseClanCell *clanCell;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadingCell;

@property (nonatomic, copy) NSString *searchString;

@property (nonatomic, assign) BOOL shouldReload;

- (void) reload;
- (void) loadClans:(NSArray *)clans isForSearch:(BOOL)search;

- (IBAction)rightButtonClicked:(id)sender;

@end