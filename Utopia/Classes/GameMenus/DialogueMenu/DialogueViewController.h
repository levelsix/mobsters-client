//
//  DialogueViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

#import "NibUtils.h"

@protocol DialogueViewDelegate <NSObject>

- (void) dialogueViewPointInsideChecked;

@end

@interface DialogueView : UIView

@property (nonatomic, assign) IBOutlet id<DialogueViewDelegate> delegate;
@property (nonatomic, assign) BOOL allowClickThrough;

@end

@class DialogueViewController;

@protocol DialogueViewControllerDelegate <NSObject>

@optional
- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc;
- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index;
- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index;
- (void) dialogueViewControllerButtonClicked:(DialogueViewController *)dvc;

@end

@interface DialogueViewController : UIViewController <DialogueViewDelegate> {
  int _curIndex;
  BOOL _isAnimating;
  BOOL _useSmallBubble;
  NSString *_buttonText;
  
  BattleItemProto *_battleItem;
  NSString *_battleItemInstruction;
}

@property (nonatomic, retain) IBOutlet UIImageView *leftImageView;
@property (nonatomic, retain) IBOutlet UIImageView *speechBubbleImage;
@property (nonatomic, retain) IBOutlet UIImageView *speechBubbleLine;

@property (nonatomic, retain) IBOutlet UILabel *speakerLabel;
@property (nonatomic, retain) IBOutlet UILabel *dialogueLabel;

@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIView *bottomGradient;

@property (nonatomic, retain) IBOutlet UIView *buttonView;
@property (nonatomic, retain) IBOutlet THLabel *buttonLabel;

@property (nonatomic, retain) IBOutlet UIView *fbButtonView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *fbButtonSpinner;
@property (nonatomic, retain) IBOutlet UILabel *fbButtonLabel;

@property (nonatomic, retain) IBOutlet UIView *itemSpeechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *itemSpeechBubbleImage;
@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *itemNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *itemInstructionLabel;

@property (nonatomic, retain) DialogueProto *dialogue;

@property (nonatomic, assign) id<DialogueViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL blackOutSpeakers;
@property (nonatomic, assign) BOOL paused;

- (id) initWithDialogueProto:(DialogueProto *)dialogue;
- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble;
- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble buttonText:(NSString *)buttonText;
- (id) initWithBattleItemName:(BattleItemProto *)bip instruction:(NSString *)str;
- (void) extendDialogue:(DialogueProto *)dialogue;
- (void) animateNext;
- (void) fadeOutBottomGradient;

- (void) showFbButtonView;
- (void) beginFbSpinning;
- (void) endFbSpinning;

- (void) pauseAndHideSpeakers;
- (void) continueAndRevealSpeakers;

- (void) allowClickThrough;
- (void) disallowClickThrough;

@end
