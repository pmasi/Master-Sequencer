
#import "AnimatedText.h"
#import "global.h"

@implementation AnimatedText

@synthesize total_length;
@synthesize arr_letters;
@synthesize action_flag;
@synthesize total_time;

#define APP_TITLE_FONT_SIZE 22.0f

#define TIME_ACT_INTERVAL   0.04f
#define TIME_ACT_INDIVIDUAL 0.14f * SCALE_Y

-(id) initWithString:(NSString*) str{
    self = [super init];
    if (self) {
        arr_letters = [[NSMutableArray alloc] init];
        CCSprite* spr_back = [[CCSprite alloc] init];
        int cnt = [str length];
        float  pos_x = 0;
        total_length = 0;
        for(int i = 0; i < cnt; i ++){
            CCLabelTTF* label = [CCLabelTTF labelWithString:[str substringWithRange:NSMakeRange(i, 1)]
                                                   fontName:FontName fontSize:APP_TITLE_FONT_SIZE];
            label.position = ccp(pos_x, 0);
            label.scale = SCALE_X;
            label.color = ccWHITE;
            [arr_letters addObject:label];
            [spr_back addChild:label];
            pos_x += [label boundingBox].size.width + 5 * SCALE_X;
        }
        total_time = TIME_ACT_INTERVAL * (cnt - 1) + TIME_ACT_INDIVIDUAL;
        total_length = pos_x;
        [self addChild:spr_back];
        [self schedule:@selector(onTimeAnimation) interval:TIME_TITLE_ANIM_INTERVAL];
    }
    return  self;
}

-(void) onTimeAnimation{
    if (action_flag) {
        int cnt = [arr_letters count];
        int action_type = (arc4random() % 10 + 5) % 2;
        int action_direction = (arc4random() % 10 + 5) % 2;
        
        for (int i = 0; i < cnt; i++) {
            CCLabelTTF* temp;
            if (action_direction == 0) {
                // from front
                temp = (CCLabelTTF*)[arr_letters objectAtIndex:i];
            }
            else{
                // from back
                temp = (CCLabelTTF*)[arr_letters objectAtIndex:cnt - i - 1];
            }
            
            id scale1, scale2;
            if (action_type == 0) {
                // to big scale action
                scale1 = [CCScaleTo actionWithDuration:0.15 scale:1.25f * SCALE_X];
            }
            else{
                // to small scale action
                scale1 = [CCScaleTo actionWithDuration:0.15 scale:0.75f * SCALE_X];
            }
            scale2 = [CCScaleTo actionWithDuration:0.15 scale:1.0f * SCALE_X];
            id seq1 = [CCSequence actions:scale1, scale2, nil];
            [temp runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.07 * i], seq1, nil]];
        }
    }
}

-(void) dropAnimation{
    int cnt = [arr_letters count];
    for (int i = 0; i < cnt; i++) {
        CCLabelTTF* temp = (CCLabelTTF*)[arr_letters objectAtIndex:i];
        id move1;
        move1 = [CCMoveBy actionWithDuration:TIME_ACT_INDIVIDUAL position:ccp(0, -SCREEN_HEIGHT / 3)];
		[temp runAction:[CCSequence actions:[CCDelayTime actionWithDuration:TIME_ACT_INTERVAL * i], move1, nil]];
    }
}

-(void) upAnimation{
    
    int cnt = [arr_letters count];
    for (int i = 0; i < cnt; i++) {
        CCLabelTTF* temp = (CCLabelTTF*)[arr_letters objectAtIndex:cnt - i - 1];
        id move1;
        move1 = [CCMoveBy actionWithDuration:TIME_ACT_INDIVIDUAL position:ccp(0, SCREEN_HEIGHT / 3)];
		[temp runAction:[CCSequence actions:[CCDelayTime actionWithDuration:TIME_ACT_INTERVAL * i], move1, nil]];
    }
}
@end
