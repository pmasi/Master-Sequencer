
#import "Box2D.h" 
#import "AppDelegate.h"

@class AppController;

class ContactListener : public b2ContactListener 
{ 
public:
    AppController*    appDelegate;
    
    ContactListener();
	~ContactListener();

    void BeginContact(b2Contact* contact); 
    void EndContact(b2Contact* contact); 
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
}; 


