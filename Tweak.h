@interface YTAppViewController : UIViewController
@property NSString *darkModeRespectsWhat;
@property UIViewController *childModalViewController;
- (void)viewDidLoad;
- (void)dealloc;
- (void)startYouTubeDarkModeSync;
- (void)changeToDarkOrLightMode:(NSInteger)newMode;
@end

@interface YTMainWindow : UIWindow
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection;
@end

@interface YTAppDelegate : UIResponder
- (UIWindow *)window;
@end

@interface YTPageStyleController : NSObject //this class controls YouTube's built-in dark mode
- (void)setPageStyle:(NSInteger)pageStyle;
@end

@interface CANavigationViewController : UINavigationController
@end

@interface CAAccountViewController : UIViewController
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end
