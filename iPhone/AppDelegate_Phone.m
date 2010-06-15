//
//  AppDelegate_Phone.m
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright MKE Computing Ltd 2010. All rights reserved.
//

#import "AppDelegate_Phone.h"

#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate_Phone

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch

    NSDictionary *appdata = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"appdata.plist"]];
    NSLog(@"appdata=%@",appdata);
    NSDictionary *filtersdata = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"filtersdata.plist"]];
    NSArray *maindata = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"maindata.plist"]];

    // Set the start settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastRun = [userDefaults objectForKey:@"lastRun"];
    
    BOOL usingRecentSettings = NO;
 
    hierarchyController = [[HierarchyViewController alloc] initWithAppData:appdata filtersData:filtersdata mainData:maindata];

    if (lastRun && [lastRun timeIntervalSinceNow] > -300) {
        // Restore
        hierarchyController.startCategory = [userDefaults objectForKey:@"startCategory"];
        hierarchyController.startFilters = [userDefaults objectForKey:@"startFilters"];
        hierarchyController.startItem = [userDefaults objectForKey:@"startItem"];
        usingRecentSettings = YES;

    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *splashFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Splash.png"];
    NSString *defaultFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Default.png"];
    if (![fileManager fileExistsAtPath:splashFile]) {
        splashFile = nil;
    }
    if (![fileManager fileExistsAtPath:defaultFile]) {
        defaultFile = nil;
    }

    NSLog(@"splashFile=%@:defaultFile=%@", splashFile, defaultFile);

    if ( ( splashFile && ! usingRecentSettings ) || defaultFile ) {
        // Load the splash view
        UIImage *splashImage;
        if (splashFile && ! usingRecentSettings) {
            splashImage = [UIImage imageWithContentsOfFile:splashFile];
        } else {
            splashImage = [UIImage imageWithContentsOfFile:defaultFile];
        }

        splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, splashImage.size.width, splashImage.size.height)];
        splashView.image = splashImage;
        
        NSLog(@"Loading the splash screen");
        [window addSubview:splashView];
        if (splashFile && ! usingRecentSettings) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(slideSplashScreenOut) userInfo:nil repeats:NO];
        } else {
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(slideSplashScreenOut) userInfo:nil repeats:NO];
        }

    } else {
        // Add the navigation view to the window
        NSLog(@"Loading the navigation view");
        [window addSubview:hierarchyController.view];
    }    
    
    [window makeKeyAndVisible];
	
	return YES;
}

-(void)applicationWillTerminate:(UIApplication *)application {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSDate date] forKey:@"lastRun"];    
}

-(void)slideSplashScreenOut {
    [splashView removeFromSuperview];
    [window addSubview:hierarchyController.view];
    
    // set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[window layer] addAnimation:animation forKey:@"SwitchToNavView"];
    
    
    /*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimatio forView:window cache:YES];
    [UIView setAnimationDelegate:self];
    [splashView removeFromSuperview];
    [window addSubview:self.navigationController.view];
    [UIView commitAnimations];
     */
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
