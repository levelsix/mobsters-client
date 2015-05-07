//
//  PurchaseHighRollerModeViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"

@protocol PurchaseHighRollerModeCallbackDelegate <NSObject>

- (void) toPackagesTapped;

@end

@interface PurchaseHighRollerModeView : TouchableSubviewsView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *paragraghLabel;
@property (nonatomic, retain) IBOutlet THLabel *packagesLabel;
@property (nonatomic, retain) IBOutlet THLabel *purchaseLabel;
@property (nonatomic, retain) IBOutlet UIView *packagesView;
@property (nonatomic, retain) IBOutlet UIView *purchaseView;

- (void) initFonts;
- (void) updateWithHeadline:(NSString *) headline andMessage:(NSString *) message;

@end

@interface PurchaseHighRollerModeViewController : UIViewController {
  NSString *_headline;
  NSString *_message;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgView;

@property (nonatomic, weak) id<PurchaseHighRollerModeCallbackDelegate> delegate;

- (IBAction) clickedPackages:(id)sender;
- (IBAction) clickedPurchase:(id)sender;
- (IBAction) clickedClose:(id)sender;

- (id) initWithHeadline:(NSString *) headline andMessage:(NSString *) message;

@end
