//
//  ClanCreateViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ClanCreateViewController.h"
#import "GameState.h"
#import "OutgoingEventController.h"

@implementation ClanCreateViewController

@synthesize nameField, tagField;

- (id) initInEditModeForClan:(FullClanProtoWithClanSize *)clan {
  if ((self = [super init])) {
    _isEditMode = YES;
    self.title = @"EDIT CLAN";
    self.clan = clan;
  }
  return self;
}

- (void) viewDidLoad {
  Globals *gl = [Globals sharedGlobals];
  
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  if (_isEditMode) {
    if (self.clan.clan.requestToJoinRequired) {
      [self typeButtonClicked:nil];
    }
    
    self.nameField.text = self.clan.clan.name;
    self.tagField.text = self.clan.clan.tag;
    self.descriptionField.text = self.clan.clan.description;
    
    self.nameField.userInteractionEnabled = NO;
    self.tagField.userInteractionEnabled = NO;
    
    self.nameBgd.hidden = YES;
    self.tagBgd.hidden = YES;
    
    self.saveButtonView.hidden = NO;
    self.createButtonView.hidden = YES;
  } else {
    self.saveButtonView.hidden = YES;
    self.createButtonView.hidden = NO;
    self.costLabel.text = [Globals cashStringForNumber:gl.cashPriceToCreateClan];
  }
}

- (void) loadClanCreationView {
  nameField.text = nil;
  tagField.text = nil;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  Globals *gl = [Globals sharedGlobals];
  int maxLen = textField == nameField ? gl.maxCharLengthForClanName : gl.maxCharLengthForClanTag;
  
  if (str.length > maxLen) {
    return NO;
  }
  return YES;
}

- (BOOL) textView:(UITextView *)t shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [t.text stringByReplacingCharactersInRange:range withString:text];
  
  if (str.length > gl.maxCharLengthForClanDescription) {
    return NO;
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (IBAction)bottomButtonClicked:(id)sender {
  if (_isEditMode) {
    [self updateClan];
  } else {
    [self createClan];
  }
}

- (void) updateClan {
  BOOL somethingChanged = NO;
  if (self.descriptionField.text.length > 0 && ![self.descriptionField.text isEqualToString:self.clan.clan.description]) {
    [[OutgoingEventController sharedOutgoingEventController] changeClanDescription:self.descriptionField.text delegate:self];
    somethingChanged = YES;
  }
  if (_isRequestType != self.clan.clan.requestToJoinRequired) {
    [[OutgoingEventController sharedOutgoingEventController] changeClanJoinType:_isRequestType delegate:self];
    somethingChanged = YES;
  }
  
  if (somethingChanged) {
    self.saveButtonView.hidden = YES;
    self.spinner.hidden = NO;
  } else {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void) createClan {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSString *name = nameField.text;
  NSString *tag = tagField.text;
  NSString *description = self.descriptionField.text;
  
  if (name.length <= 0) {
    [Globals popupMessage:@"You must enter a clan name."];
  } else if (tag.length <= 0) {
    [Globals popupMessage:@"You must enter a clan tag."];
  } else if (description.length <= 0) {
    [Globals popupMessage:@"You must enter a description."];
  } else if (name.length > gl.maxCharLengthForClanName || tag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Name or tag is too long."];
  } else if (gs.cash < gl.cashPriceToCreateClan) {
//    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.diamondPriceToCreateClan];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] createClan:name tag:tag description:description requestOnly:_isRequestType delegate:self.parentViewController];
    
    self.createButtonView.hidden = YES;
    self.spinner.hidden = NO;
  }
}

- (IBAction)typeButtonClicked:(id)sender {
  if (_isRequestType) {
    [self.typeButton setImage:[Globals imageNamed:@"enhancebutton.png"] forState:UIControlStateNormal];
    self.typeLabel.text = @"OPEN";
  } else {
    [self.typeButton setImage:[Globals imageNamed:@"heal.png"] forState:UIControlStateNormal];
    self.typeLabel.text = @"REQUEST";
  }
  
  _isRequestType = !_isRequestType;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

#pragma mark - Response handlers

- (void) handleChangeClanDescriptionResponseProto:(FullEvent *)e {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) handleChangeClanJoinTypeResponseProto:(FullEvent *)e {
  [self.navigationController popViewControllerAnimated:YES];
}

@end