//
//  DialogueViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "DialogueViewController.h"

@interface DialogueViewController ()

@end

@implementation DialogueViewController

- (void) viewDidLoad {
  CIImage *imageToBlur = [CIImage imageWithCGImage:self.rightImageView.image.CGImage];
  CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
  [blurFilter setDefaults];
  [blurFilter setValue:@(4.f) forKey: @"inputRadius"];
  [blurFilter setValue:imageToBlur forKey: @"inputImage"];
  CIImage *resultImage = [blurFilter outputImage];
  
  self.rightImageView.image = [[UIImage alloc] initWithCIImage:resultImage];
  self.rightImageView.hidden = YES;
}

@end
