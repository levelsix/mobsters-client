//
//  WBSoundController.h
//  DiceWithBuddies
//
//  Created by Max Goedjen on 10/22/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

@interface WBSoundController : NSObject
@property (nonatomic, assign) BOOL soundOn;

+ (WBSoundController *)sharedController;
-(void)playSoundNamed:(NSString *)name;

@end
