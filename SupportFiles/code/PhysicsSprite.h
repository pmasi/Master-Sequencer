
#import "cocos2d.h"
#import "Box2D.h"

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}
-(void) setPhysicsBody:(b2Body*)body;
@end