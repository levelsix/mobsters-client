//
// PPEmitterView.h
// Created by Particle Playground on 10/21/14
//

#import "PPEmitterView.h"

@implementation PPEmitterView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

+ (Class) layerClass {
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void)awakeFromNib {
    CAEmitterLayer *emitterLayer = (CAEmitterLayer*)self.layer;

	emitterLayer.name = @"emitterLayer";
	emitterLayer.emitterPosition = CGPointMake(240, 160);
	emitterLayer.emitterZPosition = 0;

	emitterLayer.emitterSize = CGSizeMake(1.00, 1.00);
	emitterLayer.emitterDepth = 0.00;

	emitterLayer.renderMode = kCAEmitterLayerAdditive;

	emitterLayer.seed = 3862096355;



	
	// Create the emitter Cell
	CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
	
	emitterCell.name = @"untitled";
	emitterCell.enabled = YES;

	emitterCell.contents = (id)[[UIImage imageNamed:@"mysprite.png"] CGImage];
	emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);

	emitterCell.magnificationFilter = kCAFilterLinear;
	emitterCell.minificationFilter = kCAFilterLinear;
	emitterCell.minificationFilterBias = 0.00;

	emitterCell.scale = 0.75;
	emitterCell.scaleRange = 0.00;
	emitterCell.scaleSpeed = 0.10;

	emitterCell.color = [[UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.00] CGColor];
	emitterCell.redRange = 1.00;
	emitterCell.greenRange = 1.00;
	emitterCell.blueRange = 1.00;
	emitterCell.alphaRange = 0.00;

	emitterCell.redSpeed = 0.00;
	emitterCell.greenSpeed = 0.16;
	emitterCell.blueSpeed = 3.41;
	emitterCell.alphaSpeed = -0.84;

	emitterCell.lifetime = 1.00;
	emitterCell.lifetimeRange = 0.50;
	emitterCell.birthRate = 75;
	emitterCell.velocity = 150.00;
	emitterCell.velocityRange = 25.00;
	emitterCell.xAcceleration = 0.00;
	emitterCell.yAcceleration = 0.00;
	emitterCell.zAcceleration = 0.00;

	// these values are in radians, in the UI they are in degrees
	emitterCell.spin = 0.000;
	emitterCell.spinRange = 12.566;
	emitterCell.emissionLatitude = 0.000;
	emitterCell.emissionLongitude = 0.000;
	emitterCell.emissionRange = 6.283;


	
	emitterLayer.emitterCells = @[emitterCell];
}

@end
