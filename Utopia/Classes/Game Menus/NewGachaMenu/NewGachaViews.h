//
//  NewGachaViews.h
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface NewGachaPrizeView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterSpinner;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *pieceLabel;

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *animateViews;

- (void) animateWithMonsterId:(int)monsterId;
- (void) animateWithMonsterId:(int)monsterId numPuzzlePieces:(NSInteger)numPuzzlePieces;
- (void) animateWithGems:(int)numGems;
- (IBAction)closeClicked:(id)sender;

@end

@interface NewGachaFeaturedView : UIView {
  int _curMonsterId;
}

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *elementIcon;
@property (nonatomic, retain) IBOutlet UILabel *elementLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;

@property (nonatomic, retain) IBOutlet UIImageView *coverGradient;

- (void) updateForMonsterId:(int)monsterId;

@end

@interface NewGachaItemCell : UIView

@property(nonatomic,copy) void (^completion)(void);

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UIImageView *shadowIcon;
@property (nonatomic, retain) IBOutlet UIImageView *diamondIcon;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item;
- (void) shakeIconNumTimes:(int)numTimes durationPerShake:(float)duration delay:(float)delay completion:(void (^)(void))comp;

@end
