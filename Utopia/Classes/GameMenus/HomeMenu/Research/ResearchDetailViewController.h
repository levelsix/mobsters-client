//
//  ResearchDetailViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

@interface ResearchDetailViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIView *bgView;
@property (nonatomic, assign) IBOutlet UIImageView *checkMark;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UILabel *improvementLabel;

-(void)updateWithRank:(NSString *)rank description:(NSString *)description;

@end

@interface ResearchDetailView : UIView
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *researchName;
@property (nonatomic, assign) IBOutlet NiceFontLabel8 *researchTimeLabel;

-(void) updateWith:(ResearchProto *)research;

@end

@interface ResearchDetailViewController : PopupSubViewController {
  int _researchId;
}

- (id) initWithResearchId:(int)researchId;

@property (nonatomic, assign) IBOutlet ResearchDetailView *view;

@end
