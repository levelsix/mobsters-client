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

- (void) setSprite:(NSString*)spriteName secsBetweenReplay:(float)secsBetweenReplay fps:(float)fps
{
  if (![spriteName isEqualToString:_spriteName])
  {
    _spriteName = spriteName;
    
    if ([spriteName rangeOfString:@".plist"].location == NSNotFound)
    {
      // Set a static image
      [Globals imageNamed:spriteName withView:self greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    }
    else
    {
      if (self.spinner) [self.spinner startAnimating];
      
      // Check for and download assets required for the sprite animation
      [Globals checkAndLoadFile:spriteName useiPhone6Prefix:NO useiPadSuffix:NO completion:^(BOOL success) {
        if (success)
        {
          NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[Globals pathToFile:spriteName useiPhone6Prefix:NO useiPadSuffix:NO]];
          NSDictionary* metadata = [dict objectForKey:@"meta"];
          NSString* texture = [metadata objectForKey:@"image"];
          [Globals checkAndLoadFile:texture useiPhone6Prefix:NO useiPadSuffix:NO completion:^(BOOL success) {
            if (self.spinner) [self.spinner stopAnimating];
            
            if (success)
            {
              [self setImage:nil];
              [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
              
              // Set own size equal to size of the biggest frame of the sprite animation
              NSDictionary* frames = [dict objectForKey:@"frames"];
              CGFloat maxFrameWidth = 0.f, maxFrameHeight = 0.f;
              for (NSString* key in frames)
              {
                NSDictionary* frame = [frames objectForKey:key];
                CGFloat frameWidth  = [[frame objectForKey:@"w"] floatValue]; if (frameWidth  > maxFrameWidth)  maxFrameWidth  = frameWidth;
                CGFloat frameHeight = [[frame objectForKey:@"h"] floatValue]; if (frameHeight > maxFrameHeight) maxFrameHeight = frameHeight;
              }
              if (maxFrameWidth > 0.f && maxFrameHeight > 0.f)
              {
                maxFrameWidth /= 2.f; maxFrameHeight /= 2.f; // Retina adjustment
                self.frame = CGRectMake(self.originX - (maxFrameWidth  - self.width) * .5f,
                                        self.originY - (maxFrameHeight - self.height),
                                        maxFrameWidth,
                                        maxFrameHeight);
              }
              
              // Create sprite animation and add it as a sublayer
              NSDictionary* spriteData = [CAWSpriteReader spritesWithContentOfDictionary:dict];
              UIImage* spritesheet = [Globals imageNamed:texture];
              CAWSpriteLayer* spriteLayer = [CAWSpriteLayer layerWithSpriteData:spriteData andImage:spritesheet];
              spriteLayer.animationLayer.showLastFrame = YES;
              [self.layer addSublayer:spriteLayer];
              spriteLayer.frame = self.layer.bounds;
              
              // Start the sprite animation
              NSString* frameNames = [[spriteName stringByDeletingPathExtension] stringByAppendingString:@"%02d"];
              [self playAnimation:[NSTimer scheduledTimerWithTimeInterval:secsBetweenReplay
                                                                   target:self
                                                                 selector:@selector(playAnimation:)
                                                                 userInfo:@{ @"SpriteLayer" : spriteLayer, @"FrameNames" : frameNames, @"FPS" : @(fps) }
                                                                  repeats:YES]];
            }
          }];
        }
        else
        {
          if (self.spinner) [self.spinner stopAnimating];
        }
      }];
    }
  }
}

- (void) playAnimation:(NSTimer*)timer
{
  NSString* frameNames = [timer.userInfo objectForKey:@"FrameNames"];
  CAWSpriteLayer* spriteLayer = [timer.userInfo objectForKey:@"SpriteLayer"];
  const float fps = [[timer.userInfo objectForKey:@"FPS"] floatValue];
  [spriteLayer playAnimation:frameNames withRate:fps];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(playingAnimation:)])
  {
    [self.delegate playingAnimation:self];
  }
}

@end
