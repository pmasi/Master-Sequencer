
#import "GamePlayLaer.h"
#import "AnimatedText.h"
#import "global.h"
#import "SharedData.h"
#import "Chartboost.h"
#import <RevMobAds/RevMobAds.h>
#import "AppDelegate.h"
#include <math.h>
#import "Appirater.h"
#include "math.h"


@implementation GamePlayLaer

#define characterSpeed 12
#define characterMaxSpeed 40
#define characterAccelerationRatio 0.005

#define paddleScale 0.48f
#define pipeSize .3
#define spaceBetweenLeftAndRightPipes 80


#define pipeHorizontalOffsetVariationFactor 0.18
#define horizontalAmplitudeVariationMaxPixel 78
#define horizontalAmplitudeInitialObtusity 0.5
#define horizontalAmplitudeMaxObtusity 0.95
#define horizontalAmplitudeObtusitySpeed 0.014
#define pathVariationUnit   0.01



#define displayInstructionDuration 3.5
#define TIME_ACT_INTERVAL   0.04f
#define TIME_ACT_INDIVIDUAL 0.14f * SCALE_Y

#define PI 3.14159265

+(CCScene *) scene
{
    
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayLaer *layer = [GamePlayLaer node];
	// add layer as a child to scene
	[scene addChild: layer z:1];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]))
    {
		// enable events
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
        preparingNextWave = YES;
        
        speedAdjustement = 1;
        if (IS_IPAD)
        {
            speedAdjustement = 2.0;
        }
        if(IS_RETINA)
        {
            speedAdjustement *= 0.5;
        }
        else
        {
        }
        [self initLogo];
        [self initPhysics];
        [self initBackground];
        [self InitializePaddle];
        [self InitializeLeftPore];
        [self InitializeRightPore];
        [self initializeInstructions];
        
        paddle.position = ccp(SCREEN_WIDTH/2 , paddle.position.y);
        leftpore.position = ccp(SCREEN_WIDTH/2  - spaceBetweenLeftAndRightPipes/2, paddle.position.y);
        rightpore.position = ccp(SCREEN_WIDTH/ 2 + spaceBetweenLeftAndRightPipes/2, paddle.position.y);
        
        currentSpeed = characterSpeed * speedAdjustement;
        pipePassedCount = 0;
        timeElapsedSinceLastSpawn = 0;
        currentAlgorithUsedIndex = 0;
        direction = 1;
        factor = horizontalAmplitudeInitialObtusity;
        algorithmTimeUsedCount = 0;
        algorithmCurrentType = 0;
        pipePassedCount = 0;
        
        [self InitPipes];
        [self RemoveAllDNA];
        
        [self initAppirater];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        BOOL tutorialAlreadyShown = [prefs boolForKey:@"tutorialAlreadyShown"];
        
        if(!tutorialAlreadyShown)
        {
            [self initTutorial];
            [prefs setBool:YES forKey:@"tutorialAlreadyShown"];
        }
        
        [[SharedData getSharedInstance] playBackground:SOUND_BACK];
        
	}
	return self;
}

#pragma mark - #yo - initializing sprites
-(void)initLogo
{
    logo = [CCSprite spriteWithFile:@"textures/gui/fp.png"];
    logo.anchorPoint = ccp(0.5f, 0.5f);
    logo.position = ccp((SCREEN_WIDTH) / 2, SCREEN_HEIGHT /2);
    [self addChild:logo z:10];
}

-(void)initTutorial
{
    tutorial = [CCSprite spriteWithFile:@"textures/instructions.png"];
    [tutorial setPosition:ccp(SCREEN_WIDTH / 2, 60 * SCALE_Y)];
    [self addChild:tutorial z:11];
}


-(void) initBackground{
    m_nGamePlayCount = 0;
    
    // background image
    if (IS_IPHONE_5)
    {
        spr_bg = [CCSprite spriteWithFile:@"textures/bg-568.png"];
    }
    else
    {
        spr_bg = [CCSprite spriteWithFile:@"textures/bg.png"];
    }
    spr_bg.anchorPoint = ccp(0,0);
    [self addChild:spr_bg z:-1];
    
    
    // menu
    m_btnPlay = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_play.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_play.png"]
                                                target:self
                                              selector:@selector(onMenuPlay:)];
    
    m_btnRate = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_rate.png"]
                                           selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_rate.png"]
                                                   target:self
                                                 selector:@selector(onMenuRateAppNow:)];
    
    m_btnGameCenter = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_rang.png"]
                                              selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_rang.png"]
                                                      target:self
                                                    selector:@selector(onMenuGameCenter:)];
    
    m_btnRate.position = ccp(- POS_BUTTON_Y  * SCALE_X, POS_BUTTON_Y * SCALE_Y);
    m_btnPlay.position = ccp(SCREEN_WIDTH + POS_BUTTON_Y * SCALE_X , POS_BUTTON_Y * SCALE_Y);
    m_btnGameCenter.position = ccp(POS_BUTTON_Y * 2 * SCALE_X + 15 * SCALE_X, - POS_BUTTON_Y * SCALE_Y);
    
    CCMenu* menu = [CCMenu menuWithItems:m_btnRate, m_btnPlay, m_btnGameCenter, nil];
    menu.position = CGPointZero;
    if(IS_IPHONE_5)
    {
        [menu setPosition:ccp(menu.position.x, menu.position.y - 35)];
    }
    [self addChild:menu z:10];
    //[self disableMenu];
    
    // add score
    m_HighScore = [SharedData getHighScore];

    m_lblScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.1f", m_Score] fontName:FontName fontSize:24.0f];
    m_lblScore.color = ccc3(50, 50, 50);
    m_lblScore.anchorPoint = ccp(0.5, 0.5);
    m_lblScore.scale = SCALE_X;
    m_lblScore.opacity = 0;
    [self addChild:m_lblScore z:10];
    
    m_lblScoreTitle = [CCLabelTTF labelWithString:@"last score" fontName:FontName fontSize:16.0f];
    m_lblScoreTitle.anchorPoint = ccp(0.5, 1.4);
    m_lblScoreTitle.color = ccc3(50, 50, 50);
    m_lblScoreTitle.scale = SCALE_X;
    m_lblScoreTitle.position = CGPointZero;
    m_lblScoreTitle.opacity = 0;
    [self addChild:m_lblScoreTitle z:10];
    
    m_lblHighScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.1f", m_HighScore] fontName:FontName fontSize:24.0f];
    m_lblHighScore.color = ccc3(50, 50, 50);
    m_lblHighScore.anchorPoint = ccp(0.5, 0.5);
    m_lblHighScore.scale = SCALE_X;
    m_lblHighScore.opacity = 0;
    [self addChild:m_lblHighScore z:10];
    
    m_lblHighScoreTitle= [CCLabelTTF labelWithString:@"best score" fontName:FontName fontSize:16.0f];
    m_lblHighScoreTitle.anchorPoint = ccp(0.5, 1.4);
    m_lblHighScoreTitle.color = ccc3(50, 50, 50);
    m_lblHighScoreTitle.position = CGPointZero;
    m_lblHighScoreTitle.scale = SCALE_X;
    m_lblHighScoreTitle.opacity = 0;
    [self addChild:m_lblHighScoreTitle z:10];
    
    // add menu
    [self showBarAnimNonPlay];
}

-(void) showBarAnimNonPlay{
    [self showTitleMenu];

    if (m_HighScore == m_Score && m_HighScore != 0) {
        [m_lblScore runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:POS_SCORE_LEFT]];
    }
    else{
        [m_lblScore runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:POS_SCORE_LEFT]];
    }

}

-(void) showTitleMenu
{
    if (m_nGamePlayCount == 0 || m_nGamePlayCount == 3)
    {
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(showADS) userInfo:nil repeats:NO];
        //[self showADS];
    }
    
    //[text dropAnimation];
    id actionMoveTextDown = [CCMoveTo actionWithDuration:0.8f position:ccp(SCREEN_WIDTH / 2, 9 * SCREEN_HEIGHT / 12)];
    [logo runAction:[CCSequence actions:actionMoveTextDown,
                      [CCCallFunc actionWithTarget:self selector:@selector(enableMenu)], nil]];
    
    [m_btnPlay setAnchorPoint:ccp(0.5f,0.5f)];
    [m_btnGameCenter setAnchorPoint:ccp(0.5f,0.5f)];
    [m_btnRate setAnchorPoint:ccp(0.5f,0.5f)];
    
    [m_btnPlay runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH / 2 - m_btnRate.contentSize.width / 4, SCREEN_HEIGHT / 2 - m_btnRate.contentSize.height - 20)]];
    [m_btnGameCenter runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH / 2+ m_btnRate.contentSize.width / 4 , SCREEN_HEIGHT / 2 - m_btnRate.contentSize.height - 20)]];
    [m_btnRate runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 10)]];
    //[self runActionWi:[CCSequence actions:0.8f,[CCCallFunc actionWithTarget:self selector:@selector(enableMenu)], nil]];
    

    if (m_nGamePlayCount == 0) {
        if (m_HighScore > 0) {
            // show high score only
            m_lblHighScore.position = POS_SCORE_RIGHT;
            m_lblHighScore.string = [NSString stringWithFormat:@"%.1f", m_HighScore];
            [m_lblHighScore runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
            m_lblHighScoreTitle.position = POS_SCORE_RIGHT;
            [m_lblHighScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
        }
    }
    else{
        if (m_Score == m_HighScore) {
            m_lblHighScoreTitle.position = POS_SCORE_LEFT;
            [m_lblHighScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
        }
        else{
            m_lblHighScore.position = POS_SCORE_RIGHT;
            m_lblHighScore.string = [NSString stringWithFormat:@"%.1f", m_HighScore];
            [m_lblHighScore runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
            m_lblHighScoreTitle.position = POS_SCORE_RIGHT;
            [m_lblHighScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
            
            m_lblScoreTitle.position = POS_SCORE_LEFT;
            [m_lblScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:255]];
        }
    }
}

-(void) hideTitleMenu
{
    //[self disableMenu];
    //[text upAnimation];
    id actionMoveTextUp = [CCMoveTo actionWithDuration:0.8f position:ccp(SCREEN_WIDTH / 2, 16 * SCREEN_HEIGHT / 12)];
    [logo runAction:actionMoveTextUp];
    
    
    [m_btnPlay runAction:[CCSequence actions:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, -SCREEN_HEIGHT * 0.9f)],
                          [CCCallFunc actionWithTarget:self selector:@selector(readyGame1)], nil]];
    [m_btnGameCenter runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, -SCREEN_HEIGHT * 0.9f)]];
    [m_btnRate runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    
    [m_lblScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:0]];
    [m_lblHighScoreTitle runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:0]];
    [m_lblScore runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:0]];
    [m_lblHighScore runAction:[CCFadeTo actionWithDuration:TIME_BUTTON_ACTION / 2 opacity:0]];
}

#pragma  mark Buttons
-(void) onMenuPlay:(id)sender{
    m_nGameMode = MODE_PLAY;
    [self hideTitleMenu];
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
}

-(void) onMenuSetting:(id)sender{
    if (IS_IPAD) {
        vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController_ipad" bundle:nil];
    }
    else{
        if (IS_IPHONE_5) {
            vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController_568" bundle:nil];
        }
        else{
            vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        }
    }
//    [[CCDirector sharedDirector].view addSubview:vc.view];
    id appDelegate = [(AppController*) [UIApplication sharedApplication] delegate];
    [((AppController*)appDelegate).navController presentViewController:vc animated:YES completion:nil];
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
}

-(void) onMenuGameCenter:(id)sender
{
    id appDelegate = [(AppController*) [UIApplication sharedApplication] delegate];
    [appDelegate showLeaderboard];
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
}

#pragma mark #yo - Game plays when the play button is pressed then launched readyGame2
#pragma mark GamePlay
-(void) readyGame1{
    [self readyGame2];
    m_lblScore.opacity = 255;
    m_lblScore.position = POS_SCORE_HIDDEN;
}

-(void) readyGame2
{
    m_bActJump = NO;
    m_bActChump = NO;
    if (m_nGameMode == MODE_PLAY)
    {
        [self startGame];
    }
    else
    {
        // Would launch a tutorial mode here
    }
}

-(void) startGame
{
    
    NSUInteger r = arc4random_uniform(4);
    [self ShowInstructions:displayInstructionDuration];
    
    
    paddle.position = ccp(SCREEN_WIDTH / 2 , paddle.position.y);
    leftpore.position = ccp(SCREEN_WIDTH / 2  - spaceBetweenLeftAndRightPipes/2, paddle.position.y);
    rightpore.position = ccp(SCREEN_WIDTH / 2 + spaceBetweenLeftAndRightPipes/2, paddle.position.y);
    
    if(tutorial != nil)
    {
        [tutorial setVisible:NO];
    }
    
    
    [self RemoveAllPipes];
    [self RemoveAllDNA];
    
    currentSpeed = characterSpeed * speedAdjustement;
    pipePassedCount = 0;
    timeElapsedSinceLastSpawn = 0;
    currentAlgorithUsedIndex = r;
    direction = 1;
    factor = horizontalAmplitudeInitialObtusity;
    algorithmTimeUsedCount = 0;
    algorithmCurrentType = 0;
    pipePassedCount = 0;
    
    [self InitPipes];
    
    m_nGameMode = MODE_PLAY;
    m_bGamePlaying = YES;
    m_Score = 0;
    m_fReadyTime = TIME_READY + (arc4random() % 5 - 2) * 0.1f;
    m_fEnemyInterval = TIME_ENEMY_INTERVAL;
    m_fCounter = 0.0f;
    [m_lblScore runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.5f + TIME_BAR_SCALE],
                           [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:POS_SCORE_BOTTOM],
                           nil]];
    
    [self scheduleUpdate];
}


#pragma mark ENABLE / DISABLE
-(void) enableMenu{
    m_btnGameCenter.isEnabled = YES;
    m_btnPlay.isEnabled = YES;
    m_btnRate.isEnabled = YES;
}

-(void) disableMenu{
    m_btnGameCenter.isEnabled = NO;
    m_btnPlay.isEnabled = NO;
    m_btnRate.isEnabled = NO;
}


// timer
-(void) update:(ccTime)dt
{
    if (m_bGamePlaying)
    {
        CCSprite *itemMissed = [self PlayerHasCollidedWithRoad];
        //itemMissed = nil;
        if(itemMissed != nil)
        {
            [self ItemAnimationCrash:itemMissed];
            m_bGamePlaying = NO;
            m_bShowGameOver = NO;
            [[SharedData getSharedInstance] playSoundEffect:EFFECT_EXPLOSION];
            
        }
        else
        {
            [self RemovePipesExpired];
            [self BringPipesDown];
            
            timeElapsedSinceLastSpawn += dt;
            m_fCounter += dt;
            m_Score = m_fCounter;
            if (m_HighScore < m_Score) {
                m_HighScore = m_Score;
            }
            m_lblScore.string = [NSString stringWithFormat:@"%.1f kbp", m_Score];
        }
    }
    else
    {
        [self schedule:@selector(onTimeShowGameOver) interval:(float)((SCREEN_WIDTH + 100 * SCALE_X) / SPEED_BLOCK + 0.5f)];
        BOOL flag = NO;
        for (CCSprite* temp in [self children]) {
            if (temp.tag == TAG_ENEMY) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [self onTimeShowGameOver];
        }
    }
    
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(dt, velocityIterations, positionIterations);
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != nil) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            CGPoint pos = myActor.position;
            float ang = -myActor.rotation / 180 * M_PI;
            b->SetTransform(b2Vec2(pos.x / PTM_RATIO, pos.y / PTM_RATIO), ang);
        }
	}

}


-(void) onTimeShowGameOver
{
    if (!m_bShowGameOver)
    {
        m_bShowGameOver = YES;
        [self showBarAnimNonPlay];
        m_nGamePlayCount++;
        [SharedData setHighScore:m_HighScore];
        id appDelegate = [(AppController*) [UIApplication sharedApplication] delegate];
        [appDelegate submitScore];
        [self unscheduleUpdate];
        [self unschedule:_cmd];
    }
    else {
        [self unschedule:_cmd];
    }
}

#pragma mark Touch

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bGamePlaying)
    {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInView: [touch view]];
            CGPoint touch_location = [[CCDirector sharedDirector] convertToGL:location];
            if(!touchDown)
            {
                touchDown = YES;
                touch_location_initialX = touch_location.x;
                paddleInitialPosX = paddle.position.x;
                leftporetouchDown = YES;
                leftporetouch_location_initialX = touch_location.x;
                leftporeInitialPosX = paddle.position.x;
                rightporetouchDown = YES;
                rightporetouch_location_initialX = touch_location.x;
                rightporeInitialPosX = paddle.position.x;
            }
        }
    }
    else
    {
#pragma mark #yo tutorial logic
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bGamePlaying && touchDown)
    {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInView: [touch view]];
            CGPoint touch_location = [[CCDirector sharedDirector] convertToGL:location];
            float paddlePosX = paddleInitialPosX + (touch_location.x - touch_location_initialX);
            float leftporePosX = leftporeInitialPosX + (touch_location.x - touch_location_initialX);
            float rightporePosX = rightporeInitialPosX + (touch_location.x - touch_location_initialX);
            
            paddle.position = ccp( paddlePosX, paddle.position.y);
            leftpore.position = ccp( leftporePosX - spaceBetweenLeftAndRightPipes/2, paddle.position.y);
            rightpore.position = ccp( rightporePosX + spaceBetweenLeftAndRightPipes/2, paddle.position.y);
            //[[SharedData getSharedInstance] playSoundEffect:EFFECT_JUMP];
        }
    }

}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchDown = NO;
    leftporetouchDown = NO;
    rightporetouchDown = NO;
}

// ads
-(void) showADS{
    [[Chartboost sharedChartboost] showInterstitial];
    [[RevMobAds session] showFullscreen];
}

-(void) initPhysics
{
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Bodies are allowed to sleep
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
//	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	// Define the ground body.
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
}



-(void) removeAllBodies{
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        b->SetUserData(nil);
        world->DestroyBody(b);
    }
}
-(b2World*) getWorld{
    return world;
}

-(void) draw
{
    //
    // IMPORTANT:
    // This is only for debug purposes
    // It is recommended to disable it only in certain cases
    //
    [super draw];
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
    kmGLPushMatrix();
    
    world->DrawDebugData();
    
    kmGLPopMatrix();
}

-(void) dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [self removeAllBodies];
    delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	delete contactListener;
    contactListener = NULL;
	[super dealloc];
}

-(void) addBody:(CCSprite*)spr{
    CGSize sz = [spr boundingBox].size;
    CGPoint p = spr.position;
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2FixtureDef fixtureDef_bullet;
    b2Body* body = world->CreateBody(&bodyDef);
    
    b2PolygonShape box;
    box.SetAsBox(sz.width / (2 * PTM_RATIO), sz.height / (2 * PTM_RATIO));
    fixtureDef_bullet.shape = &box;
    fixtureDef_bullet.density = 0.1f;
    fixtureDef_bullet.friction = 0.1f;
    fixtureDef_bullet.restitution = 0.1f;
    body->CreateFixture(&fixtureDef_bullet);
    body->SetUserData(spr);
//    spr.opacity = 30;
}


-(void)onMenuRateAppNow:(id)sender
{
    [Appirater setAppId:APPLE_APP_ID];
    [Appirater rateApp];
}


-(void)initAppirater
{
    [Appirater setAppId:APPLE_APP_ID];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

-(CCSprite*)PlayerHasCollidedWithRoad
{
    //CGRect paddleArea = paddle.boundingBox;
    
    
    
    
    for(CCSprite *item in [self children])
    {
        if(item.tag >= 1000)
        {
            CGRect validPaddleArea = CGRectMake(paddle.position.x - (0.2 * paddle.boundingBox.size.width) , paddle.position.y + (0.2 * paddle.boundingBox.size.height), 0.5 * paddle.boundingBox.size.width, 0.6 * paddle.boundingBox.size.height);
            //CGRect validFallingItemArea = CGRectMake(item.position.x + 0.1 * item.boundingBox.size.width, item.position.y, 0.8 * item.boundingBox.size.width, 0.9 * item.boundingBox.size.height);
            
            if(CGRectIntersectsRect(validPaddleArea, item.boundingBox))
            {
                return item;
            }
        }
    }
    return nil;
}



-(void)InitializePaddle
{
    paddle = [CCSprite spriteWithFile:@"textures/paddle/paddle.png"];
    [self addChild:paddle z:5];
    paddle.tag = -100;
    paddle.anchorPoint = ccp(0.5,0.5);
    [paddle setPosition:ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, 100 * SCALE_Y)];
    [paddle setScale:paddleScale];
}

-(void)InitializeLeftPore
{
    leftpore = [CCSprite spriteWithFile:@"textures/pore/leftpore.png"];
    [self addChild:leftpore z:5];
    leftpore.tag = -101;
    leftpore.anchorPoint = ccp(1,1);
    [leftpore setPosition:ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, 100 * SCALE_Y)];
    [leftpore setScale:paddleScale];
}

-(void)InitializeRightPore
{
    rightpore = [CCSprite spriteWithFile:@"textures/pore/rightpore.png"];
    [self addChild:rightpore z:5];
    rightpore.tag = -102;
    rightpore.anchorPoint = ccp(0,1);
    [rightpore setPosition:ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, 100 * SCALE_Y)];
    [rightpore setScale:paddleScale];
}

-(void)initializeInstructions
{
    instructions = [CCSprite spriteWithFile:@"textures/instructions.png"];
    [self addChild:instructions z:10];
    paddle.tag = 0;
    instructions.opacity = 200;
    [instructions setPosition:ccp(SCREEN_WIDTH / 2, 50 * SCALE_Y)];
    instructions.visible = NO;
}

-(void)ShowInstructions:(int)seconds
{
    instructions.visible = YES;
    id actionBlink = [CCBlink actionWithDuration:0.8f blinks:3];
    id actionHide = [CCHide action];
    id actionDelay = [CCDelayTime actionWithDuration:seconds];
    
    [instructions runAction:[CCSequence actions:actionBlink, actionDelay,
                     actionHide, nil]];
}

-(void)ItemAnimationCrash:(CCSprite*)item
{
    //[item stopAllActions];
    [item runAction:[CCBlink actionWithDuration:3.0f blinks:13]];
}


-(void)InitPipes
{
    currentHorizontalSpaceBetweenPipes = spaceBetweenLeftAndRightPipes;
    /*if(IS_RETINA)
    {
        currentHorizontalSpaceBetweenPipes *= 2;
    }*/
    
    pipePassedCount = 0;
    CCSprite *pipeSpriteRight, *pipeSpriteLeft, *DNASprite;
    float ouverture = 80;
    if(IS_RETINA)
    {
        ouverture *= 2;
    }
    
    float decrement = ouverture / 16;
    
    for(float i = 0; i < pipesMaxCount; i += 1.0f)
    {
        pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
        
        pipeSpriteLeft = [CCSprite spriteWithFile:@"textures/pipes/wall_horizontal.png"];
        pipeSpriteLeft.anchorPoint = ccp(1.0f, 0.5f);
        [pipeSpriteLeft setScale:pipeSize];
        [self addChild:pipeSpriteLeft z:3];
        pipeSpriteLeft.position = ccp(SCREEN_WIDTH / 2 - currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation/2 - ouverture, (SCREEN_HEIGHT / 2) + (i * pipeSpriteLeft.contentSize.height * pipeSize));
        pipeSpriteLeft.tag = 1000;
        
        
        pipeSpriteRight = [CCSprite spriteWithFile:@"textures/pipes/wall_horizontal.png"];
        pipeSpriteRight.anchorPoint = ccp(1.0f, 0.5f);
        [pipeSpriteRight setScale:pipeSize];
        [pipeSpriteRight setScaleX:pipeSize * -1];
        [self addChild:pipeSpriteRight z:3];
        pipeSpriteRight.position = ccp((SCREEN_WIDTH / 2)  + currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation/2 + ouverture, (SCREEN_HEIGHT / 2) + (i * pipeSpriteLeft.contentSize.height * pipeSize));
        pipeSpriteRight.tag = 1001;
        
        pipePassedCount++;
        ouverture = ouverture - decrement;
        if (ouverture < 0) {
            ouverture = 0;
        }

    }
    
    for(float h = 0; h < pipesMaxCount; h += 1.0f)
    {
        pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
        
        DNASprite = [CCSprite spriteWithFile:@"textures/DNA/DNA.png"];
        DNASprite.anchorPoint = ccp(0.5f,0.5f);
        [DNASprite setScaleY:pipeSize];
        [self addChild:DNASprite z:3];
        DNASprite.position = ccp((SCREEN_WIDTH / 2) + (pipeCurrentHorizontalOffsetVariation/2) + ouverture, (SCREEN_HEIGHT / 2) + (h * pipeSpriteLeft.contentSize.height * pipeSize));
        DNASprite.tag = 999;
        
        ouverture = ouverture - decrement;
        if (ouverture < 0) {
            ouverture = 0;
        }
    }
}

-(float)GetPipeHorizontalOffset
{
    int switchPipesAfterCount = 12;
    algorithmTimeUsedCount++;
    float val = algorithmTimeUsedCount * pipeHorizontalOffsetVariationFactor;
    
    if(algorithmTimeUsedCount % switchPipesAfterCount == 0)
    {
        currentAlgorithUsedIndex += (pathVariationUnit * direction);
    }
    
    if (currentAlgorithUsedIndex > 1)
    {
        currentAlgorithUsedIndex = 1;
        direction = -1;
        //NSLog(@"direction down");
    }
    if(currentAlgorithUsedIndex < 0)
    {
        direction = 1;
        currentAlgorithUsedIndex = 0;
        //NSLog(@"direction up");
        factor += horizontalAmplitudeObtusitySpeed;
        if (factor > horizontalAmplitudeMaxObtusity)
        {
            factor = horizontalAmplitudeMaxObtusity;
        }
    }
    
    return horizontalAmplitudeVariationMaxPixel * factor * cosf(val * currentAlgorithUsedIndex * PI / 180);
}

-(void)RemovePipesExpired
{
    int markedCount = 0;
    for(CCSprite *item in [self children])
    {
        if(item.tag == 1000)
        {
            if(item.position.y < -200)
            {
                item.tag = -1000;
                markedCount++;
            }
        }
        if(item.tag == 1001)
        {
            if(item.position.y < -200)
            {
                item.tag = -1001;
                markedCount++;
            }
        }
        if(item.tag == 999)
        {
            if(item.position.y < -200)
            {
                item.tag = -999;
            }
        }
    }
    
    int currentMark = 0;
    float posXLeft = 0;
    float posXRight = 0;
    float posY = 0;
    float posYDNA = 0;
    float posXDNA = 0;
    float pipesPassedThisTurn = 0;
    
    pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
    
    for(CCSprite *item in [self children])
    {
        if(item.tag == -1000)
        {
            posY = [self getposYOfHighestPipe] + item.contentSize.height * pipeSize;
            posXLeft = SCREEN_WIDTH / 2 - currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation;
            [item setPosition:ccp(posXLeft, posY)];
            item.tag = 1000;
            pipesPassedThisTurn++;
        }

        if(item.tag == -1001)
        {
            posXRight = (SCREEN_WIDTH / 2)  + currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation;
            [item setPosition:ccp(posXRight, posY)];
            pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
            item.tag = 1001;
            pipesPassedThisTurn++;
        }
        
        if(item.tag == -999)
        {
            pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
            posYDNA = [self getposYOfHighestDNA] + item.contentSize.height * pipeSize;
            posXDNA = (SCREEN_WIDTH / 2) + pipeCurrentHorizontalOffsetVariation / 3;
            [item setPosition:ccp(posXDNA, posYDNA)];
            pipeCurrentHorizontalOffsetVariation = [self GetPipeHorizontalOffset];
            item.tag = 999;
            pipesPassedThisTurn++;
        }
        
        currentMark++;
        if(pipesPassedThisTurn == 2)
        {
            pipePassedCount++;
            pipesPassedThisTurn = 0;
        }
        
    }
}

-(float)getposYOfHighestPipe
{
    float highestPosY = SCREEN_HEIGHT;
    for(CCSprite *item in [self children])
    {
        if(item.tag >= 1000)
        {
            if(item.position.y > highestPosY)
            {
                highestPosY = item.position.y;
            }
        }
    }
    return highestPosY;
}

-(float)getposYOfHighestDNA
{
    float highestPosYDNA = SCREEN_HEIGHT;
    for(CCSprite *item in [self children])
    {
        if(item.tag == 999)
        {
            if(item.position.y >highestPosYDNA)
            {
                highestPosYDNA = item.position.y;
            }
        }
    }
    return highestPosYDNA;
}

-(void)BringPipesDown
{
    currentSpeed =  currentSpeed + characterAccelerationRatio * speedAdjustement;
    if(currentSpeed > characterMaxSpeed)
    {
        currentSpeed = characterMaxSpeed;
    }
    for(CCSprite *item in [self children])
    {
        if(item.tag >= 999)
        {
            [item setPosition:ccp(item.position.x, item.position.y - currentSpeed)];
        }
    }
}

-(void)ResetPaddleOriginalPosition
{
    
}

-(void)RemoveAllPipes
{
    BOOL itemFound = NO;
    BOOL continuing = YES;
    while (continuing)
    {
        continuing = NO;
        itemFound = NO;
        for(CCSprite *item in [self children])
        {
            if(item.tag == 1000 || item.tag == 1001 || item.tag == -1000 || item.tag == -1001)
            {
                itemFound = YES;
                [self removeChild:item cleanup:YES];
                break;
            }
        }
        if(itemFound)
        {
            continuing = YES;
        }
    }
    
}

-(void)RemoveAllDNA
{
    BOOL itemFound = NO;
    BOOL continuing = YES;
    while (continuing)
    {
        continuing = NO;
        itemFound = NO;
        for(CCSprite *item in [self children])
        {
            if(item.tag == 999 || item.tag == -999)
            {
                itemFound = YES;
                [self removeChild:item cleanup:YES];
                break;
            }
        }
        if(itemFound)
        {
            continuing = YES;
        }
    }
    
}

@end

























