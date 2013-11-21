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
#import "MobstersEventProtocol.pb.h"

@interface GachaponPrizeView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterSpinner;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;

- (void) animateFromPoint:(CGPoint)pt withMonsterId:(int)monsterId;
- (IBAction)closeClicked:(id)sender;

@end

@interface GachaponFeaturedView : UIView {
  int _curMonsterId;
}

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *elementIcon;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;

@end

@interface GachaponItemCell : UIView

@property(nonatomic,copy) void (^completion)(void);

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UIImageView *diamondIcon;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end

@interface GachaponViewController : GenViewController <EasyTableViewDelegate, UIScrollViewDelegate> {
  BOOL _isSpinning;
  
  int _curPage;
}

@property (nonatomic, retain) BoosterPackProto *boosterPack;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) BoosterItemProto *prize;

@property (nonatomic, retain) EasyTableView *gachaTable;
@property (nonatomic, retain) IBOutlet UIImageView *machineIcon;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UIView *spinView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet UIView *spotlightContainer;
@property (nonatomic, retain) GachaponFeaturedView *leftFeaturedView;
@property (nonatomic, retain) GachaponFeaturedView *curFeaturedView;
@property (nonatomic, retain) GachaponFeaturedView *rightFeaturedView;
@property (nonatomic, retain) IBOutlet UIScrollView *featuredScrollView;

@property (nonatomic, retain) UIImageView *topBar;

@property (nonatomic, retain) IBOutlet GachaponItemCell *itemCell;
@property (nonatomic, retain) IBOutlet GachaponFeaturedView *featuredView;
@property (nonatomic, retain) IBOutlet GachaponPrizeView *prizeView;

- (id) initWithBoosterPack:(BoosterPackProto *)bpp;

- (IBAction)rightArrowClicked:(id)sender;
- (IBAction)leftArrowClicked:(id)sender;

@end
