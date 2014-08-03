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

@interface AttackMapStatusView : TouchableSubviewsView

@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;
@property (nonatomic, retain) IBOutlet UILabel *sideLabel;

@property (nonatomic, retain) IBOutlet UIView *enterButtonView;
@property (nonatomic, retain) IBOutlet UIView *greyscaleView;

@property (nonatomic, assign) int taskId;

- (void) updateForTaskId:(int)taskId element:(Element)elem level:(int)level isLocked:(BOOL)isLocked isCompleted:(BOOL)isCompleted;

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
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) IBOutlet UIView *enterView;
@property (nonatomic, retain) IBOutlet UIView *cooldownView;

@property (nonatomic, assign) IBOutlet id<AttackEventViewDelegate> delegate;

@property (nonatomic, assign) int persistentEventId;

- (void) updateForEvo;
- (void) updateForEnhance;
- (void) updateLabels;

@end

@interface MultiplayerView : UIView

@property (nonatomic, strong) IBOutlet UILabel *multiplayerUnlockLabel;
@property (nonatomic, strong) IBOutlet UILabel *cashCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *backButton;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *findMatchView;
@property (nonatomic, strong) IBOutlet UIView *rankView;

@property (nonatomic, strong) IBOutlet LeagueView *leagueView;

//@property (nonatomic, strong) IBOutletCollection(LeagueDescriptionView) NSArray *leagueDescriptionViews;

- (void) updateForLeague;
- (IBAction) leagueSelected:(id)sender;
- (IBAction) backClicked:(id)sender;

@end