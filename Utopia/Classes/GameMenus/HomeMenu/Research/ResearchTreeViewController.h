//
//  RearchTreeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@protocol TreeDelegate <NSObject>
-(void)researchButtonClickWithResearch:(UserResearch *)userResearch sender:(id)sender;
@end

@interface researchSelectionBarView : TouchableSubviewsView {
  UserResearch *_userResearch;
}

@property (nonatomic, assign) IBOutlet UIImageView *selectionIcon;
@property (nonatomic, assign) IBOutlet UIImageView *nextArrowButton;
@property (nonatomic, assign) IBOutlet NiceFontLabel12B *rankTotal;
@property (nonatomic, assign) IBOutlet NiceFontLabel12T *selectionTitle;
@property (nonatomic, assign) IBOutlet UILabel *selectionDescription;
@property (nonatomic, assign) IBOutlet UIButton *barButton;

@property (nonatomic, assign) id delegate;

-(void)updateForProto:(UserResearch *)userResearch;
-(void)updateSelf;
-(void) animateIn:(dispatch_block_t)completion;
-(void) animateOut:(dispatch_block_t)completion;

@end

@interface ResearchButtonView : UIView {
  UserResearch *_userResearch;
  
  NSHashTable* _parentNodes; // Similar to NSSet, but can hold weak references to its members
}

@property (nonatomic, assign) IBOutlet UIImageView *researchIcon;
@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankCountLabel;
@property (nonatomic, assign) IBOutlet UIImageView *outline;
@property (nonatomic, assign) IBOutlet UIImageView *bgView;
@property (nonatomic, assign) IBOutlet UIImageView *lockedIcon;
@property (nonatomic, assign) id<TreeDelegate> delegate;

- (IBAction)researchSelected:(id)sender;
- (IBAction)touchDownOnButton:(id)sender;
- (IBAction)touchUpOnButton:(id)sender;

- (void)updateSelf;
- (void)updateForResearch:(UserResearch *)userResearch parentNodes:(NSSet *)parentNodes;
- (void)select;
- (void)deselect;

@end

@interface ResearchTreeViewController : PopupSubViewController <TreeDelegate>{
  ResearchButtonView *_lastClicked;
  NSMutableArray *_researchButtons;
  researchSelectionBarView *_curBarView;
  ResearchDomain _domain;
  BOOL _selectFieldViewUp;
  BOOL _barAnimating;
}

@property (weak, nonatomic) IBOutlet researchSelectionBarView *selectFieldView;

-(id)initWithDomain:(ResearchDomain)domain;
-(void)researchButtonClickWithResearch:(UserResearch *)userResearch sender:(id)sender;
-(void)barClickedWithResearch:(UserResearch *)research;
@end

@interface ResearchTreeView : UIView
@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@end
