#import "Tweak.h"

%hook YTMainWindow
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection { //this method is called when iOS 13's dark mode is toggled
    %orig;
    YTAppDelegate *delegate = (YTAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate startYouTubeDarkModeSync];
}
%end

%hook YTAppDelegate
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions { //ensures the correct appearance is displayed even if dark mode was toggled when YouTube wasn't open
    BOOL result = %orig;
    [self startYouTubeDarkModeSync];
    return result;
}
%new
- (void)startYouTubeDarkModeSync { //if necessary, change YouTube's built-in appearance to iOS 13's current appearance
    YTAppViewController *YTAppVC = (YTAppViewController *)self.window.rootViewController;
    YTPageStyleController *darkModeController = MSHookIvar<YTPageStyleController *>(YTAppVC, "_pageStyleController"); //YTPageStyleController is an ivar of YTAppViewController, not an @property
    
    CAAccountViewController *rootCercubeVC; //get the instance of Cercube's root view controller
    if ([YTAppVC.childModalViewController isKindOfClass:%c(CANavigationViewController)]) {
        CANavigationViewController *nav = (CANavigationViewController *)YTAppVC.childModalViewController;
        rootCercubeVC = (CAAccountViewController *)[nav.viewControllers firstObject];
    }
    
    if (YTAppVC.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        [darkModeController setPageStyle:1]; //pass 1 to change to YouTube's built-in dark mode
        //compatibility with CercubeDarkMode
        if (rootCercubeVC) { //nil check
            [rootCercubeVC dismissViewControllerAnimated:YES completion:nil]; //Cercube's menus do not update their appearance immediately, so we have to dismiss the root Cercube VC for changes to take effect
        }
    }
    else if (YTAppVC.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [darkModeController setPageStyle:0]; //pass 0 to change to YouTube's built-in light mode
        if (rootCercubeVC) {
            [rootCercubeVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
%end
