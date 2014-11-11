//
//  TutorialQuestLogViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialQuestLogViewController.h"
#import "Globals.h"

@implementation TutorialQuestLogViewController

- (id) init
{
  if (self = [super initWithNibName:@"QuestLogViewController" bundle:nil]) {
    
  }
  return self;
}

- (void) arrowOnFirstQuestInList {
  UITableViewCell *cell = [self.questListViewController.questListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [Globals createUIArrowForView:cell atAngle:-M_PI_2];
}

- (void) arrowOnVisit {
  QuestDetailsCell *cell = (QuestDetailsCell *)[self.questDetailsViewController.taskTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [Globals createUIArrowForView:cell.goView atAngle:M_PI];
}

- (void) arrowOnCollect {
//  [Globals createUIArrowForView:self.questDetailsViewController.collectButton atAngle:M_PI];
}

#pragma mark - Overwritten methods

- (void) questListCellClicked:(QuestListCell *)cell {
  [Globals removeUIArrowFromViewRecursively:self.view];
  [super questListCellClicked:cell];
  [self.delegate questClickedInList];
}

- (void) visitClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC jobId:(int)jobId {
  [self close];
  [Globals removeUIArrowFromViewRecursively:self.view];
  [self.delegate questVisitClicked];
}

- (void) donateClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC jobId:(int)jobId {
  
}

- (void) collectClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC {
  [super collectClickedWithDetailsVC:detailsVC];
  [Globals removeUIArrowFromViewRecursively:self.view];
  [self close];
  [self.delegate questCollectClicked];
}

- (void) button2Clicked:(id)sender {
  // Do nothing
}

- (void) close:(id)sender {
  // Do nothing
}

- (void) backClicked:(id)sender {
  // Do nothing
}

@end
