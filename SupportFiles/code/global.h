#import <UIKit/UIKit.h>

// device
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)


// scale and screen size
//#ifdef SHOrientationLandScape

#define SCREEN_WIDTH		[[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT			[[UIScreen mainScreen] bounds].size.height
#define SCALE_X                 (SCREEN_WIDTH /  320)
#define SCALE_Y                 (SCREEN_HEIGHT / 480)


#define FontName            @"HiraKakuProN-W6"

#define APPLE_APP_ID        @"961373960"
#define CB_APPID            @"insert ID here"
#define CB_SIGNATURE        @"insert ID here"
#define REVMOB_APP_ID       @"insert ID here"
#define ADMOB_BANNER_ID      @"insert ID here"
#define kEasyLeaderboardID  @"Master_Sequencer_Leaderboard_2"

#define EFFECT_BUTTON       @"button.wav"
#define EFFECT_JUMP         @"jump.wav"
#define EFFECT_EXPLOSION    @"explosion.wav"
#define SOUND_BACK          @"music_back.mp3"
#define SOUND_BONUS         @"bonus.mp3"


#define PTM_RATIO           32
// time
#define TIME_TITLE_ANIM_INTERVAL    3.0f

#define POS_BUTTON_Y        40
#define TIME_BUTTON_ACTION  0.4f
#define TIME_BAR_SCALE      0.2f * SCALE_X
#define TIME_HELP_ACTION    0.6f
#define NUM_BAR_HEIGHT      6
#define SPEED_BLOCK         250 / SCALE_X

#define TIME_ENEMY_INTERVAL 0.9f * SCALE_X
#define TIME_ROPE_ENEMY     20.0f
//#define TIME_ENEMY_ACROSS   2.3f
#define TIME_JUMP           0.5f
#define TIME_READY          1.0f

#define MODE_PLAY           10
#define MODE_TUTORIAL       11

// tag
#define TAG_ENEMY           10000
#define TAG_ROPE            10001
#define TAG_MAIN            10

#define POS_TOP_Y           SCREEN_HEIGHT / 2 + NUM_BAR_HEIGHT / 2 - 1
#define POS_BOTTOM_Y        SCREEN_HEIGHT / 2 - NUM_BAR_HEIGHT / 2 + 1

#define POS_SCORE_LEFT      ccp(3 * SCREEN_WIDTH / 12, 80 * SCALE_Y)
#define POS_SCORE_RIGHT     ccp(SCREEN_WIDTH * 9 / 12, 80 * SCALE_Y)
#define POS_SCORE_CENTER    ccp(SCREEN_WIDTH / 2, 80 * SCALE_Y)
#define POS_SCORE_BOTTOM    ccp(SCREEN_WIDTH / 2, 20 * SCALE_Y)
#define POS_SCORE_HIDDEN    ccp(SCREEN_WIDTH / 2, -50 * SCALE_Y)

#define POS_HELP_BOTTOM     ccp(SCREEN_WIDTH / 2, 20 * SCALE_Y)
#define POS_HELP_TOP        ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 20 * SCALE_Y)
#define POS_HELP_B_READY    ccp(SCREEN_WIDTH / 2, -60 * SCALE_Y)
#define POS_HELP_T_READY    ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT + 60 * SCALE_Y)



