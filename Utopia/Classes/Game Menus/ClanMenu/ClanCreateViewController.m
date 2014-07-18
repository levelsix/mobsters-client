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
#import "GenericPopupController.h"

#define ICON_WIDTH 31.f
#define ICON_HEIGHT 34.f
#define ICON_SPACING 8.f

@implementation ClanIconChooserView

- (void) updateWithInitialIconId:(int)iconId {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *validIcons = [NSMutableArray array];
  for (ClanIconProto *icon in gs.staticClanIcons) {
    if (icon.isAvailable) {
      [validIcons addObject:icon];
    }
  }
  
  int numPerRow = self.iconsScrollView.frame.size.width/(ICON_WIDTH+ICON_SPACING);
  int maxY = 0;
  for (int i = 0; i < validIcons.count; i++) {
    ClanIconProto *icon = validIcons[i];
    
    int ix = i % numPerRow;
    int iy = i / numPerRow;
    float x = self.iconsScrollView.frame.size.width/2+(ix-numPerRow/2.f+0.5)*(ICON_WIDTH+ICON_SPACING)-ICON_WIDTH/2.f;
    float y = iy*ICON_HEIGHT+(iy+1)*ICON_SPACING;
    
    GeneralButton *iv = [[GeneralButton alloc] initWithFrame:CGRectMake(x, y, ICON_WIDTH, ICON_HEIGHT)];
    [iv awakeFromNib];
    [Globals imageNamed:icon.imgName withView:iv greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    iv.tag = icon.clanIconId;
    [iv addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.iconsScrollView addSubview:iv];
    
    maxY = y+ICON_HEIGHT+ICON_SPACING;
  }
  [self setSelectedIconId:iconId];
  self.iconsScrollView.contentSize = CGSizeMake(self.iconsScrollView.frame.size.width, maxY);
}

- (void) setSelectedIconId:(int)selectedId {
  UIView *v = [self.iconsScrollView viewWithTag:selectedId];
  if (v) {
    self.selectedView.center = v.center;
    self.selectedView.hidden = NO;
  } else {
    self.selectedView.hidden = YES;
  }
}

- (void) iconClicked:(UIButton *)sender {
  [self setSelectedIconId:(int)sender.tag];
  [self.delegate iconChosen:(int)sender.tag];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

@end

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
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (_isEditMode) {
    if (self.clan.clan.requestToJoinRequired) {
      self.typeSwitch.on = NO;
      _isRequestType = YES;
    }
    
    self.nameField.text = self.clan.clan.name;
    self.tagField.text = self.clan.clan.tag;
    self.descriptionField.text = self.clan.clan.description;
    [self setIconId:self.clan.clan.clanIconId];
    
    self.nameField.userInteractionEnabled = NO;
    self.tagField.userInteractionEnabled = NO;
    
//    self.nameBgd.hidden = YES;
//    self.tagBgd.hidden = YES;
    
    self.saveButtonView.hidden = NO;
    self.createButtonView.hidden = YES;
    
    self.placeholderLabel.hidden = YES;
    self.maxTagSizeLabel.hidden = YES;
  } else {
    self.saveButtonView.hidden = YES;
    self.createButtonView.hidden = NO;
    self.costLabel.text = [Globals commafyNumber:gl.coinPriceToCreateClan];
    [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
    
    self.maxTagSizeLabel.text = [NSString stringWithFormat:@"Max %d Characters", gl.maxCharLengthForClanTag];
    
    // Set default clan id
    for (ClanIconProto *cip in gs.staticClanIcons) {
      if (cip.isAvailable) {
        [self setIconId:cip.clanIconId];
        break;
      }
    }
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.iconChooserView close:nil];
}

- (void) loadClanCreationView {
  nameField.text = nil;
  tagField.text = nil;
}

- (void) setIconId:(int)iconId {
  GameState *gs = [GameState sharedGameState];
  ClanIconProto *icon = [gs clanIconWithId:iconId];
  
  if (icon) {
    _iconId = iconId;
    [Globals imageNamed:icon.imgName withView:self.iconButton greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
}

#pragma mark - Textview/Textfield delegate

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
  
  if (str.length > gl.maxCharLengthForClanDescription && text.length > 0) {
    return NO;
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
  if (![textView hasText]) {
    self.placeholderLabel.hidden = NO;
  }
}

- (void) textViewDidChange:(UITextView *)textView
{
  if(![textView hasText]) {
    self.placeholderLabel.hidden = NO;
  }
  else{
    self.placeholderLabel.hidden = YES;
  }
}

#pragma mark - IBActions

- (IBAction)bottomButtonClicked:(id)sender {
  if (!_waitingForResponse) {
    if (_isEditMode) {
      [self updateClan];
    } else {
      [self createClan];
    }
  }
}

- (void) updateClan {
  BOOL descriptionChanged = NO, reqTypeChanged = NO, iconIdChanged = NO;
  if (self.descriptionField.text.length > 0 && ![self.descriptionField.text isEqualToString:self.clan.clan.description]) {
    descriptionChanged = YES;
  }
  if (_isRequestType != self.clan.clan.requestToJoinRequired) {
    reqTypeChanged = YES;
  }
  if (_iconId != self.clan.clan.clanIconId) {
    iconIdChanged = YES;
  }
  
  if (descriptionChanged || reqTypeChanged || iconIdChanged) {
    [[OutgoingEventController sharedOutgoingEventController] changeClanSettingsIsDescription:descriptionChanged description:self.descriptionField.text isRequestType:reqTypeChanged requestRequired:_isRequestType isIcon:iconIdChanged iconId:_iconId delegate:self];
    
    self.saveButtonView.hidden = YES;
    self.spinner.hidden = NO;
    _waitingForResponse = YES;
  } else {
    [self goBack];
  }
}

- (void) createClan {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSString *name = nameField.text;
  NSString *tag = tagField.text;
  NSString *description = self.descriptionField.text;
  
  if (name.length <= 0) {
    [Globals addAlertNotification:@"You must enter a clan name."];
  } else if (tag.length <= 0) {
    [Globals addAlertNotification:@"You must enter a clan tag."];
  } else if (description.length <= 0) {
    [Globals addAlertNotification:@"You must enter a description."];
  } else if (name.length > gl.maxCharLengthForClanName) {
    [Globals addAlertNotification:@"The name you entered is too long."];
  } else if (tag.length > gl.maxCharLengthForClanTag) {
    [Globals addAlertNotification:@"The tag you entered is too long."];
  } else {
    if (gs.silver < gl.coinPriceToCreateClan) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeCash amount:gl.coinPriceToCreateClan-gs.silver target:self selector:@selector(allowCreateWithGems)];
    } else {
      [self createClanWithGems:NO];
    }
  }
}

- (void) allowCreateWithGems {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  int cost = gl.coinPriceToCreateClan;
  int curAmount = gs.silver;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cost-curAmount];
  
  if (gs.gold < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self createClanWithGems:YES];
  }
}

- (void) createClanWithGems:(BOOL)useGems {
  NSString *name = nameField.text;
  NSString *tag = tagField.text;
  NSString *description = self.descriptionField.text;
  
  [[OutgoingEventController sharedOutgoingEventController] createClan:name tag:tag description:description requestOnly:_isRequestType iconId:_iconId useGems:useGems delegate:self];
  
  self.createButtonView.hidden = YES;
  self.spinner.hidden = NO;
  _waitingForResponse = YES;
}

- (IBAction)typeButtonClicked:(id)sender {
  _isRequestType = !self.typeSwitch.isOn;
}

- (IBAction)editIconClicked:(id)sender {
  [self.iconChooserView updateWithInitialIconId:_iconId];
  [self.parentViewController.view addSubview:self.iconChooserView];
  self.iconChooserView.frame = self.parentViewController.view.bounds;
  [Globals bounceView:self.iconChooserView.mainView fadeInBgdView:self.iconChooserView.bgdView];
}

- (void) iconChosen:(int)iconId {
  [self setIconId:iconId];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

- (BOOL) canGoBack {
  if (!_isEditMode) {
    return YES;
  } else if ((self.descriptionField.text.length > 0 && ![self.descriptionField.text isEqualToString:self.clan.clan.description]) ||
      _isRequestType != self.clan.clan.requestToJoinRequired ||
      _iconId != self.clan.clan.clanIconId) {
    [GenericPopupController displayConfirmationWithDescription:@"You have some unsaved changes. Would you like to save them?" title:@"Save?" okayButton:@"Save" cancelButton:@"Back" okTarget:self okSelector:@selector(updateClan) cancelTarget:self cancelSelector:@selector(goBack)];
    return NO;
  } else {
    return YES;
  }
}

- (void) goBack {
  [self.parentViewController goBack];
}

- (BOOL) canClose {
  if (!_isEditMode) {
    return YES;
  } else if ((self.descriptionField.text.length > 0 && ![self.descriptionField.text isEqualToString:self.clan.clan.description]) ||
      _isRequestType != self.clan.clan.requestToJoinRequired ||
      _iconId != self.clan.clan.clanIconId) {
    _shouldClose = YES;
    [GenericPopupController displayConfirmationWithDescription:@"You have some unsaved changes. Would you like to save them?" title:@"Save?" okayButton:@"Save" cancelButton:@"Close" okTarget:self okSelector:@selector(updateClan) cancelTarget:self cancelSelector:@selector(close)];
    return NO;
  } else {
    return YES;
  }
}

- (void) close {
  [self.parentViewController close];
}

#pragma mark - Response handlers

- (void) handleCreateClanResponseProto:(FullEvent *)e {
  self.spinner.hidden = YES;
  self.createButtonView.hidden = NO;
  _waitingForResponse = NO;
  
  CreateClanResponseProto *proto = (CreateClanResponseProto *)e.event;
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    [Analytics createSquad:proto.clanInfo.name];
  }
}

- (void) handleChangeClanSettingsResponseProto:(FullEvent *)e {
  if (_shouldClose) {
    [self close];
  } else {
    [self goBack];
  }
  _waitingForResponse = NO;
}

@end