//
//  TutorialEnhanceViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "EnhanceChooserViewController.h"

@protocol TutorialEnhanceChooserDelegate <NSObject>

- (void) chooserOpened;
- (void) choseMonster;

@end

@interface TutorialEnhanceChooserViewController : EnhanceChooserViewController {
  BOOL _arrowOverMonsterCreated;
}

@property (nonatomic, assign) id<TutorialEnhanceChooserDelegate> delegate;

@property (nonatomic, retain) NSString *clickableUserMonsterUuid;

- (void) allowChoose:(NSString *)userMonsterUuid;

@end
