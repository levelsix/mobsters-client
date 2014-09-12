//
//  GachaponViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/31/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "Protocols.pb.h"
#import "FocusScrollView.h"
#import "GachaponViews.h"

@interface GachaponViewController : GenViewController <EasyTableViewDelegate, FocusScrollViewDelegate, TabBarDelegate> {
  BOOL _isSpinning;
  
  NSInteger _curPage;
  
  NSInteger _numPuzzlePieces;
  
  NSInteger _cachedDailySpin;
  BOOL      _lastSpinWasFree;
}

@property (nonatomic, retain) BoosterPackProto *boosterPack;
@property (nonatomic, retain) BoosterPackProto *badBoosterPack;
@property (nonatomic, retain) BoosterPackProto *goodBoosterPack;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) BoosterItemProto *prize;

@property (nonatomic, retain) EasyTableView *gachaTable;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;
@property (nonatomic, retain) IBOutlet FocusScrollView *focusScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *machineImage;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UIView *spinView;
@property (nonatomic, retain) IBOutlet UILabel *spinCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spinActionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet GachaponItemCell *itemCell;
@property (nonatomic, retain) IBOutlet GachaponFeaturedView *featuredView;
@property (nonatomic, retain) IBOutlet GachaponPrizeView *prizeView;

@property (nonatomic, retain) IBOutlet ButtonTabBar *navBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *badBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *goodBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *eventBadge;

- (id) initWithBoosterPack:(BoosterPackProto *)bpp;

@end
