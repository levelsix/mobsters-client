//
//  CCLabelFX.m
//  LabelsTest
//
//  Created by Jose Andrade on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCLabelFX.h"

#import "CCTexture2D+TextShadow.h"
#import "ccMacros.h"

#define SIGNCHECK(x) (x>0)?x:0

@implementation CCLabelFX

@synthesize fillColor = fillColor_;
@synthesize shadowColor = shadowColor_;

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
          shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur shadowColor:(ccColor4B)sColor fillColor:(ccColor4B)fColor
{
	return [[[self alloc] initWithNSString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size shadowOffset:shadowSize 
                                shadowBlur:shadowBlur shadowColor:sColor fillColor:fColor] autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size shadowOffset:(CGSize)shadowSize 
            shadowBlur:(float)shadowBlur shadowColor:(ccColor4B)sColor fillColor:(ccColor4B)fColor
{
	return [[[self alloc] initWithNSString: string fontName:name fontSize:size shadowOffset:shadowSize shadowBlur:shadowBlur shadowColor:sColor 
                                 fillColor:fColor] autorelease];
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
          shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur
{
	return [[[self alloc] initWithNSString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size shadowOffset:shadowSize shadowBlur:shadowBlur] autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur
{
	return [[[self alloc] initWithNSString: string fontName:name fontSize:size shadowOffset:shadowSize shadowBlur:shadowBlur] autorelease];
}


- (id) initWithNSString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
         shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur shadowColor:(ccColor4B)sColor fillColor:(ccColor4B)fColor
{
	if( (self=[super initWithString:str fontName:name fontSize:size dimensions:dimensions hAlignment:alignment]))
    {
        shadowOffset_ = CGSizeMake(shadowSize.width * CC_CONTENT_SCALE_FACTOR(), shadowSize.height*CC_CONTENT_SCALE_FACTOR());
        shadowBlur_ = SIGNCHECK(shadowBlur* CC_CONTENT_SCALE_FACTOR());
        shadowColor_ = sColor;
        fillColor_ = fColor; 
        
		[self setString:str];
	}
	return self;
}

- (id) initWithNSString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size shadowOffset:(CGSize)shadowSize
           shadowBlur:(float)shadowBlur shadowColor:(ccColor4B)sColor fillColor:(ccColor4B)fColor
{
	if( (self=[super initWithString:str fontName:name fontSize:size]) ) 
    {
        shadowOffset_ = CGSizeMake(shadowSize.width * CC_CONTENT_SCALE_FACTOR(), shadowSize.height*CC_CONTENT_SCALE_FACTOR());
        shadowBlur_ = SIGNCHECK(shadowBlur* CC_CONTENT_SCALE_FACTOR());
        shadowColor_ = sColor;
        fillColor_ = fColor;
        
        [self setString:str];
	}
	return self;
}

- (id) initWithNSString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur
{
    return [self initWithNSString:str dimensions:dimensions alignment:alignment fontName:name fontSize:size 
                     shadowOffset:shadowSize shadowBlur:shadowBlur shadowColor:ccc4(0,0,0,255) fillColor:ccc4(255,255,255,255)];
}

- (id) initWithNSString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size shadowOffset:(CGSize)shadowSize shadowBlur:(float)shadowBlur
{
	
    return [self initWithNSString:str fontName:name fontSize:size shadowOffset:shadowSize shadowBlur:shadowBlur shadowColor:ccc4(0,0,0,255) 
                        fillColor:ccc4(255,255,255,255)];
}

- (void) setString:(NSString*)str
{
	[_string release];
	_string = [str copy];
    
	CCTexture2D *tex;
	if( CGSizeEqualToSize( _dimensions, CGSizeZero ) )
    {
        ccColor4F sColor4F = ccc4FFromccc4B(shadowColor_);
        ccColor4F fColor4F = ccc4FFromccc4B(fillColor_);
        
        float sColor[4] = {sColor4F.r, sColor4F.g, sColor4F.b, sColor4F.a};
        float fColor[4] = {fColor4F.r, fColor4F.g, fColor4F.b, fColor4F.a};
        
        tex = [[CCTexture2D alloc] initWithString:str
                                         fontName:_fontName
                                         fontSize:_fontSize
                                     shadowOffset:_shadowOffset
                                       shadowBlur:_shadowBlur
                                      shadowColor:sColor
                                        fillColor:fColor];
    }
	else
    {
        ccColor4F sColor4F = ccc4FFromccc4B(shadowColor_);
        ccColor4F fColor4F = ccc4FFromccc4B(fillColor_);
        
        float sColor[4] = {sColor4F.r, sColor4F.g, sColor4F.b, sColor4F.a};
        float fColor[4] = {fColor4F.r, fColor4F.g, fColor4F.b, fColor4F.a};
        
        tex = [[CCTexture2D alloc] initWithString:str
                                       dimensions:_dimensions
                                        alignment:_hAlignment
                                         fontName:_fontName
                                         fontSize:_fontSize
                                     shadowOffset:_shadowOffset
                                       shadowBlur:_shadowBlur
                                      shadowColor:sColor
                                        fillColor:fColor];
    }
    
	[self setTexture:tex];
	[tex release];
    
	CGRect rect = CGRectZero;
	rect.size = [_texture contentSize];
	[self setTextureRect: rect];
}

- (void)setShadowColor:(ccColor4B)shadowColor
{
    shadowColor_ = shadowColor;
    [self setString:_string];
}

- (void)setFillColor:(ccColor4B)fillColor
{
    fillColor_ = fillColor;
    [self setString:_string];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | FontName = %@, FontSize = %.1f, ShadowOffset = %@, ShadowBlur = %f>", 
            [self class], self, _fontName, _fontSize, NSStringFromCGSize(_shadowOffset), _shadowBlur];
}

@end
