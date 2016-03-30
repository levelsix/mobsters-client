//
//  NewGachaViews.h
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface NewGachaPrizeStatsView : EmbeddedNibView

@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UIImageView *pieceIcon;
@property (nonatomic, retain) IBOutlet UILabel *pieceLabel;
@property (nonatomic, retain) IBOutlet UILabel *pieceSeparator;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *powerLabel;

@property (nonatomic, retain) IBOutlet UIImageView* skillsSeparator;
@property (nonatomic, retain) IBOutlet UIView *offensiveSkillView;
@property (nonatomic, retain) IBOutlet UIView *defensiveSkillView;
@property (nonatomic, retain) IBOutlet UIImageView *offensiveSkillIcon;
@property (nonatomic, retain) IBOutlet UIImageView *defensiveSkillIcon;
@property (nonatomic, retain) IBOutlet UILabel *offensiveSkillName;
@property (nonatomic, retain) IBOutlet UILabel *defensiveSkillName;

@end

@interface NewGachaPrizeView : UIView <UIScrollViewDelegate>
{
  NSMutableArray* _characterImageViews;
  NSMutableArray* _characterStatsViews;
  
  NSArray*  _characterDescriptors;
  NSInteger _currentCharacterIndex;

  UIImageView *_lightCircleDuplicate;
  UIImageView *_whiteLightCircleDuplicate;
  UIImageView *_characterWhite;
  
  UIView *_particleEffectView;
  
  BOOL _firstTimeLoadingFromNib;
  BOOL _skippingAnimations;
  BOOL _startedNextRevealSoundEffect;
}

@property (nonatomic, retain) IBOutlet UIView* animationContainerView;
@property (nonatomic, retain) IBOutlet NewGachaPrizeStatsView* statsContainerView;

@property (nonatomic, retain) IBOutlet UIScrollView* contentScrollView;   // Interactable
@property (nonatomic, retain) IBOutlet UIScrollView* characterScrollView; // Scrolls in sync with contentScrollView

@property (nonatomic, retain) IBOutlet UIPageControl* contentPageControl;
@property (nonatomic, retain) IBOutlet UILabel* contentPageLabel;

@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *animateImageViews;

@property (nonatomic, retain) IBOutlet UIImageView* background;
@property (nonatomic, retain) IBOutlet UIImageView* characterShadow;
@property (nonatomic, retain) IBOutlet UIImageView* character;
@property (nonatomic, retain) IBOutlet UIImageView* characterWhite;
@property (nonatomic, retain) IBOutlet UIImageView* elementbigFlash;
@property (nonatomic, retain) IBOutlet UIImageView* lightCircle;
@property (nonatomic, retain) IBOutlet UIImageView* whiteLightCircle;
@property (nonatomic, retain) IBOutlet UIImageView* elementLightsFlash;
@property (nonatomic, retain) IBOutlet UIImageView* lights;
@property (nonatomic, retain) IBOutlet UIImageView* glow;
@property (nonatomic, retain) IBOutlet UIImageView* elementGlow;
@property (nonatomic, retain) IBOutlet UIImageView* crystalGlow;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt1;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt2;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt3;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt4;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt5;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt6;
@property (nonatomic, retain) IBOutlet UIImageView* lightningBolt7;
@property (nonatomic, retain) IBOutlet UIImageView* afterGlow;

@property (nonatomic, retain) IBOutlet UIButton* prevButton;
@property (nonatomic, retain) IBOutlet UIButton* nextButton;
@property (nonatomic, retain) IBOutlet UIButton* skipAllButton;
@property (nonatomic, retain) IBOutlet UIButton* closeButton;

- (void) preloadWithMonsterIds:(NSArray*)monsterIds;
- (void) initializeWithMonsterDescriptors:(NSArray*)monsterDescriptors;

- (void) beginAnimation;

- (IBAction) prevButtonClicked:(id)sender;
- (IBAction) nextButtonClicked:(id)sender;
- (IBAction) skipAllClicked:(id)sender;
- (IBAction) closeClicked:(id)sender;

@end

@protocol NewGachaFeaturedViewCallbackDelegate <NSObject>

- (void) skillTapped:(SkillProto*)skill offensive:(BOOL)offensive element:(Element)element position:(CGPoint)pos;

@end

@interface NewGachaFeaturedView : UIView {
  int _curMonsterId;
  Element _curMonsterElement;
  
  CGPoint _leftSkillViewOrigin;
  CGPoint _rightSkillViewOrigin;
}

@property (nonatomic, retain) IBOutlet UIView* imageContainerView;
@property (nonatomic, retain) IBOutlet UIView* statsContainerView;

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rarityIcon;
@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *strengthLabel;
@property (nonatomic, retain) IBOutlet UIImageView *strengthIcon;
@property (nonatomic, retain) IBOutlet UILabel *skillsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *skillsSeparator;

@property (weak, nonatomic) IBOutlet UIView *offensiveSkillView;
@property (weak, nonatomic) IBOutlet UIView *defensiveSkillView;
@property (weak, nonatomic) IBOutlet UIImageView *offensiveSkillBg;
@property (weak, nonatomic) IBOutlet UIImageView *offensiveSkillIcon;
@property (weak, nonatomic) IBOutlet UIImageView *defensiveSkillBg;
@property (weak, nonatomic) IBOutlet UIImageView *defensiveSkillIcon;

@property (strong, nonatomic) SkillProto* offensiveSkill;
@property (strong, nonatomic) SkillProto* defensiveSkill;

@property (weak, nonatomic) id<NewGachaFeaturedViewCallbackDelegate> delegate;

- (IBAction) offensiveSkillTapped:(id)sender;
- (IBAction) defensiveSkillTapped:(id)sender;

- (void) updateForMonsterId:(int)monsterId;

@end

@interface NewGachaItemCell : UIView

@property(nonatomic,copy) void (^completion)(void);

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UIImageView *shadowIcon;
@property (nonatomic, retain) IBOutlet UIImageView *diamondIcon;
@property (nonatomic, retain) IBOutlet UILabel *label;

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet THLabel *iconLabel;
@property (nonatomic, strong) IBOutlet UILabel *itemQuantityLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *itemView;

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item;
- (void) shakeIconNumTimes:(int)numTimes durationPerShake:(float)duration delay:(float)delay completion:(void (^)(void))comp;

@end
