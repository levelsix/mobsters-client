//
//  EmbeddedScrollingUpgradeView.h
//  Utopia
//
//  Created by Kenneth Cox on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "DetailViewController.h"

@protocol EmbeddedDelegate <NSObject>

- (void) goClicked:(int)prereqId;
- (void) detailsClicked:(int)index;

@end

@interface DetailsPrereqView : UIView
@property (nonatomic, assign) IBOutlet UIImageView *checkIcon;
@property (nonatomic, assign) IBOutlet UILabel *prereqLabel;
@property (nonatomic, assign) IBOutlet UIButton *goButton;

@property (nonatomic, assign) IBOutlet id<EmbeddedDelegate> delegate;
@end

@interface DetailsProgressBarView : UIView
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *detailName;
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *increaseDescription;
@property (nonatomic, assign) IBOutlet NiceFontButton9 *detailButton;
@property (nonatomic, assign) IBOutlet UIView *buttonView;

@property (nonatomic, assign) IBOutlet SplitImageProgressBar *frontBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *backBar;

@property (nonatomic, assign) IBOutlet id<EmbeddedDelegate> delegate;

@end

@interface DetailsTitleBarView : UIView

@property (nonatomic, assign) IBOutlet UILabel *title;

@end

@interface DetailsStrengthView : UIView
@property (nonatomic, assign) IBOutlet UILabel *strengthLabel;

@end

@interface EmbeddedScrollingUpgradeView : EmbeddedNibView <EmbeddedDelegate>{
  float _curY;
}

@property (nonatomic, assign) IBOutlet UIView *view;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet UIView *contentView;

@property (nonatomic, retain) UIView *townHallUnlocksView;

@property (nonatomic, assign) IBOutlet id<EmbeddedDelegate> delegate;

- (void) updateForGameTypeProto:(id<GameTypeProtocol>)gameProto;
- (void) updateForTownHall:(id<GameTypeProtocol>)gameProto;

@end
