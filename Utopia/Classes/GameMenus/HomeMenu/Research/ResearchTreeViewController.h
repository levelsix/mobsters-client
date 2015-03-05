//
//  RearchTreeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface ResearchTreeViewController : PopupSubViewController {
  NSArray *_researches;
}

-(id)initWithDomain:(ResearchDomain)domain;
-(void)researchButtonClickWithId:(int) id;

@end

@interface ResearchTreeView : UIView

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

@end

@interface ResearchSelectionView : UIView {
  int _id;
}

- (void)updateForProto:(ResearchProto *)research;

@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;

@property (nonatomic, assign) IBOutlet UIImageView *selectedOutline;
@property (nonatomic, assign) IBOutlet UIImageView *bgView;

@property (nonatomic, assign) ResearchTreeViewController* delegate;

@end
