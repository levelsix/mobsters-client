//
//  ClanCreateViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "PopupSubViewController.h"

#import "ResourceItemsFiller.h"

@protocol ClanIconChooserDelegate <NSObject>

- (void) iconChosen:(int)iconId;

@end

@interface ClanIconChooserView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIScrollView *iconsScrollView;
@property (nonatomic, retain) IBOutlet UIView *selectedView;

@property (nonatomic, weak) IBOutlet id<ClanIconChooserDelegate> delegate;

- (IBAction) close:(id)sender;

@end

@interface ClanCreateViewController : PopupSubViewController <UITextFieldDelegate, ClanIconChooserDelegate, ResourceItemsFillerDelegate> {
  BOOL _isRequestType;
  BOOL _isEditMode;
  int _iconId;
  
  BOOL _waitingForResponse;
  BOOL _shouldClose;
}

@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextField *tagField;
@property (nonatomic, assign) IBOutlet UITextView *descriptionField;
@property (nonatomic, assign) IBOutlet UILabel *maxTagSizeLabel;
@property (nonatomic, assign) IBOutlet UILabel *placeholderLabel;

@property (nonatomic, assign) IBOutlet UIButton *iconButton;
@property (nonatomic, assign) IBOutlet UIButton* bottomButton;

@property (nonatomic, assign) IBOutlet UIView *nameBgd;
@property (nonatomic, assign) IBOutlet UIView *tagBgd;

@property (nonatomic, assign) IBOutlet UISwitch *typeSwitch;

@property (nonatomic, assign) IBOutlet UIView *saveButtonView;
@property (nonatomic, assign) IBOutlet UIView *createButtonView;
@property (nonatomic, assign) IBOutlet UILabel *costLabel;

@property (nonatomic, retain) IBOutlet ClanIconChooserView *iconChooserView;

@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

- (id) initInEditModeForClan:(FullClanProtoWithClanSize *)clan;

@end
