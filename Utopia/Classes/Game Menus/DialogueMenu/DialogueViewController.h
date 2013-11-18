//
//  DialogueViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogueViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *leftImageView;
@property (nonatomic, retain) IBOutlet UIImageView *rightImageView;

@property (nonatomic, retain) IBOutlet UILabel *speakerLabel;
@property (nonatomic, retain) IBOutlet UILabel *dialogueLabel;

@end
