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

@synthesize window, navigationController, tabBarController, currentFilters, tintColor;
@synthesize appdata, filtersdata, maindata;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch

    appdata = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"appdata.plist"]] retain];
    NSLog(@"appdata=%@",appdata);
    filtersdata = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"filtersdata.plist"]] retain];
    maindata = [[NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"maindata.plist"]] retain];

    // Retrieve the tint color for nav bars if we have one
    NSDictionary *appearance = [appdata objectForKey:@"appearance"];
    if (appearance ) {
        if ([appearance objectForKey:@"navigationBarTint"]) {
            float red, blue, green, alpha;
            NSScanner *s = [NSScanner scannerWithString:[appearance objectForKey:@"navigationBarTint"]];
            [s setCharactersToBeSkipped:
             [NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
            if ([s scanFloat:&red] && [s scanFloat:&green] && [s scanFloat:&blue] && [s scanFloat:&alpha] ) {
                tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            }
        }
    }
    
    
    // Create an array to hold the filtered data
    filteredData = [[NSMutableArray alloc] initWithCapacity:[maindata count]];
    
    //self.navigationController.navigationBar.tintColor = [UIColor c
    
    // The currently applied filters
    currentFilters = [[NSMutableArray alloc] init];
    ignoredFilters = [[NSMutableArray alloc] init];
    
    // Set the start settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastRun = [userDefaults objectForKey:@"lastRun"];
    
    BOOL usingRecentSettings = NO;
 
    

    if (lastRun && [lastRun timeIntervalSinceNow] > -300) {
        // Restore
        NSString *startCategory =  [userDefaults objectForKey:@"startCategory"];
        [self setupTabBarWithInitialCategory:startCategory];
        [self setCategoryByName:startCategory];
        
        NSArray *startFilters = [userDefaults objectForKey:@"startFilters"];
        NSLog(@"startFilters=%@", startFilters);
        NSArray *oneFilter;
        BOOL oneValidFilter = NO;
        for (oneFilter in startFilters) {
            if (![self filterProperty:[oneFilter objectAtIndex:0] value:[oneFilter objectAtIndex:1] fromSave:YES]) {
                // If this filter is no longer valid then don't look at following ones.
                break;
            }
            oneValidFilter = YES;
        }
        
        NSDictionary *startItem = [userDefaults objectForKey:@"startItem"];
        NSLog(@"startItem=%@", startItem);
        if (startItem) {
            [self showItem:startItem fromSave:YES];
        }
        
        usingRecentSettings = YES;

    } else {
        [self setupTabBarWithInitialCategory:nil];
        [self setCategoryByName:nil];
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
        [window addSubview:self.tabBarController.view];
    }    
    
    [window makeKeyAndVisible];
	
	return YES;
}

-(void)setupTabBarWithInitialCategory:(NSString*)initialCategory {    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    NSArray *categories = [filtersdata objectForKey:@"categories"];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:([categories count]+1)];
    NSDictionary *categoryData;
    NSString *iconFile;
    UIImage *icon;
    UINavigationController *navController;
    UITabBarItem *tabBarItem;
    NSUInteger selected = 0, i = 0, l = [categories count];
    for (;i < l; ++i) {
        categoryData = [categories objectAtIndex:i];
        iconFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: [categoryData objectForKey:@"icon"]];
        icon = [UIImage imageWithContentsOfFile:iconFile];
        NSLog(@"icon %@ gave %@", iconFile, icon );

        navController = [[[UINavigationController alloc] init] autorelease];
        navController.delegate = self;
        if (self.tintColor) {
            navController.navigationBar.tintColor = tintColor;
        }
        tabBarItem = [[[UITabBarItem alloc] initWithTitle:[categoryData objectForKey:@"title"] image:icon tag:i] autorelease];
        navController.tabBarItem = tabBarItem;
        [viewControllers addObject:navController];
        
        if ([initialCategory isEqualToString:[categoryData objectForKey:@"title"]]) {
            selected = i;
        }
    }
    
    NSDictionary *itemDescription = [appdata objectForKey:@"itemData"];
    if ([@"YES" isEqualToString:[itemDescription objectForKey:@"canAppearAsCategory"]]) {
        iconFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: [itemDescription objectForKey:@"categoryIcon"]];
        icon = [UIImage imageWithContentsOfFile:iconFile];
        NSLog(@"icon %@ gave %@", iconFile, icon );
        
        navController = [[[UINavigationController alloc] init] autorelease];
        navController.delegate = self;
        if (self.tintColor) {
            navController.navigationBar.tintColor = tintColor;
        }        
        tabBarItem = [[[UITabBarItem alloc] initWithTitle:[itemDescription objectForKey:@"title"] image:icon tag:i] autorelease];
        navController.tabBarItem = tabBarItem;
        [viewControllers addObject:navController];        

        if ([initialCategory isEqualToString:[itemDescription objectForKey:@"title"]]) {
            selected = i;
        }
    }
    
    [tabBarController setViewControllers:viewControllers];
    tabBarController.selectedIndex = selected;
    self.navigationController = (UINavigationController*)tabBarController.selectedViewController;
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.navigationController = (UINavigationController*)viewController;
    NSLog(@"selected %@", viewController);
    NSLog(@"viewController.tag = %i", viewController.tabBarItem.tag);
    NSLog(@"viewController count = %i", [self.navigationController.viewControllers count]);
    [self setCategoryByName:viewController.tabBarItem.title];
    NSLog(@"viewController count = %i", [self.navigationController.viewControllers count]);
}

-(void)filterData {
    if ([currentFilters count] == 0) {
        [filteredData setArray:maindata];
        return;
    }
    NSDictionary *itemData, *itemProperties;
    NSArray *filter;
    NSString *testValue;
    BOOL match;
    [filteredData removeAllObjects];
    for (itemData in maindata) {
        match = YES;
        itemProperties = [itemData objectForKey:@"properties"];
        
        for (filter in currentFilters) {
            testValue = [itemProperties objectForKey:[filter objectAtIndex:0]];
            if (![testValue isEqualToString:[filter objectAtIndex:1]]) {
                match = NO;
                break;
            }
        }
        
        if (match) {
            [filteredData addObject:itemData];
        }
    }
}

-(void)filterDataWhereProperty:(NSString*)property hasValue:(NSString*)value {
    NSUInteger i, count = [filteredData count];
    NSDictionary *itemData, *itemProperties;
    for (i = 0; i < count; ) {
        itemData = [filteredData objectAtIndex:i];
        itemProperties = [itemData objectForKey:@"properties"];
        if ([value isEqualToString:[itemProperties objectForKey:property]]) {
            ++i;
        } else {
            [filteredData removeObjectAtIndex:i];
            --count;
        }
    }
}

-(void)applicationWillTerminate:(UIApplication *)application {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSDate date] forKey:@"lastRun"];    
}

-(void)slideSplashScreenOut {
    [splashView removeFromSuperview];
    [window addSubview:self.tabBarController.view];
    
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
    NSDictionary *itemDescription = [appdata objectForKey:@"itemData"];
    if ([category isEqualToString:[itemDescription objectForKey:@"title"]]) {
        return itemDescription;
    }
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
    [self filterData];
    if ([currentCategory isEqualToString:[categoryData objectForKey:@"title"]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [currentCategory release];
        currentCategory = [[categoryData objectForKey:@"title"] retain];
        NSDictionary *currentFilter = [self getCurrentFilterAtPosition:categoryPathPosition];

        id viewController;
        if (currentFilter) {
            NSArray *headings = [self filterHeadings:currentFilter];
            viewController = [[[ListViewController alloc] initDisplaying:currentFilter data:headings] autorelease];
        } else {
            // Show a list of items
            viewController = [[[ItemListViewController alloc] 
                                                       initDisplaying:[appdata objectForKey:@"itemData"] 
                                                       data:filteredData] autorelease];
        }
        [self.navigationController setViewControllers:[NSArray arrayWithObject:viewController]];        
    }
}

-(NSArray*)filterDataForSearchTerm:(NSString*)string usingFilters:(BOOL)useFilters {
    NSArray *searchData;
    if (useFilters) {
        searchData = filteredData;
    } else {
        searchData = maindata;
    }
    NSArray *filters = [filtersdata objectForKey:@"filters"];
    NSDictionary *itemDescription = [appdata objectForKey:@"itemData"];
    NSMutableArray *itemResults = [NSMutableArray arrayWithCapacity:[searchData count]];
    NSMutableDictionary *filterResults = [NSMutableArray arrayWithCapacity:[filters count]];
    
    
    NSDictionary *itemData;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self like[cd] %@)", [NSString stringWithFormat:@"*%@*", string]];
    for (itemData in searchData) {
        NSString *title = [itemData objectForKey:@"title"];
        NSLog(@"Checking %@", title);
        if ([predicate evaluateWithObject:title]) {
            NSLog(@"MATCH - %@", title);
            [itemResults addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, itemData, nil]
                                                               forKeys:[NSArray arrayWithObjects:@"title", @"itemData", nil]]
             ];
        }
    }
    
    
    
    NSUInteger resultsCapacity = [filterResults count];
    if ([itemResults count]) {
        ++resultsCapacity;
    }
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:resultsCapacity];
    if ([itemResults count]) {
        [results addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[itemDescription objectForKey:@"title"], itemResults, nil]
                                                       forKeys:[NSArray arrayWithObjects:@"type", @"results", nil]]];
    }
    //[results addObjectsFromArray:[filterResults allValues]];
    
    NSLog(@"returning results=%@", results);
    return results;
}

/**
 * This function may be called whether we're going forwards or backwards
 * in a hierarchy. If we're going forwards then everything should add up
 * fine and we won't do anything, if we're going backwards then
 * categoryPathPosition should end up "too big" and we'll know that we
 * need to remove filters until we match the number of viewcontrollers
 * that are visible. Couldn't think of a better way of detecting that we
 * had gone backwards through the hierarchy.
 */
-(void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL modifiedFilters = NO;
    // The number of navigation controllers will be less if we've ignored filters
    // so we need to add their count on here
    categoryPathPosition = ([self.navigationController.viewControllers count] - 1) + [ignoredFilters count];
    
    // Whereas currentFilters still has the ignoredFilters included so should be "right"
    while ([currentFilters count] > categoryPathPosition) {
        NSArray *removingFilter = [currentFilters lastObject];
        NSDictionary *lastIgnoredFilter = [ignoredFilters lastObject];
        
        // Now check if the filter we just removed was one that we were ignoring anyway, if it
        // was then we'll need to remove the next one too.
        NSString *removedFilterProperty = [removingFilter objectAtIndex:0];
        NSLog(@"removedFilterProperty=%@:lastIgnoredFilter=%@", removedFilterProperty, [lastIgnoredFilter objectForKey:@"property"] );
        if ([removedFilterProperty isEqualToString:[lastIgnoredFilter objectForKey:@"property"]]) {
            NSLog(@"IGNORED FILTER");
            [ignoredFilters removeLastObject];
            --categoryPathPosition;
        }
        [currentFilters removeLastObject];
        modifiedFilters = YES;
    }
    
    if (modifiedFilters) {
        [self filterData];
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

    NSLog(@"saving currentFilters as %@", currentFilters);
    [userDefaults setObject:currentFilters forKey:@"startFilters"];
    [userDefaults setObject:currentCategory forKey:@"startCategory"];
    NSLog(@"currentItem = %@", currentItem);
    [userDefaults setObject:currentItem forKey:@"startItem"];
}

-(BOOL) filterProperty:(NSString*)name value:(NSString*)value fromSave:(BOOL) fromSave {
    if (fromSave) {
        NSDictionary *itemData;
        BOOL match = NO;
        for (itemData in filteredData) {
            if ([value isEqualToString:[[itemData objectForKey:@"properties"] objectForKey:name]]) {
                match = YES;
            }
        }
        if (!match) {
            return NO;
        }
    }
    NSLog(@"Should filter items with %@ = %@", name, value );
    [currentFilters addObject:[NSArray arrayWithObjects:name, value, nil]];
    [self filterDataWhereProperty:name hasValue:value];
    
    // Advance to next path position
    ++categoryPathPosition;
    NSDictionary *currentFilter = [self getCurrentFilterAtPosition:categoryPathPosition];
    
    if (currentFilter) {
        NSArray *headings = [self filterHeadings:currentFilter];
        if ( [headings count] == 1
            && [@"YES" isEqualToString:[currentFilter objectForKey:@"skipSingleEntry"] ]) {
            NSLog(@"skipping %@ because everything has the value %@", [currentFilter objectForKey:@"property"], [headings objectAtIndex:0] );
            [ignoredFilters addObject:currentFilter];
            // If we're restoring from a saved position then we will have already saved the skip and doing it here
            // will result in a duplicated filter
            if (fromSave) {
                return YES;
            }
            // Skip onto the next filter
            return [self filterProperty:[currentFilter objectForKey:@"property"] value:[headings objectAtIndex:0] fromSave:NO];
        }
        ListViewController *viewController = [[[ListViewController alloc] initDisplaying:currentFilter data:headings] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        // Show a list of items
        ItemListViewController *viewController = [[[ItemListViewController alloc] 
                                                   initDisplaying:[appdata objectForKey:@"itemData"] 
                                                   data:filteredData] autorelease];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    return YES;
}

-(NSArray*) filterHeadings:(NSDictionary *)filter {
    NSMutableDictionary *tableHash = [NSMutableDictionary dictionaryWithCapacity:[filteredData count]];
    NSDictionary *itemData, *itemProperties;
    NSString *itemName;
    for (itemData in filteredData) {
        itemProperties = [itemData objectForKey:@"properties"];
        itemName = [itemProperties objectForKey:[filter objectForKey:@"property"]];
        if (![tableHash objectForKey:itemName]) {
            [tableHash setObject:itemName forKey:itemName];
        }
    }
    return [[tableHash allKeys] sortedArrayUsingDescriptors:
                  [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES] autorelease]]
                  ];
}

-(BOOL) showItem:(NSDictionary*)itemData fromSave:(BOOL) fromSave {
    if (fromSave) {
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
    NSLog(@"toolbar=%@", viewController.toolbar);
    viewController.toolbar.tintColor = tintColor;
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
