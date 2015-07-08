
#import "SettingViewController.h"
#import "SharedData.h"
#import "global.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize viewAbout;
@synthesize viewSound;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView.text = @"\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n\nJump! Chump! game \n";
    textView.textAlignment = UITextAlignmentCenter;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [viewSound release];
    [viewAbout release];
    [textView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setViewSound:nil];
    [self setViewAbout:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}
- (IBAction)onButtoneDone:(id)sender {
//    [self.view removeFromSuperview];
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSelectBackMusic:(id)sender {
    UISwitch* sw = (UISwitch*)sender;
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
    if ([sw isOn]) {
        [[SharedData getSharedInstance] setG_bSound:YES];
        [[SharedData getSharedInstance] playBackground:SOUND_BACK];
    }
    else{
        [[SharedData getSharedInstance] setG_bSound:NO];
        [[SharedData getSharedInstance] stopBackground];
    }
}

- (IBAction)onSelectEffect:(id)sender {
    UISwitch* sw = (UISwitch*)sender;
    if ([sw isOn]) {
        [[SharedData getSharedInstance] setG_bEffect:YES];
    }
    else{
        [[SharedData getSharedInstance] setG_bEffect:NO];
    }
}

- (IBAction)onSelectTap:(id)sender {
    UISegmentedControl* seg = (UISegmentedControl*) sender;
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];

    if ([seg selectedSegmentIndex] == 0) {
        viewSound.hidden = NO;
        viewAbout.hidden = YES;
    }
    else {
        viewSound.hidden = YES;
        viewAbout.hidden = NO;
    }
}

@end
