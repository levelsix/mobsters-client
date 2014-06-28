//
//  PopupSubViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "EnhanceQueueViewController.h"
#import "Globals.h"

@implementation PopupSubViewController

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self respondsToSelector:@selector(updateLabels)]) {
    self.updateTimer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    [self performSelector:@selector(updateLabels)];
  }
  
  if ([self respondsToSelector:@selector(waitTimeComplete)]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:EVOLUTION_WAIT_COMPLETE_NOTIFICATION object:nil];
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) canGoBack {
  return YES;
}

- (BOOL) canClose {
  return YES;
}

@end
