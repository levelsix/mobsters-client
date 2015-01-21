//
//  BattleHudView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BattleScheduleView.h"
#import "NibUtils.h"

@interface BattleElementView : UIView

- (void) open;
- (void) close;

@end

@interface BattleDeployCardView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet ProgressBar *healthbar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@end

@interface BattleDeployView : UIView

@property (nonatomic, retain) IBOutletCollection(BattleDeployCardView) NSArray *cardViews;

- (void) updateWithBattlePlayers:(NSArray *)players;

@end

@protocol BattleSkillCounterPopupCallbackDelegate <NSObject>

- (void) skillPopupDisplayed;

@end

@class BattleHudView;

@interface BattleSkillCounterPopupView : UIView

@property (nonatomic, assign) IBOutlet id<BattleSkillCounterPopupCallbackDelegate> parentView;

@property (nonatomic, retain) IBOutlet UIImageView* background;
@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* descLabel;
@property (nonatomic, retain) IBOutlet UIImageView* orbIcon;
@property (nonatomic, retain) IBOutlet UILabel* orbCounterLabel;
@property (nonatomic, retain) IBOutlet UILabel* orbDescriptionLabel;

- (void) displayWithSkillName:(NSString*)name description:(NSString*)desc counterLabel:(NSString*)counter orbDescription:(NSString*)orbDesc
              backgroundImage:(NSString*)bgImage orbImage:(NSString*)orbImage atPosition:(CGPoint)pos;
- (void) hide;

@end

@interface BattleHudView : TouchableSubviewsView <BattleSkillCounterPopupCallbackDelegate>

@property (nonatomic, retain) IBOutlet UIView *swapView;
@property (nonatomic, retain) IBOutlet UILabel *swapLabel;
@property (nonatomic, retain) IBOutlet BattleDeployView *deployView;
@property (nonatomic, retain) IBOutlet UIView *forfeitButtonView;
@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) UIButton *deployCancelButton;
@property (nonatomic, retain) IBOutlet THLabel *waveNumLabel;

@property (nonatomic, retain) IBOutlet UIButton *elementButton;
@property (nonatomic, retain) IBOutlet BattleElementView *elementView;
@property (nonatomic, retain) IBOutlet BattleScheduleView *battleScheduleView;
@property (nonatomic, retain) IBOutlet BattleSkillCounterPopupView* skillPopupView;
@property (nonatomic, retain) IBOutlet UIButton* skillPopupCloseButton;

@property (nonatomic, assign) CGPoint schedulePosition;

- (void) displaySwapButton;
- (void) removeSwapButtonAnimated:(BOOL)animated;
- (void) displayDeployViewToCenterX:(float)centerX cancelTarget:(id)target selector:(SEL)selector;
- (void) removeDeployView;
- (void) displayBattleScheduleView;
- (void) removeBattleScheduleView;

- (void) removeButtons;
- (void) prepareForMyTurn;

- (IBAction) hideSkillPopup:(id)sender;

@end
