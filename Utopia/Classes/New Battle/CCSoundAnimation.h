//
//  CCSoundAnimation.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/19/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface CCAnimation (SoundAnimation)

- (void) repeatFrames:(NSRange)range;
- (void) addSoundEffect:(NSString *)effectName atIndex:(int)index;

@end

@interface CCSoundAnimate : CCAnimate

@property (nonatomic, retain) NSDictionary *soundDictionary;
@property (nonatomic, retain) NSMutableSet *playedSounds;

@end