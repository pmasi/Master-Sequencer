
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SimpleAudioEngine.h"

@interface SharedData : NSObject{
    @public
    SimpleAudioEngine* sae;
    NSString*       cur_sound;

}

@property (nonatomic, assign) BOOL  g_bSound;
@property (nonatomic, assign) BOOL  g_bEffect;

+ (id)getSharedInstance;

+ (void) setHighScore:(float)val;
+ (float) getHighScore;
+ (BOOL) isSetValuesAtFirstLoad;
+ (void) setValuesAtFirstLoad:(BOOL)flag;

+ (BOOL) getDetectCollision;
+ (void) setDetectCollision:(BOOL)flag;

-(id)init;
-(void) playBackground:(NSString*) title;
-(void) playSoundEffect:(NSString*) title;
-(void) stopBackground;
-(void) stopEffect;
-(void) pauseBackgroud;
-(void) resumeBackground;
@end
