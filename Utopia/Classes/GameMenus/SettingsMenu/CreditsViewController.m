//
//  CreditsViewController.m
//  Utopia
//
//  Created by Rob Giusti on 5/16/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "CreditsViewController.h"
#import "Globals.h"

@implementation CreditsViewController

- (void)loadFAQ {
  Globals *gl = [Globals sharedGlobals];
  [self loadFile:gl.creditsFileName ? gl.creditsFileName : @"Credits.1.txt"];
}

@end