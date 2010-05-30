//
//  AppDelegate_Phone.m
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright MKE Computing Ltd 2010. All rights reserved.
//

#import "AppDelegate_Phone.h"
#import "ListViewController.h"
#import "ItemListViewController.h"
#import "ItemDetailViewController.h"
#import "ItemWebViewController.h"
#import "WebBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate_Phone

@synthesize window, navigationController;
@synthesize appdata, filtersdata, maindata;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch

    appdata = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"appdata.plist"]] retain];
    NSLog(@"appdata=%@",appdata);
    filtersdata = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"filtersdata.plist"]] retain];
    maindata = [[NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"maindata.plist"]] retain];
    
    NSDictionary *appearance = [appdata objectForKey:@"appearance"];
    if (appearance ) {
        if ([appearance objectForKey:@"navigationBarTint"]) {
            float red, blue, green, alpha;
            NSString *tintColor = [appearance objectForKey:@"navigationBarTint"];
            NSScanner *s = [NSScanner scannerWithString:tintColor];
            [s setCharactersToBeSkipped:
             [NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
            if ([s scanFloat:&red] && [s scanFloat:&green] && [s scanFloat:&blue] && [s scanFloat:&alpha] ) {
                self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            }
        }
    }
    //self.navigationController.navigationBar.tintColor = [UIColor c
    
    // The currently applied filters
    currentFilters = [[NSMutableArray alloc] init];
    
    // Set the start settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastRun = [userDefaults objectForKey:@"lastRun"];
    
    BOOL usingRecentSettings = NO;
    
    if (lastRun && [lastRun timeIntervalSinceNow] > -300) {
        // Restore
        NSString *startCategory =  [userDefaults objectForKey:@"startCategory"];
        [self setCategoryByName:startCategory];
        
        NSArray *startFilters = [userDefaults objectForKey:@"startFilters"];
        NSArray *oneFilter;
        BOOL oneValidFilter = NO;
        for (oneFilter in startFilters) {
            if (![self filterProperty:[oneFilter objectAtIndex:0] value:[oneFilter objectAtIndex:1] confirm:YES]) {
                // If this filter is no longer valid then don't look at following ones.
                break;
            }
            oneValidFilter = YES;
        }
        
        NSDictionary *startItem = [userDefaults objectForKey:@"startItem"];
        NSLog(@"startItem=%@", startItem);
        if (startItem) {
            [self showItem:startItem confirm:YES];
        }
        
        usingRecentSettings = YES;

    } else {
        [self setCategoryByName:nil];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *splashFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Splash.png"];        
    
    if (!usingRecentSettings && [fileManager fileExistsAtPath:splashFile]) {
        // Load the splash view
        UIImage *splashImage = [UIImage imageWithContentsOfFile:splashFile];
        splashView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, splashImage.size.width, splashImage.size.height)] autorelease];
        splashView.image = splashImage;
        
        NSLog(@"Loading the splash screen");
        [window addSubview:splashView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(slideSplashScreenOut) userInfo:nil repeats:NO];
    } else {
        // Add the navigation view to the window
        NSLog(@"Loading the navigation view");
        [window addSubview:self.navigationController.view];
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
    [window addSubview:self.navigationController.view];
    
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

-(NSDictionary*) getCategoryDataByName:(NSString*) category {
    NSArray *categories = [filtersdata objectForKey:@"categories"];
    NSDictionary *categoryData = nil, *searchCategoryData = nil;
    if (category) {
        for (searchCategoryData in categories) {
            if ([category isEqualToString:[searchCategoryData objectForKey:@"title"]]) {
                categoryData = searchCategoryData;
                break;
            }
        }
    } else {
        categoryData = [categories objectAtIndex:0];
    }
    return categoryData;
}

-(void) setCategoryByName:(NSString*) category {
    NSDictionary *categoryData = [self getCategoryDataByName:category];
    if (!categoryData) {
        // Bad data, do nothing
        NSLog(@"Incorrect category requested: %@", category);
        return;
    }

    categoryPathPosition = 0;
    [currentFilters removeAllObjects];
    if ([currentCategory isEqualToString:[categoryData objectForKey:@"title"]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        NSDictionary *firstFilter = [self getCurrentFilterAtPosition:0];
        
        NSLog(@"firstFilter=%@", firstFilter);
        // Create a ListViewController with
        //  displaying firstFilter
        //  filteredBy currentFilters
        ListViewController *viewController = [[[ListViewController alloc] initDisplaying:firstFilter data:maindata filteredBy:currentFilters] autorelease];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:viewController]];
        
        [currentCategory release];
        currentCategory = [[categoryData objectForKey:@"title"] retain];
    }
}

-(void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    categoryPathPosition = [self.navigationController.viewControllers count] - 1;
    while ([currentFilters count] > categoryPathPosition) {
        [currentFilters removeLastObject];
    }
    
    NSLog(@"[currentFilters count] = %i", [currentFilters count] );
    NSLog(@"categoryPathPosition = %i", categoryPathPosition );

    if (currentItem && [currentFilters count] == categoryPathPosition) {
        [currentItem release], currentItem = nil;
    }
    NSLog(@"currentFilters now %@", currentFilters);
    [self saveCurrentPosition];
}
/*
-(BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [currentFilters removeLastObject];
    NSLog(@"currentFilters now %@", currentFilters);
    return YES;
}
 */
  
-(void) saveCurrentPosition {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setObject:currentFilters forKey:@"startFilters"];
    [userDefaults setObject:currentCategory forKey:@"startCategory"];
    NSLog(@"currentItem = %@", currentItem);
    [userDefaults setObject:currentItem forKey:@"startItem"];
}

-(BOOL) filterProperty:(NSString*)name value:(NSString*)value confirm:(BOOL) confirm {
    if (confirm) {
        ListViewController *currentViewController = [self.navigationController.viewControllers lastObject];
        if (![currentViewController validFilterValue:value]) {
            return NO;
        }
    }
    NSLog(@"Should filter items with %@ = %@", name, value );
    [currentFilters addObject:[NSArray arrayWithObjects:name, value, nil]];
    
    // Advance to next path position
    ++categoryPathPosition;
    NSDictionary *currentFilter = [self getCurrentFilterAtPosition:categoryPathPosition];
    
    if (currentFilter) {
        ListViewController *viewController = [[[ListViewController alloc] initDisplaying:currentFilter data:maindata filteredBy:currentFilters] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        // Show a list of items
        ItemListViewController *viewController = [[[ItemListViewController alloc] 
                                                   initDisplaying:[appdata objectForKey:@"itemData"] 
                                                   data:maindata
                                                   filteredBy:currentFilters] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    return YES;
}

-(BOOL) showItem:(NSDictionary*)itemData confirm:(BOOL) confirm {
    if (confirm) {
        ItemListViewController *currentViewController = [self.navigationController.viewControllers lastObject];
        if (![currentViewController validItem:itemData]) {
            return NO;
        }
    }
    id viewController;
    if ([itemData objectForKey:@"htmlfile"] || [itemData objectForKey:@"url"]) {
        viewController = [[[ItemWebViewController alloc] initWithItem:itemData] autorelease];
    } else {
        viewController = [[[ItemDetailViewController alloc] initWithItem:itemData] autorelease];
    }
    currentItem = [itemData retain];
    [self.navigationController pushViewController:viewController animated:YES];
    return YES;
}

-(void) loadURLRequestInLocalBrowser:(NSURLRequest*) request {
    WebBrowserViewController *viewController;
    viewController = [[[WebBrowserViewController alloc] initWithRequest:request] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(NSDictionary*) getCurrentFilterAtPosition:(NSUInteger)position {
    NSDictionary *categoryData = [self getCategoryDataByName:currentCategory];

    NSDictionary *filters = [filtersdata objectForKey:@"filters"];
    
    NSArray *categoryPath =[categoryData objectForKey:@"path"];
    if (position >= [categoryPath count]) {
        return nil;
    }
    NSString *filterName = [categoryPath objectAtIndex:position];
    return [filters objectForKey:filterName];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
