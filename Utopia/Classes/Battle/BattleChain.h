
@class BattleOrb;

typedef NS_ENUM(NSUInteger, ChainType) {
  ChainTypeMatch,
  ChainTypePowerupNormal,
  ChainTypeRainbowLine,
  ChainTypeRainbowExplosion,
  ChainTypeDoubleRainbow,
  
  // For clouds
  ChainTypeAdjacent
};

@interface BattleChain : NSObject

// This orb is used to tell where the powerup is located + what type of powerup
@property (nonatomic, retain) BattleOrb *powerupInitiatorOrb;

// This orb is used to tell which orb must be destroyed before this chain can be started. (only uses position so faking is okay)
@property (nonatomic, retain) BattleOrb *prerequisiteOrb;

@property (nonatomic, assign) ChainType chainType;

// The BattleOrbs that are part of this chain.
// These orbs cannot be faked!
@property (strong, nonatomic, readonly) NSArray *orbs;

- (void)addOrb:(BattleOrb *)orb;

@end
