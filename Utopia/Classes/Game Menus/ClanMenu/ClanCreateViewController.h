//
//  ClanCreateViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "ClanSubViewController.h"

@protocol ClanIconChooserDelegate <NSObject>

- (void) iconChosen:(int)iconId;

@end

@interface ClanIconChooserView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIScrollView *iconsScrollView;
@property (nonatomic, retain) IBOutlet UIView *selectedView;

@property (nonatomic, assign) IBOutlet id<ClanIconChooserDelegate> delegate;

- (IBAction) close:(id)sender;

@end

@interface ClanCreateViewController : ClanSubViewController <UITextFieldDelegate, ClanIconChooserDelegate> {
  BOOL _isRequestType;
  BOOL _isEditMode;
  int _iconId;
  
  BOOL _waitingForResponse;
  BOOL _shouldClose;
}

@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextField *tagField;
@property (nonatomic, assign) IBOutlet UITextView *descriptionField;

@property (nonatomic, assign) IBOutlet UIImageView *iconImage;

@property (nonatomic, assign) IBOutlet UIView *nameBgd;
@property (nonatomic, assign) IBOutlet UIView *tagBgd;

@property (nonatomic, assign) IBOutlet UIButton *typeButton;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;

@property (nonatomic, assign) IBOutlet UIView *saveButtonView;
@property (nonatomic, assign) IBOutlet UIView *createButtonView;
@property (nonatomic, assign) IBOutlet UILabel *costLabel;

@property (nonatomic, retain) IBOutlet ClanIconChooserView *iconChooserView;

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;

- (id) initInEditModeForClan:(FullClanProtoWithClanSize *)clan;

@end
