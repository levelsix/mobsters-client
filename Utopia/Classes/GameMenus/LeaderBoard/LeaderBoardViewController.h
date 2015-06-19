//
//  LeaderBoardViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 5/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "LeaderBoardObject.h"
#import "ChatView.h"

@interface LeaderBoardBotBar : UIView

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isUp;

- (void) scrollViewDidScrollCheck:(UIScrollView *)scrollView;

- (void) animateIn:(dispatch_block_t)completion;
- (void) animateOut:(dispatch_block_t)completion;

@end

@interface LeaderBoardViewCell : UITableViewCell

- (void)updateWithLeaderBoardObject:(id<LeaderBoardObject>)leaderInfo scoreIcon:(NSString *)scoreIcon;
- (void) updateWithRank:(int)rank score:(long)score userName:(NSString *)userName scoreIcon:(NSString *)scoreIcon;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rankBG;
@property (nonatomic, retain) IBOutlet UIImageView *cellBG;
@property (nonatomic, retain) IBOutlet UIImageView *scoreImage;
@property (nonatomic, retain) IBOutlet UIImageView *starImageView;

@end

@interface LeaderBoardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ChatPopoverDelegate> {
  CGFloat _cellHeight;
  NSString *_scoreName;
  NSString *_scoreIcon;
  id<LeaderBoardObject> _clickedLeader;
  int _highestRankShown;
  int _highestRankToShow;
  long _ownScore;
  BOOL _moreScoresAvailable;
  BOOL _waitingOnServer;
}

@property (nonatomic, retain) id<LeaderBoardObject> ownRanking;
@property (nonatomic, retain) NSMutableArray *leaderList;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) IBOutlet UIView *yourRankingHeader;
@property (nonatomic, retain) IBOutlet UIView *leaderboardHeaderView;
@property (nonatomic, retain) IBOutlet UIView *topHeaderView;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadingViewCell;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingViewIndicator;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *tableLoadingIndicator;
@property (nonatomic, retain) IBOutlet ChatPopoverView *popoverView;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet LeaderBoardBotBar *botBar;

- (id) initStrengthLeaderBoard;

@end
