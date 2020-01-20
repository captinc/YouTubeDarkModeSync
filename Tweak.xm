#import "Tweak.h"

UIWindow *keyWindow() { //keyWindow was deprecated in iOS 13, so here's a replacement
    UIWindow *foundWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}

void syncAppearance(UIViewController *sender) { //If necessary, this changes YouTube's built-in appearance to iOS 13's current appearance
    YTAppViewController *YTAppVC = (YTAppViewController *)keyWindow().rootViewController;
    YTPageStyleController *darkModeController = MSHookIvar<YTPageStyleController *>(YTAppVC, "_pageStyleController"); //YTPageStyleController is an ivar of YTAppViewController, not an @property
    
    CAAccountViewController *rootCercubeVC; //Get the instance of the root Cercube VC
    if ([YTAppVC.childModalViewController isKindOfClass:%c(CANavigationViewController)]) {
        CANavigationViewController *nav = (CANavigationViewController *)YTAppVC.childModalViewController;
        rootCercubeVC = (CAAccountViewController *)[nav.viewControllers firstObject];
    }
    
    if (sender.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        [darkModeController setPageStyle:1]; //Pass 1 to change to YouTube's built-in dark mode
        [rootCercubeVC dismissViewControllerAnimated:YES completion:nil]; //Compatibility with CercubeDarkMode
        //Cercube's menus do not change to light/dark mode immediately, so we have to dismiss the root Cercube VC for changes to take effect
    }
    else if (sender.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        [darkModeController setPageStyle:0]; //Pass 0 to change to YouTube's built-in light mode
        [rootCercubeVC dismissViewControllerAnimated:YES completion:nil];
    }
}

%hook UIViewController
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection { //This method is called when the user toggles iOS 13's dark mode
    %orig;
    syncAppearance(self);
}
%end

%hook YTAppDelegate //Tells YouTube to sync its appearance if the user toggled iOS 13's dark mode when YouTube was not open
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    %orig;
    syncAppearance(keyWindow().rootViewController);
    return %orig;
}
%end
