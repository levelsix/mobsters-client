//
//  RearchTreeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@protocol ResearchSelectionBarDelegate <NSObject>

- (void) researchBarClicked:(id)sender;

@end

@interface ResearchSelectionBarView : TouchableSubviewsView

@property (nonatomic, assign) IBOutlet UIImageView *selectionIcon;
@property (nonatomic, assign) IBOutlet UIImageView *nextArrowButton;
@property (nonatomic, assign) IBOutlet THLabel *rankTotal;
@property (nonatomic, assign) IBOutlet THLabel *selectionTitle;
@property (nonatomic, assign) IBOutlet THLabel *selectionDescription;
@property (nonatomic, assign) IBOutlet UIButton *barButton;

@property (nonatomic, weak) id<ResearchSelectionBarDelegate> delegate;

- (void) updateForUserResearch:(UserResearch *)userResearch;
- (void) animateIn:(dispatch_block_t)completion;
- (void) appearInPosition;
- (void) animateOut:(dispatch_block_t)completion;

@end

@protocol ResearchTreeDelegate <NSObject>

- (void) researchButtonClicked:(id)sender;

@end

@interface ResearchButtonView : UIView {
  NSHashTable  *_parentNodes; // Similar to NSSet, but can hold weak references to its members
  NSMutableSet *_connectionsToParentNodes;
  
  BOOL _isAvailable;
}

@property (nonatomic, assign) IBOutlet UIImageView *researchIcon;
@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankCountLabel;
@property (nonatomic, assign) IBOutlet UIImageView *outline;
@property (nonatomic, assign) IBOutlet UIImageView *bgView;
@property (nonatomic, assign) IBOutlet UIImageView *lockedIcon;
@property (nonatomic, assign) IBOutlet UILabel *researchingTimeLeftLabel;
@property (nonatomic, assign) IBOutlet UIImageView *researchingCircle;
@property (nonatomic, weak) id<ResearchTreeDelegate> delegate;

- (IBAction)researchSelected:(id)sender;

- (void)updateForResearch:(UserResearch *)userResearch parentNodes:(NSSet *)parentNodes;
- (void)highlightPathToParentNodes:(BOOL)highlight needsBlackOutline:(BOOL)needsBlackOutline ignoreNodes:(NSMutableArray *)ignoreNodes;
- (void)select;
- (void)deselect;
- (void)dropOpacity;
- (void)fullOpacity;
- (void)updateTimeLeftLabelForResearch:(UserResearch *)userResearch;

@end

@interface ResearchTreeViewController : PopupSubViewController <ResearchTreeDelegate, ResearchSelectionBarDelegate> {
  NSMutableArray *_researchButtons;
  NSMutableArray *_userResearches;
  
  ResearchSelectionBarView *_curBarView;
  ResearchDomain _domain;
  CGSize _contentSize;
  BOOL _selectFieldViewUp;
  BOOL _barAnimating;
  
  ResearchButtonView *_lastClicked;
  UserResearch *_selectedResearch;
  
  UserResearch *_preSelectResearch;
}

@property (nonatomic, assign) IBOutlet UIView *contentView;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) IBOutlet UIButton *bgButton;
@property (nonatomic, assign) IBOutlet ResearchSelectionBarView *selectFieldView;

- (id) initWithDomain:(ResearchDomain)domain;
- (void) selectResearch:(UserResearch *)userResearch;
@end
