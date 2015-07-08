
#import "SharedData.h"
#import "global.h"

static SharedData * instance = nil;
@implementation SharedData

@synthesize g_bSound;
@synthesize g_bEffect;


+(id)getSharedInstance
{
    if(instance == nil)
    {
        instance = [[SharedData alloc] init];
    }
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self initVar];
    }
    return self;
}

-(void) initVar{
    g_bSound = YES;
    g_bEffect = YES;
    sae = [SimpleAudioEngine sharedEngine];
    cur_sound = @"";
}


+ (BOOL) getSoundEnabel{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"sound"];
}

+ (float) getHighScore{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:@"highscore"];
}

+ (void) setHighScore:(float)val{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aIndex  =	[NSNumber numberWithFloat:val];
	[defaults setObject:aIndex forKey:@"highscore"];
	[NSUserDefaults resetStandardUserDefaults];
}

-(void) playBackground:(NSString *)title{
    if (g_bSound) {
        if (cur_sound != title || ![sae isBackgroundMusicPlaying]) {
            [sae stopBackgroundMusic];
//            [sae setBackgroundMusicVolume:0.1f];
            [sae playBackgroundMusic:title loop:YES];
            cur_sound = title;
        }
    }
}

-(void) pauseBackgroud{
    if (g_bSound) {
        [sae pauseBackgroundMusic];
    }
}
-(void) resumeBackground{
    if (g_bSound) {
        [sae resumeBackgroundMusic];
    }
}

-(void) playSoundEffect:(NSString *)title{
    if (g_bSound) {
        [sae playEffect:title];
    }
}

-(void) stopBackground{
    [sae stopBackgroundMusic];
}

-(void) stopEffect{
}

+ (BOOL) isSetValuesAtFirstLoad{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"fir_start"];
}

+ (void) setValuesAtFirstLoad:(BOOL)flag{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aIndex  =	[NSNumber numberWithBool:flag];
	[defaults setObject:aIndex forKey:@"fir_start"];
	[NSUserDefaults resetStandardUserDefaults];
}

+ (BOOL) getDetectCollision{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"collision"];
}

+ (void) setDetectCollision:(BOOL)flag{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* aIndex  =	[NSNumber numberWithBool:flag];
	[defaults setObject:aIndex forKey:@"collision"];
	[NSUserDefaults resetStandardUserDefaults];
}

@end
