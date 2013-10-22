//
//  ClanCreateViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface ClanCreateViewController : GenViewController <UITextFieldDelegate> {
  BOOL _isRequestType;
  BOOL _isEditMode;
}

@property (nonatomic, assign) IBOutlet UITextField *nameField;
@property (nonatomic, assign) IBOutlet UITextField *tagField;
@property (nonatomic, assign) IBOutlet UITextView *descriptionField;

@property (nonatomic, assign) IBOutlet UIView *nameBgd;
@property (nonatomic, assign) IBOutlet UIView *tagBgd;

@property (nonatomic, assign) IBOutlet UIButton *typeButton;
@property (nonatomic, assign) IBOutlet UILabel *typeLabel;

@property (nonatomic, assign) IBOutlet UIView *saveButtonView;
@property (nonatomic, assign) IBOutlet UIView *createButtonView;
@property (nonatomic, assign) IBOutlet UILabel *costLabel;

@property (nonatomic, retain) IBOutlet FullClanProtoWithClanSize *clan;

- (id) initInEditModeForClan:(FullClanProtoWithClanSize *)clan;

@end
