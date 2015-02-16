//
//  AttackedAlertViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"

@interface AttackedAlertView : UIView {
  int _oilLost;
  int _cashLost;
  int _rankLost;
}

@property (nonatomic, retain) IBOutlet UILabel *cashLabel;
@property (nonatomic, retain) IBOutlet UILabel *oilLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;

- (void) updateForPvpList:(NSArray *) pvpList;

@end

@interface AttackedAlertViewController : UIViewController

@property (nonatomic, retain) IBOutlet AttackedAlertView *alertView;
@property (weak, nonatomic) IBOutlet UIView *BGView;

@end
