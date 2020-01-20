@interface YTAppDelegate : UIResponder
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;
@end

@interface YTAppViewController : UIViewController
@property UIViewController *childModalViewController;
@end

@interface YTPageStyleController : NSObject //This class controls YouTube's built-in dark mode
- (void)setPageStyle:(NSInteger)pageStyle;
@end

@interface CANavigationViewController : UINavigationController
@end

@interface CAAccountViewController : UIViewController //The root Cercube view controller
@end
