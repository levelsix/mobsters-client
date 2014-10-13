//
//  EvolveDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "EvolveDetailsViews.h"

#import "UserData.h"

@interface EvolveDetailsViewController : PopupSubViewController {
  BOOL _allowEvolution;
}

@property (nonatomic, retain) IBOutlet EvolveDetailsMiddleView *middleView;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;

@property (nonatomic, retain) IBOutlet UIView *oilButtonView;
@property (nonatomic, retain) IBOutlet UIView *gemButtonView;
@property (nonatomic, retain) IBOutlet UIView *helpButtonView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIView *gemLabelsView;
@property (nonatomic, retain) IBOutlet UIView *oilLabelsView;

@property (nonatomic, retain) UIView *greyscaleView;
@property (nonatomic, retain) IBOutlet UIView *bottomView;

@property (nonatomic, retain) EvoItem *evoItem;

@property (nonatomic, strong) NSTimer *updateTimer;

- (id) initWithEvoItem:(EvoItem *)evoItem allowEvolution:(BOOL)allowEvolution;
- (id) initWithCurrentEvolution;

- (IBAction)speedupClicked:(id)sender;
- (IBAction)helpClicked:(id)sender;

@end
