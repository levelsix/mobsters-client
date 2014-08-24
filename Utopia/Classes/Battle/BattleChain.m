
#import "BattleChain.h"

@implementation BattleChain {
  NSMutableArray *_orbs;
}

- (void)addOrb:(BattleOrb *)orb {
  if (_orbs == nil) {
    _orbs = [NSMutableArray array];
  }
  
  if (orb) {
    [_orbs addObject:orb];
  }
}

- (NSArray *)orbs {
  return _orbs;
}

@end
