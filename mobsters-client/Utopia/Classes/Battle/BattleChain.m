
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

- (NSString *) description {
  return [NSString stringWithFormat:@"%@:\n\t\t\t Initiator: %@\n\t\t\t Prereq: %@\n\t\t\t Orbs:%@", [super description], self.powerupInitiatorOrb, self.prerequisiteOrb, self.orbs];
}

@end
