//
//  BattleEndView.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/7/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleEndView.h"

@implementation BattleEndView

//- (void) awakeFromNib {
//  CIContext *context = [CIContext contextWithOptions:nil];
//  
//  NSLog(@"%@", NSStringFromCGSize(self.bgdView.image.size));
//  
//  CIImage *bgdImage = [CIImage imageWithCGImage:self.bgdView.image.CGImage];
//  CIImage *inputImage = [CIImage imageWithCGImage:self.spinner.image.CGImage];
//  CIImage *clear = [CIImage emptyImage];
//  clear = [clear imageByCroppingToRect:bgdImage.extent];
//  
//  CGSize s = bgdImage.extent.size;
//  CGRect r = CGRectMake(inputImage.extent.size.width/2-s.width/2, inputImage.extent.size.height/2-s.height/2, s.width, s.height);
//  inputImage = [inputImage imageByCroppingToRect:r];
//  inputImage = [inputImage imageByApplyingTransform:CGAffineTransformMakeTranslation(-r.origin.x, -r.origin.y)];
//  NSLog(@"%@", NSStringFromCGRect(inputImage.extent));
//  
//  CIFilter* filterm = [CIFilter filterWithName:@"CIBlendWithAlphaMask"];
//  [filterm setValue:inputImage forKey:@"inputImage"];
//  [filterm setValue:bgdImage forKey:@"inputBackgroundImage"];
//  [filterm setValue:inputImage forKey:@"inputMaskImage"];
//  CIImage *result = [filterm valueForKey:@"outputImage"];
//  
////  self.spinner.image = [UIImage imageWithCIImage:outputImage];
//  CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
//  self.bgdView.image = [UIImage imageWithCGImage:cgImage];
//  NSLog(@"%@", NSStringFromCGSize(self.bgdView.image.size));
//  self.spinner.hidden = YES;
//}

- (void)drawRect:(CGRect)rect
{
  [self.bgdView addSubview:self.spinner];
  
  UIGraphicsBeginImageContext(self.frame.size);
  
  CGContextRef c = UIGraphicsGetCurrentContext();
  
  CGContextSetBlendMode(c, kCGBlendModeColorBurn);
  [self.bgdView.layer renderInContext:c];
  
  UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [blendedImage drawAtPoint:CGPointMake(240, 160)];
  
  self.bgdView.hidden = YES;
}

@end
