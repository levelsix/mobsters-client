//
//  DialogueViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@class DialogueViewController;

@protocol DialogueViewControllerDelegate <NSObject>

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc;

@optional
- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index;
- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index;

@end

@interface DialogueViewController : UIViewController {
  int _curIndex;
  BOOL _isAnimating;
}

@property (nonatomic, retain) IBOutlet UIImageView *leftImageView;
@property (nonatomic, retain) IBOutlet UIImageView *rightImageView;

@property (nonatomic, retain) IBOutlet UILabel *speakerLabel;
@property (nonatomic, retain) IBOutlet UILabel *dialogueLabel;

@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *bottomGradient;

@property (nonatomic, retain) DialogueProto *dialogue;

@property (nonatomic, assign) id<DialogueViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL blackOutSpeakers;

- (id) initWithDialogueProto:(DialogueProto *)dialogue;
- (void) animateNext;
- (void) fadeOutBottomGradient;

@end
