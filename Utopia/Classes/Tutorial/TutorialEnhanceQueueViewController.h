//
//  TutorialEnhanceQueueViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "EnhanceQueueViewController.h"

@protocol TutorialEnhanceQueueDelegate <NSObject>

- (void) queueOpened;
- (void) choseFeeder;
- (void) beganEnhance;
- (void) finishedEnhance;

- (void) queueClosed;

@end

@interface TutorialEnhanceQueueViewController : EnhanceQueueViewController {
  BOOL _arrowOverMonsterCreated;
  BOOL _allowClose;
  BOOL _allowEnhance;
  BOOL _allowFinish;
}

@property (nonatomic, weak) id<TutorialEnhanceQueueDelegate> delegate;

@property (nonatomic, retain) NSString *clickableUserMonsterUuid;

- (void) allowChoose:(NSString *)userMonsterUuid;
- (void) allowEnhance;
- (void) allowFinish;
- (void) allowClose;

@end
