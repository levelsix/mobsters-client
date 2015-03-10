//
//  RearchTreeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface researchSelectionBarView : TouchableSubviewsView {
  int _researchId;
}

@property (nonatomic, assign) IBOutlet UIImageView *selectionIcon;
@property (nonatomic, assign) IBOutlet UIImageView *nextArrowButton;
@property (nonatomic, assign) IBOutlet NiceFontLabel12B *rankTotal;
@property (nonatomic, assign) IBOutlet NiceFontLabel12T *selectionTitle;
@property (nonatomic, assign) IBOutlet UILabel *selectionDescription;
@property (nonatomic, assign) IBOutlet UIButton *barButton;

@property (nonatomic, assign) id delegate;

-(void)updateForProto:(ResearchProto *)proto;
-(void) animateIn:(dispatch_block_t)completion;
-(void) animateOut:(dispatch_block_t)completion;

@end

@interface ResearchTreeViewController : PopupSubViewController {
  NSArray *_researches;
  researchSelectionBarView *_curBarView;
  BOOL _selectFieldViewUp;
  BOOL _barAnimating;
}

@property (weak, nonatomic) IBOutlet researchSelectionBarView *selectFieldView;

-(id)initWithDomain:(ResearchDomain)domain;
-(void)researchButtonClickWithId:(int) index;
-(void)barClickedWithId:(int)index;
@end

@interface ResearchTreeView : UIView
@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@end

@interface ResearchButtonView : UIView {
  int _id;
}
@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UIImageView *selectedOutline;
@property (nonatomic, assign) IBOutlet UIImageView *bgView;
@property (nonatomic, assign) ResearchTreeViewController* delegate;

- (void)updateForProto:(ResearchProto *)research;

@end
