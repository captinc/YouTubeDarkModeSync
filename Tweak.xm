#import "Tweak.h"

%hook YTAppViewController
%property (strong) NSString *darkModeRespectsWhat;
- (void)viewDidLoad { //determine what "parent" to respect
    %orig;
    if (@available(iOS 13, *)) { //if on iOS 13 or newer, respect iOS 13's dark mode
        self.darkModeRespectsWhat = @"iOS13";
    }
    else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //if on iOS 12 or older and DarkModeToggle is installed, respect DarkModeToggle
        if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/DarkModeToggleCCAlert.dylib"]) {
            self.darkModeRespectsWhat = @"DarkModeToggle";
            [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(startYouTubeDarkModeSync) name:@"com.captinc.darkmodetoggle.toggled" object:nil];
        }
        //but if DarkModeToggle is not installed and Noctis12 is, respect Noctis12
        else if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis12.dylib"]) {
            self.darkModeRespectsWhat = @"Noctis12";
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startYouTubeDarkModeSync) name:@"com.laughingquoll.noctis.darkModeChanged" object:nil];
        }
        else {
            self.darkModeRespectsWhat = @"None";
        }
    }
    [self startYouTubeDarkModeSync]; //ensure the appearance is synced even if dark mode was toggled when YouTube wasn't open
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    %orig;
}
%new
- (void)startYouTubeDarkModeSync { //match YouTube's appearance to the current state of what "parent" to respect
    if (@available(iOS 13, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self changeToDarkOrLightMode:1];
        }
        else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            [self changeToDarkOrLightMode:0];
        }
    }
    else {
        if ([self.darkModeRespectsWhat isEqualToString:@"DarkModeToggle"]) {
            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.captinc.darkmodetoggle.plist"];
            NSString *state = [prefs objectForKey:@"darkModeState"];
            if (!state) {
                state = @"light";
            }

            if ([state isEqualToString:@"dark"]) {
                [self changeToDarkOrLightMode:1];
            }
            else if ([state isEqualToString:@"light"]) {
                [self changeToDarkOrLightMode:0];
            }
        }
        else if ([self.darkModeRespectsWhat isEqualToString:@"Noctis12"]) {
            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctis12prefs.settings.plist"];
            BOOL state = [(NSNumber *)[prefs objectForKey:@"enabled"] boolValue];

            if (state) {
                [self changeToDarkOrLightMode:1];
            }
            else {
                [self changeToDarkOrLightMode:0];
            }
        }
    }
}
%new
- (void)changeToDarkOrLightMode:(NSInteger)newMode {
    YTPageStyleController *darkModeController = MSHookIvar<YTPageStyleController *>(self, "_pageStyleController"); //YTPageStyleController is an ivar of YTAppViewController, not an @property
    [darkModeController setPageStyle:newMode]; //pass 1 to change to YouTube's built-in dark mode. pass 0 to change to light mode
    
    //compatibility with CercubeDarkMode
    CAAccountViewController *rootCercubeVC;
    if ([self.childModalViewController isKindOfClass:%c(CANavigationViewController)]) {
        CANavigationViewController *nav = (CANavigationViewController *)self.childModalViewController;
        rootCercubeVC = (CAAccountViewController *)[nav.viewControllers firstObject];
    }
    if (rootCercubeVC) { //nil check to prevent crashes
        [rootCercubeVC dismissViewControllerAnimated:YES completion:nil]; //must dismiss the root Cercube VC in order to make Cercube update its appearance
    }
}
%end

%hook YTMainWindow
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection { //this method is called when iOS 13's dark mode is toggled
    %orig;
    YTAppDelegate *delegate = (YTAppDelegate *)[[UIApplication sharedApplication] delegate];
    [(YTAppViewController *)delegate.window.rootViewController startYouTubeDarkModeSync];
}
%end
