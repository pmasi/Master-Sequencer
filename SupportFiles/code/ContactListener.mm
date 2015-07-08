
#import "ContactListener.h" 
#import "cocos2d.h" 
#import "global.h"
#import "SharedData.h"


ContactListener::ContactListener(){
    appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
}

ContactListener::~ContactListener(){
}
void ContactListener::BeginContact(b2Contact* contact) 
{
}

void ContactListener::EndContact(b2Contact* contact) { 
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    contact->SetEnabled(true);
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();	
    
    CCSprite* spr_a = (CCSprite*)bodyA->GetUserData();
    CCSprite* spr_b = (CCSprite*)bodyB->GetUserData();
    if ((spr_a.tag == TAG_MAIN && spr_b.tag == TAG_ENEMY) || (spr_b.tag == TAG_MAIN && spr_a.tag == TAG_ENEMY)) {
        [SharedData setDetectCollision:YES];
    }
    
    // tap enemy
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}
