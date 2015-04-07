//
//  SpriteAnimationImageView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SpriteAnimationImageView.h"
#import "CAWSpriteReader.h"
#import "CAWSpriteLayer.h"
#import "Globals.h"

@implementation SpriteAnimationImageView

- (void) setSprite:(NSString*)spriteName
{
  if (![spriteName isEqualToString:_spriteName])
  {
    _spriteName = spriteName;
    
    if ([spriteName rangeOfString:@".plist"].location == NSNotFound)
    {
      [Globals imageNamed:spriteName withView:self greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    }
    else
    {
      [Globals checkAndLoadFile:spriteName useiPhone6Prefix:NO completion:^(BOOL success) {
        if (success)
        {
          NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[Globals pathToFile:spriteName useiPhone6Prefix:NO]];
          NSDictionary *metadata = [dict objectForKey:@"meta"];
          NSString *texture = [metadata objectForKey:@"image"];
          [Globals checkAndLoadFile:texture useiPhone6Prefix:NO completion:^(BOOL success) {
            if (success)
            {
              [self setImage:nil];
              [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
              
              NSDictionary* spriteData = [CAWSpriteReader spritesWithContentOfDictionary:dict];
              UIImage* spritesheet = [Globals imageNamed:texture];
              CAWSpriteLayer* spriteLayer = [CAWSpriteLayer layerWithSpriteData:spriteData andImage:spritesheet];
              spriteLayer.animationLayer.showLastFrame = YES;
              [self.layer addSublayer:spriteLayer];
              
              NSString* frameNames = [[spriteName stringByDeletingPathExtension] stringByAppendingString:@"%02d"];
              [self playAnimation:[NSTimer scheduledTimerWithTimeInterval:12.f
                                                                   target:self
                                                                 selector:@selector(playAnimation:)
                                                                 userInfo:@{ @"SpriteLayer" : spriteLayer, @"FrameNames" : frameNames }
                                                                  repeats:YES]];
            }
          }];
        }
      }];
    }
  }
}

- (void) playAnimation:(NSTimer*)timer
{
  NSString* frameNames = [timer.userInfo objectForKey:@"FrameNames"];
  CAWSpriteLayer* spriteLayer = [timer.userInfo objectForKey:@"SpriteLayer"];
  [spriteLayer playAnimation:frameNames withRate:15];
}

@end
