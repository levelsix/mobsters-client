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

@class DialogueViewController;

@protocol DialogueViewControllerDelegate <NSObject>

@optional
- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc;
- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index;
- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index;
- (void) dialogueViewControllerButtonClicked:(DialogueViewController *)dvc;

@end

@interface DialogueViewController : UIViewController {
  int _curIndex;
  BOOL _isAnimating;
  BOOL _useSmallBubble;
  NSString *_buttonText;
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

@property (nonatomic, retain) DialogueProto *dialogue;

@property (nonatomic, assign) id<DialogueViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL blackOutSpeakers;
@property (nonatomic, assign) BOOL paused;

- (id) initWithDialogueProto:(DialogueProto *)dialogue;
- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble;
- (id) initWithDialogueProto:(DialogueProto *)dialogue useSmallBubble:(BOOL)smallBubble buttonText:(NSString *)buttonText;
- (void) extendDialogue:(DialogueProto *)dialogue;
- (void) animateNext;
- (void) fadeOutBottomGradient;

- (void) showFbButtonView;
- (void) beginFbSpinning;
- (void) endFbSpinning;

- (void) pauseAndHideSpeakers;
- (void) continueAndRevealSpeakers;

@end
