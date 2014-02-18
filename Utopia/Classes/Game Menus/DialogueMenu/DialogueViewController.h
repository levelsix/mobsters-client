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

@protocol DialogueViewControllerDelegate

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc;

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

- (id) initWithDialogueProto:(DialogueProto *)dialogue;

@end
