
#import "CCLayer.h"
#import "cocos2d.h"

@interface BackgroundLayer : CCLayer{
    CCLayerColor* back_color;
    CCSprite*       spr_bg1;
    CCSprite*       spr_bg2;
    BOOL            m_bColorDir; // yes - increase, no - decrease
    int             idx;
    float           color[3];
    float           m_fMoveInterval;
}
@property (nonatomic, assign) BOOL m_bChangeBack;
@property (nonatomic, assign) BOOL m_bChangeColor;

- (void) stopBackgroundAnimation;
-(void) startBackgroundAnimation;
- (void) stopBackgroundColorChange;
-(void) startBackgroundColorChange;
-(void) moveBackground;
-(void) startMoveBackground;
@end
