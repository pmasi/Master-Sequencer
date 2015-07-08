
#import "CCLayer.h"
#import "cocos2d.h"
#import "AnimatedText.h"
//#import "BackgroundLayer.h"
#import "SettingViewController.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "GADBannerView.h"


#define BANNER_TYPE kBanner_Portrait_Bottom

const int pipesMaxCount = 150;

typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}CocosBannerType;


@interface GamePlayLaer : CCLayer{

    CGSize      sz_jump;
    CCSprite * spr_bg;
    
    CCSprite *logo;
    CCSprite *pipe_v_left_up, *pipe_v_left_down;
    CCSprite *pipe_v_right_up, *pipe_v_right_down;
    CCSprite *pipe_v_mid_up, *pipe_v_mid_down;
    CCSprite *pipe_h_left, *pipe_h_right;
    
    CCSprite *mainCharacter;
    CCSprite *bonusLeftUp, *bonusLeftDown, *bonusMidUp, *bonusMidDown, *bonusMidRightUp, *bonusMidRightDown, *bonusRightUp, *bonusRightDown;
    
    float timeElapsedSinceLastSpawn;
    int lastBonusRespawnSpot;
        
    BOOL bonusLeftUpShown, bonusLeftDownShown, bonusMidUpShown, bonusMidDownShown, bonusMidRightUpShown, bonusMidRightDownShown, bonusRightUpShown, bonusRightDownShown;
    
    CCSprite *scorePlusOne;
    CCSprite *enemy;
    
    
    CCSprite *tutorial;
    //AnimatedText* text;
    int         m_nTutorialTouch;
    BOOL        m_bActJump;
    BOOL        m_bActChump;
    float         m_HighScore;
    float         m_Score;
    float       m_fEnemyInterval;
    float       m_fCounter;
    float       m_fReadyTime;
    BOOL        m_bShowGameOver;
    
    CCMenuItemSprite*   m_btnRate;
    CCMenuItemSprite*   m_btnPlay;
    CCMenuItemSprite*   m_btnGameCenter;
    
    CCLabelTTF*         m_lblHighScore;
    CCLabelTTF*         m_lblScore;
    CCLabelTTF*         m_lblScoreTitle;
    CCLabelTTF*         m_lblHighScoreTitle;
    int                 m_nGamePlayCount;
    int                 m_nGameMode;

    BOOL                m_bGamePlaying;
    

    SettingViewController*  vc;
    
    b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    b2Body* groundBody;
    b2ContactListener* contactListener;
    
    
    GADBannerView *mBannerView; //
    CocosBannerType mBannerType; //
    float on_x, on_y, off_x, off_y; //
    

    float currentFallSpeed;
    
    CCSprite *paddle; //controlled by player
    float touch_location_initialX;
    float paddleInitialPosX;
    BOOL touchDown;
    CCSprite *leftpore; //controlled by player
    float leftporetouch_location_initialX;
    float leftporeInitialPosX;
    BOOL leftporetouchDown;
    CCSprite *rightpore; //controlled by player
    float rightporetouch_location_initialX;
    float rightporeInitialPosX;
    BOOL rightporetouchDown;
    CCSprite *instructions;
    BOOL preparingNextWave;
    BOOL freezeWave;
    int waveCount;
    
    //CCSprite *roadPartLeft;
    //CCSprite *roadPartRight;
    
    
    float pipeCurrentHorizontalOffsetVariation;
    
    float speedAdjustement;
    int pipePassedCount;
    float currentHorizontalSpaceBetweenPipes;
    float currentSpeed;
    
    int algorithmTimeUsedCount;
    int algorithmCurrentType;
    float currentAlgorithUsedIndex;
    float direction;
    float factor;

}

//@property (strong, nonatomic)     BackgroundLayer* back_layer;


+(CCScene *) scene;

@end
