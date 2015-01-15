//
//  AttackMapViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

#define SCROLL_DISPLAY_TIME 2
#define SCROLL_SPEED_PX_PER_SEC 20

@interface AttackMapIconView : UIView {
  NSString *_name;
}

@property (nonatomic, strong) IBOutlet UIImageView *cityNameIcon;
@property (nonatomic, strong) IBOutlet THLabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIButton *cityButton;
@property (nonatomic, strong) IBOutlet UILabel *cityNumLabel;
@property (nonatomic, strong) IBOutlet UIImageView *shadowIcon;
@property (nonatomic, strong) IBOutlet UIImageView *glowIcon;
@property (nonatomic, strong) IBOutlet UIImageView *bossIcon;
@property (nonatomic, assign) BOOL isLocked;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

- (void) setIsLocked:(BOOL)isLocked bossImage:(NSString *)bossImage element:(Element)element;
- (void) doShake;

- (void) updateForTaskMapElement:(TaskMapElementProto *)elem task:(FullTaskProto *)task isLocked:(BOOL)isLocked;

- (void) displayLabelAndGlow;
- (void) removeLabelAndGlow;

@end

@interface AttackMapStatusView : TouchableSubviewsView <UIScrollViewDelegate> {
  UINib *dropNib;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;
@property (nonatomic, retain) IBOutlet UILabel *sideLabel;

@property (nonatomic, retain) IBOutlet UIView *enterButtonView;
@property (nonatomic, retain) IBOutlet UIView *greyscaleView;

@property (nonatomic, strong) IBOutlet UILabel *availableLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *taskNameScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *dropScrollView;

@property (nonatomic, retain) IBOutlet UIImageView *characterIcon;

@property (nonatomic, retain) IBOutlet UIImageView *doneCheckImage;
@property (nonatomic, retain) IBOutlet UIImageView *rightGradient;
@property (nonatomic, retain) IBOutlet UIImageView *leftGradient;

@property (nonatomic, assign) int taskId;

- (void) updateForTaskId:(int)taskId element:(Element)elem level:(int)level isLocked:(BOOL)isLocked isCompleted:(BOOL)isCompleted oilAmount:(int)oil cashAmount:(int)cash charImgName:(NSString *)charImgName;

@end

@interface PossibleDropView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *iconImage;
@property (nonatomic, retain) IBOutlet CircleMonsterView *circleMonsterView;
@property (nonatomic, strong) IBOutlet UILabel *label;

- (void) updateForReward:(NSString *)imageName labelText:(NSString *)labelText;
- (void) updateForToon:(int)toonId;

@end

@protocol AttackEventViewDelegate <NSObject>

- (void) eventViewSelected:(id)eventView;

@end

@interface AttackEventView : AttackMapStatusView {
  PersistentEventProto_EventType _eventType;
}

@property (nonatomic, retain) IBOutlet UIImageView *monsterImage;
@property (nonatomic, retain) IBOutlet UIImageView *enhanceBubbleImage;
@property (nonatomic, retain) IBOutlet UILabel *cooldownLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedupGemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet UIView *enterView;
@property (nonatomic, retain) IBOutlet UIView *cooldownView;

@property (nonatomic, assign) IBOutlet id<AttackEventViewDelegate> delegate;

@property (nonatomic, assign) int persistentEventId;

- (void) updateForEvo;
- (void) updateForEnhance;
- (void) updateLabels;

@end

@interface LeagueListView : UIView <UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* leagueTable;

@end

@interface LeagueListViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *leagueImage;
@property (nonatomic, strong) IBOutlet NiceFontLabel12 *leagueLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@interface MultiplayerView : UIView <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;
@property (nonatomic, strong) IBOutlet UILabel *cashCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *backButton;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *findMatchView;
@property (nonatomic, strong) IBOutlet UIView *rankView;

@property (nonatomic, strong) IBOutlet LeagueView *leagueView;

@property (nonatomic, strong) IBOutlet LeagueListView *leagueListView;
@property (nonatomic, strong) IBOutlet UIButton *leagueListButton;
@property (nonatomic, strong) IBOutlet UIView *multiplayerHeaderView;

@property (nonatomic, strong) IBOutlet UIImageView *pvpGuysIcon;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UITextView *defendingStatusTextView;

//@property (nonatomic, strong) IBOutletCollection(LeagueDescriptionView) NSArray *leagueDescriptionViews;

- (void) updateForLeague;
- (IBAction) leagueSelected:(id)sender;
- (IBAction) backClicked:(id)sender;

- (void) showHideLeagueList;

@end