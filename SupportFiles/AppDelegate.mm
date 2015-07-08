
#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "GamePlayLaer.h"
#import "SharedData.h"
#import "global.h"
#import "Chartboost.h"


@implementation AppController

@synthesize viewController2;
@synthesize gameCenterManager, currentLeaderBoard;

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
    // Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if( ! [director_ enableRetinaDisplay:YES] )
        CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
//	[director_ pushScene: [IntroLayer scene]];
	[director_ pushScene: [GamePlayLaer scene]];
	
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    if (![SharedData isSetValuesAtFirstLoad]) {
        [SharedData setHighScore:0.0f];
        [SharedData setValuesAtFirstLoad:YES];
    }

	[self initGameCenter];
    
    [self createAdmobAds];
    
	return YES;
}

// Supported orientations: Portrait. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}

#pragma mark ChartBoost
- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);
    
    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}


/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No publishing campaign matches for that user (go make a new one in the dashboard)
 */

- (void)didFailToLoadInterstitial:(NSString *)location {
    NSLog(@"failure to load interstitial at location %@", location);
    
    // Show a house ad or do something else when a chartboost interstitial fails to load
}


/*
 * didCacheInterstitial
 *
 * Passes in the location name that has successfully been cached.
 *
 * Is fired on:
 * - All assets loaded
 * - Triggered by cacheInterstitial
 *
 * Notes:
 * - Similar to this is: cb.hasCachedInterstitial(String location)
 * Which will return true if a cached interstitial exists for that location
 */

- (void)didCacheInterstitial:(NSString *)location {
    NSLog(@"interstitial cached at location %@", location);
    
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */

- (void)didFailToLoadMoreApps {
    NSLog(@"failure to load more apps");
}


/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 * #Pro Tip: Use the delegate method below to immediately re-cache interstitials
 */

-(void)didDismissInterstitial:(CBLocation)location
{
    NSLog(@"dismissed interstitial");
    [[Chartboost sharedChartboost] cacheInterstitial:location];
}


/*
 * didDismissMoreApps
 *
 * This is called when the more apps page is dismissed
 *
 * Is fired on:
 * - More Apps click
 * - More Apps close
 *
 * #Pro Tip: Use the delegate method below to immediately re-cache the more apps page
 */

- (void)didDismissMoreApps {
    NSLog(@"dismissed more apps page, re-caching now");
    
    [[Chartboost sharedChartboost] cacheMoreApps];
}


/*
 * shouldRequestInterstitialsInFirstSession
 *
 * This sets logic to prevent interstitials from being displayed until the second startSession call
 *
 * The default is NO, meaning that it will always request & display interstitials.
 * If your app displays interstitials before the first time the user plays the game, implement this method to return NO.
 */

- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}

#pragma mark GameCenter View Controllers

- (void)initGameCenter{
	if(viewController2 != nil)
		return;
	viewController2 = [GCViewController alloc];
    self.currentLeaderBoard = kEasyLeaderboardID;
    
	if ([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
    
    viewController2.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   
}


- (void)submitScore
{
    float score = [SharedData getHighScore];
	if( score > 0){
        
        if ([GameCenterManager isGameCenterAvailable])
        {
            //[self initGameCenter];
            
            [self.gameCenterManager reportScore:score  forCategory:self.currentLeaderBoard];
            //[self.gameCenterManager reloadHighScoresForCategory:self.currentLeaderBoard];
        }
	}
}
- (void)abrirLDB
{
    [self initGameCenter];
    self.currentLeaderBoard = kEasyLeaderboardID;
    if ([GameCenterManager isGameCenterAvailable]) {
        [viewController2.view setHidden:NO];
        [self.window addSubview:viewController2.view];
                [self submitScore];
        [self showLeaderboard];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Gamecenter is not available in your iOS version" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
        
    }
}

- (void)abrirACHV{
    if ([GameCenterManager isGameCenterAvailable])
    {
        [viewController2.view setHidden:NO];
        [self.window addSubview:viewController2.view];
        [self showAchievements];
        
    }
}

- (void) showLeaderboard
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL)
    {
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
        [self submitScore];
        
		[self.navController presentModalViewController: leaderboardController animated: YES];
        //		leaderboardController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(0.0f));
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController1{
	[viewController1 dismissModalViewControllerAnimated: YES];
	[viewController2.view removeFromSuperview];
	[viewController2.view setHidden:YES];
	[viewController1 release];
}

- (void) showAchievements{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL){
		achievements.achievementDelegate = self;
		[viewController2 presentModalViewController: achievements animated: YES];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController1{
	[viewController1 dismissModalViewControllerAnimated: YES];
	[viewController2.view removeFromSuperview];
	[viewController2.view setHidden:YES];
	[viewController1 release];
}

- (IBAction) resetAchievements: (id) sender{
	[gameCenterManager resetAchievements];
}


-(void)createAdmobAds
{
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //kGADAdSizeBanner
    //kGADAdSizeSmartBannerLandscape
    GADBannerView *adBanner_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    adBanner_.adUnitID = ADMOB_BANNER_ID;
    adBanner_.delegate = nil;
    //adBanner_.frame = CGRectMake(0, winSize.height - 50, winSize.width, 50);
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [adBanner_ setRootViewController:[app navController]];
    [[CCDirector sharedDirector].view addSubview:adBanner_];
    
    GADRequest *r = [[GADRequest alloc] init];
    [adBanner_ loadRequest:r];
}

@end

