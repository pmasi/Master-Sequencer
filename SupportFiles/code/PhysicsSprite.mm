
#import "PhysicsSprite.h"

// Needed PTM_RATIO
#import "HelloWorldLayer.h"

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( _ignoreAnchorPointForPosition ) {
		x += _anchorPointInPoints.x;
		y += _anchorPointInPoints.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ){
		x += c*-_anchorPointInPoints.x + -s*-_anchorPointInPoints.y;
		y += s*-_anchorPointInPoints.x + c*-_anchorPointInPoints.y;
	}
	
	// Rot, Translate Matrix
	_transform = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );	
	
	return _transform;
}

-(void) dealloc
{
	// 
	[super dealloc];
}

@end
