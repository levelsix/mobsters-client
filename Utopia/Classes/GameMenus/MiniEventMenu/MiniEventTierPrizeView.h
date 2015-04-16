//
//  MiniEventTierPrizeView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"

@interface MiniEventTierPrizeView : EmbeddedNibView <UITableViewDataSource>
{
  NSMutableArray* _prizeList;
}

@property (nonatomic, retain) IBOutlet UIImageView* tierBackground;
@property (nonatomic, retain) IBOutlet THLabel*     tierTitle;
@property (nonatomic, retain) IBOutlet UIImageView* tierCheckbox;
@property (nonatomic, retain) IBOutlet UIImageView* tierCheckmark;
@property (nonatomic, retain) IBOutlet UITableView* tierPrizeList;

- (void) updateForTier:(int)tier prizeList:(NSArray*)prizeList;

@end
