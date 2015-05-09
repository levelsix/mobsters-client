//
//  LeaderBoardViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 5/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeaderBoardObject <NSObject>

- (int) score;
- (NSString *) name;

@optional

- (int) rank;

@end

@interface LeaderBoardViewCell: UITableViewCell

- (void) updateWithRank:(int)rank score:(int)score userName:(NSString *)userName scoreIcon:(NSString *)scoreIcon;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rankBG;
@property (nonatomic, retain) IBOutlet UIImageView *cellBG;
@property (nonatomic, retain) IBOutlet UIImageView *scoreImage;

@end

@interface LeaderBoardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  CGFloat _cellHeight;
  NSString *_scoreName;
  NSString *_scoreIcon;
}
@property (nonatomic, retain) NSArray *leaderList;

@property (nonatomic, retain) IBOutlet UIView *yourRankingHeader;
@property (nonatomic, retain) IBOutlet UIView *LeaderBoardHeaderView;
@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

- (id) initStrengthLeaderBoard;

@end
