
#import "BackgroundLayer.h"
#import "global.h"

@implementation BackgroundLayer

#define MAX_INTERVAL    2.0f;
@synthesize m_bChangeBack;
@synthesize m_bChangeColor;


-(id) init{
    self = [super init];
    if (self) {
        if (IS_IPHONE_5) {
            spr_bg1 = [CCSprite spriteWithFile:@"textures/bg-568hd.png"];
            spr_bg2 = [CCSprite spriteWithFile:@"textures/bg-568hd.png"];
        }
        else{
            spr_bg1 = [CCSprite spriteWithFile:@"textures/bg.png"];
            spr_bg2 = [CCSprite spriteWithFile:@"textures/bg.png"];
        }
        
//        spr_bg1.opacity = 0;
//        spr_bg2.opacity = 0;
        spr_bg1.anchorPoint = ccp(0,1);
        spr_bg2.anchorPoint = ccp(0,1);
        
        [self addChild:spr_bg1 z:2];
        [self addChild:spr_bg2 z:2];
        [self startMoveBackground];
        
        color[0] = arc4random() % 120 + 80;
        color[1] = arc4random() % 120 + 80;
        color[2] = arc4random() % 120 + 80;
        back_color = [[CCLayerColor alloc] initWithColor:ccc4(color[0], color[1], color[2], 255) width:SCREEN_WIDTH height:SCREEN_HEIGHT];
        [self addChild:back_color z:1];
        [self scheduleUpdate];
        
        m_bColorDir = NO;
        idx = 2;
        m_bChangeBack = NO;
        m_bChangeColor = YES;
        
        m_fMoveInterval = 0.0f;
    }
    return self;
}

-(void) startMoveBackground{
    spr_bg1.position = ccp(0, SCREEN_HEIGHT);
    spr_bg2.position = ccp(0, spr_bg1.position.y + [spr_bg2 boundingBox].size.height);
    [self schedule:@selector(moveBackground) interval:0.1f];
}

-(void) moveBackground{
    if (m_bChangeBack) {
        if (m_fMoveInterval < 2.0f * SCALE_Y) {
            m_fMoveInterval += 0.2f;
        }
    }
    else{
        if (m_fMoveInterval > 0.0f ) {
            m_fMoveInterval -= 0.05f;
        }
        if (m_fMoveInterval < 0.0f) {
            m_fMoveInterval = 0.0f;
        }
    }
    if (m_fMoveInterval != 0.0f) {
        spr_bg1.position = ccp(0, spr_bg1.position.y - m_fMoveInterval);
        spr_bg2.position = ccp(0, spr_bg2.position.y - m_fMoveInterval);
        if (spr_bg1.position.y <= 0) {
            spr_bg1.position = ccp(0, spr_bg2.position.y + [spr_bg2 boundingBox].size.height);
        }
        else if(spr_bg2.position.y <= 0){
            spr_bg2.position = ccp(0, spr_bg1.position.y + [spr_bg1 boundingBox].size.height);
        }
    }
}


-(void) update:(ccTime) dt{
//    CCLOG(@"%.0f, %.0f, %.0f, %d %d", color[0],color[1],color[2], idx, m_bChangeColor);
    if (m_bChangeColor) {
        if (m_bColorDir) {
            color[idx] += 0.4f;
        }
        else{
            color[idx] -= 0.4f;
        }
        if (color[idx] >= 200) {
            color[idx] = 200;
            idx --;
            if (idx == -1) {
                idx = 2;
                m_bColorDir = !m_bColorDir;
            }
        }
        else if (color[idx] <= 80){
            color[idx] = 80;
            idx --;
            if (idx == -1) {
                idx = 2;
                m_bColorDir = !m_bColorDir;
            }
        }
        back_color.color = ccc3(color[0], color[1],color[2]);
    }
    else{
        color[idx] -= 2.0f;
        if (color[idx] <= 80){
            color[idx] = 80;
            idx --;
            if (idx == -1) {
                idx = 2;
            }
        }
        back_color.color = ccc3(color[0], color[1],color[2]);
    }
}

- (void) stopBackgroundAnimation{
    m_bChangeBack = NO;
}

-(void) startBackgroundAnimation{
    m_bChangeBack = YES;
}

- (void) stopBackgroundColorChange{
    m_bChangeColor = NO;
}

-(void) startBackgroundColorChange{
    m_bChangeColor = YES;
}

@end
