@interface YTMainWindow : UIWindow
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection;
@end

@interface YTAppDelegate : UIResponder
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;
- (void)startYouTubeDarkModeSync;
- (UIWindow *)window;
@end

@interface YTAppViewController : UIViewController
@property UIViewController *childModalViewController;
@end

@interface YTPageStyleController : NSObject //this class controls YouTube's built-in dark mode
- (void)setPageStyle:(NSInteger)pageStyle;
@end

@interface CANavigationViewController : UINavigationController
@end

@interface CAAccountViewController : UIViewController //the root Cercube view controller
@end
