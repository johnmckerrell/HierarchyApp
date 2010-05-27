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
    
    // The currently applied filters
    currentFilters = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *splashFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Splash.png"];    

    NSLog(@"splashFile=%@", splashFile);
    
    if ([fileManager fileExistsAtPath:splashFile]) {
        // Load the splash view
        UIImage *splashImage = [UIImage imageWithContentsOfFile:splashFile];
        splashView = [[[UIImageView alloc] initWithFrame:window.frame] autorelease];
        splashView.image = splashImage;
                       
        NSLog(@"Loading the splash screen");
        [window addSubview:splashView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(slideSplashScreenOut) userInfo:nil repeats:NO];
    } else {
        // Add the navigation view to the window
        NSLog(@"Loading the navigation view");
        [window addSubview:self.navigationController.view];
    }


    // Set the filters to the default.
    [self setCategoryByName:nil];
    
    [window makeKeyAndVisible];
	
	return YES;
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

    NSLog(@"currentFilters now %@", currentFilters);
}
/*
-(BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [currentFilters removeLastObject];
    NSLog(@"currentFilters now %@", currentFilters);
    return YES;
}
 */
  
-(void) filterProperty:(NSString*)name value:(NSString*)value {
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

}

-(void) showItem:(NSDictionary*)itemData {
    id viewController;
    if ([itemData objectForKey:@"htmlfile"]) {
        viewController = [[[ItemWebViewController alloc] initWithItem:itemData] autorelease];
    } else {
        viewController = [[[ItemDetailViewController alloc] initWithItem:itemData] autorelease];
    }
    [self.navigationController pushViewController:viewController animated:YES];
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
