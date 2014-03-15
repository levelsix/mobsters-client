//
//  main.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Carrot/Carrot.h>

int main(int argc, char *argv[]) {
  int retVal = -1;
  @try {
    signal(SIGPIPE, SIG_IGN); 
//    [Carrot plantInApplication:[AppDelegate class] withSecret:@"e245245bcaa1df6fd12d313abf118434"];
    retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
  @catch (NSException* exception) {
    NSLog(@"Uncaught exception: %@", exception.description);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);
  }
  NSLog(@"Return Val: %d", retVal);
  return retVal;
}
