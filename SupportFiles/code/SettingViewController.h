
#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *viewSound;
@property (retain, nonatomic) IBOutlet UIView *viewAbout;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (IBAction)onSelectTap:(id)sender;
- (IBAction)onButtoneDone:(id)sender;
- (IBAction)onSelectBackMusic:(id)sender;
- (IBAction)onSelectEffect:(id)sender;

@end
