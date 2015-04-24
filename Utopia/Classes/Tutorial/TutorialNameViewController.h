//
//  TutorialNameViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TutorialNameDelegate <NSObject>

- (void) nameChosen:(NSString *)name;

@end

@interface TutorialNameViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSString *initialName;

@property (nonatomic, weak) id<TutorialNameDelegate> delegate;

- (id) initWithName:(NSString *)name;
- (IBAction)closeClicked:(id)sender;

@end
