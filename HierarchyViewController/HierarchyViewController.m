    //
//  HierarchyViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 15/06/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "HierarchyViewController.h"
#import "ListViewController.h"
#import "ItemListViewController.h"
#import "ItemDetailViewController.h"
#import "ItemWebViewController.h"
#import "WebBrowserViewController.h"

@implementation HierarchyViewController

@synthesize startCategory, startFilters, startItem, extraFilters, leftMostItem, rightBarButtonItem, selectModeNavigationItem, extraViewControllers;
@synthesize filteredData, tabBarController, currentCategory, currentFilters, currentItem, tintColor;
@synthesize appdata, filtersdata, maindata;

- (id)initWithAppData:(NSDictionary*)_appdata filtersData:(NSDictionary*)_filtersdata mainData:(NSArray*)_maindata {
    if ((self == [super init])) {
        appdata = [_appdata retain];
        filtersdata = [_filtersdata retain];
        maindata = [_maindata retain];
        
        // Retrieve the tint color for nav bars if we have one
        NSDictionary *appearance = [appdata objectForKey:@"appearance"];
        if (appearance ) {
            if ([appearance objectForKey:@"navigationBarTint"]) {
                float red, blue, green, alpha;
                NSScanner *s = [NSScanner scannerWithString:[appearance objectForKey:@"navigationBarTint"]];
                [s setCharactersToBeSkipped:
                 [NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
                if ([s scanFloat:&red] && [s scanFloat:&green] && [s scanFloat:&blue] && [s scanFloat:&alpha] ) {
                    tintColor = [[UIColor colorWithRed:red green:green blue:blue alpha:alpha] retain];
                }
            }
        }
        
        // Create an array to hold the filtered data
        filteredData = [[NSMutableArray alloc] initWithCapacity:[maindata count]];
        
        // The currently applied filters
        currentFilters = [[NSMutableArray alloc] init];
        ignoredFilters = [[NSMutableArray alloc] init];
        extraFilters = [[NSArray array] retain];
        selectModeNavigationItem = [[UINavigationItem alloc] init];
        
        
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    // Create the tab bar showing the right category
    [self setupTabBarWithInitialCategory:self.startCategory];
    [self setCurrentCategory:self.startCategory filters:self.startFilters item:self.startItem];
    self.view = tabBarController.view;
}

-(void) setCurrentCategory:(NSString*)_category filters:(NSArray*) _filters item:(NSDictionary*)_itemData {
    // This is needed to prepare the headings correctly
    [self setCategoryByName:_category];
    
    NSLog(@"startFilters=%@", _filters);
    NSArray *oneFilter;
    BOOL oneValidFilter = NO;
    for (oneFilter in _filters) {
        if (![self filterProperty:[oneFilter objectAtIndex:0] value:[oneFilter objectAtIndex:1] fromSave:YES]) {
            // If this filter is no longer valid then don't look at following ones.
            break;
        }
        oneValidFilter = YES;
    }
    
    NSLog(@"startItem=%@", _itemData);
    if (oneValidFilter && _itemData) {
        [self showItem:_itemData fromSave:YES];
    }
    
}

-(BOOL) filter:(NSDictionary*)aFilterData isEqualTo:(NSDictionary*)bFilterData {
    return [[aFilterData objectForKey:@"property"] isEqualToString:[bFilterData objectForKey:@"property"]];
}

-(void) updateData:(NSArray*)_data {
    if (_data == maindata) {
        // Do nothing, assume we just need to re-filter
    } else {
        [maindata release];
        maindata = [_data retain];
    }
    //NSString *oldCurrentCategory = currentCategory;
    if (currentCategory) {
        UINavigationController *navController = ((UINavigationController*)tabBarController.selectedViewController);
        // Need to do this or it won't update the data
        
        NSLog(@"Clearing out old data");
        // Copy the initial filters
        NSArray *oldFilters = [[currentFilters copy] autorelease];
        NSMutableArray *oldIgnored = [[ignoredFilters mutableCopy] autorelease];
        
        // Empty the current filters
        [currentFilters removeAllObjects];
        [ignoredFilters removeAllObjects];
        
        // Filter the data (i.e. to be unfiltered)
        [self filterData];
        
        NSDictionary *currentFilter = nil;
        NSArray *headings = nil;
        // Update the data on the first view controller
        ListViewController *viewController = [navController.viewControllers objectAtIndex:0];
        if ([viewController isKindOfClass:[ItemListViewController class]]) {
            NSLog(@"showing all items");
            [((ItemListViewController*) viewController) updateData:filteredData];
        } else {
            currentFilter = [self getCurrentFilterAtPosition:0];
            NSLog(@"Showing first filter: %@", currentFilter);
            if (currentFilter) {
                headings = [self filterHeadings:currentFilter];
                [viewController updateData:headings forFilter:currentFilter];
            }
        }
        viewController.navigationItem.rightBarButtonItem = self.rightBarButtonItem;

        
        // Go through the filters
        NSUInteger i, count = [oldFilters count];
        BOOL ignoredLast = NO;
        for (i = 0; i < count; i++) {
            NSArray * filter = [oldFilters objectAtIndex:i];
                    
            NSLog(@"filtering data with filter: %@", filter);
            // Filter the data
            [self filterDataWhereProperty:[filter objectAtIndex:0] hasValue:[filter objectAtIndex:1]];
        
            if ([filteredData count] == 0) {
                --i;
                // Filter again without the last filter
                [self filterData];
                NSLog(@"breaking because there was no match");
                break;
            }
            // Set the filter
            [currentFilters addObject:filter];

            currentFilter = [self getCurrentFilterAtPosition:i+1];
            
            NSLog(@"filter for %i is %@ ", i, currentFilter);
            
            if (currentFilter) {
                // Retrieve the headings
                headings = [self filterHeadings:currentFilter];
            
                // If there's only one, ignore this filter
                if ( [headings count] == 1
                    && [@"YES" isEqualToString:[currentFilter objectForKey:@"skipSingleEntry"] ]) {
                    if ([oldIgnored count] && [self filter:[oldIgnored objectAtIndex:0] isEqualTo:currentFilter]) {
                        [oldIgnored removeObjectAtIndex:0];
                    } else {
                        NSMutableArray *newControllers = [navController.viewControllers mutableCopy];
                        [newControllers removeObjectAtIndex:(i+1)-[ignoredFilters count]];
                        [navController setViewControllers:newControllers animated:NO];
                        [newControllers release];
                    }

                    [ignoredFilters addObject:currentFilter];
                    ignoredLast = YES;
                    continue;
                } else if ([oldIgnored count] && [self filter:[oldIgnored objectAtIndex:0] isEqualTo:currentFilter]) {
                    // We must have ignored this last time but don't want to this time
                    ListViewController *viewController = [ListViewController viewControllerDisplaying:currentFilter data:headings];
                    NSMutableArray *newControllers = [NSMutableArray arrayWithCapacity:([navController.viewControllers count]+1)];
                    NSUInteger ip1 = i+1, j = 0, jl = [navController.viewControllers count] + 1;
                    for (; j < jl; ++j) {
                        if (j < ip1) {
                            [newControllers addObject:[navController.viewControllers objectAtIndex:j]];
                        } else if (j > ip1) {
                            [newControllers addObject:[navController.viewControllers objectAtIndex:j-1]];
                        } else {
                            [newControllers addObject:viewController];
                        }
                    }
                    viewController.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
                    [navController setViewControllers:newControllers animated:NO];
                } else {
                // Otherwise update the data on the view controller
                    ListViewController *viewController = [navController.viewControllers objectAtIndex:(i+1)-[ignoredFilters count]];
                    if ([viewController isKindOfClass:[ItemListViewController class]]) {
                        NSLog(@"breaking because got an itemlist when expecting normal list: %@", viewController);
                        break;
                    }
                    if (![viewController updateData:headings forFilter:currentFilter]) {
                        NSLog(@"update failed");
                        break;
                    }
                    viewController.navigationItem.rightBarButtonItem = self.rightBarButtonItem;

                }
            } else if (i == ([currentFilters count] - 1)) {
                // Should be showing an item list
                id viewController = [navController.viewControllers objectAtIndex:(i+1)-[ignoredFilters count]];
                if (![viewController isKindOfClass:[ItemListViewController class]]) {
                    NSLog(@"breaking because didn't get an item list when expecting one: %@", viewController);
                    break;
                }
                [((ItemListViewController*) viewController) updateData:filteredData];
                ((ItemListViewController*) viewController).navigationItem.rightBarButtonItem = self.rightBarButtonItem;

            } else if (i == ([currentFilters count]) && currentItem) {
                // Check that the currently selected item is still valid?
                NSDictionary *itemData;
                BOOL match = NO;
                for (itemData in filteredData) {
                    if ([[itemData objectForKey:@"id"] isEqualToString:[currentItem objectForKey:@"id"]]) {
                        match = YES;
                        break;
                    }
                }
                if (!match) {
                    NSLog(@"breaking because current item is no longer valid: %@", currentItem);
                    break;
                }
            } else {
                NSLog(@"breaking because we're at the end of the filters and there's no current item");
                break;
            }

            ignoredLast = NO;
        }
        
        // Get rid of any other view controllers
        NSLog(@"i=%i", i);
        NSLog(@"ignored=%i", [ignoredFilters count]);
        NSLog(@"count=%i", [navController.viewControllers count]);
        NSUInteger numFilters = (i+1) - [ignoredFilters count];
        if (numFilters < 1) {
            numFilters = 1;
        }
        while ([navController.viewControllers count] > numFilters) {
            NSLog(@"popping a view controller");
            NSLog(@"count=%i", [navController.viewControllers count]);
            [navController popViewControllerAnimated:NO];
        }
        
        if (ignoredLast) {
            [self filterProperty:[currentFilter objectForKey:@"property"] value:[headings objectAtIndex:0] fromSave:NO];
        }
                          
                          
                          /*
        currentCategory = nil;
        NSArray *scrollPositions = [NSMutableArray arrayWithCapacity:[self.navigationController.viewControllers count]];
        UIViewController *viewController;
        for (viewController in self.navigationController.viewControllers) {
            if (![viewController isKindOfClass:[ListViewController class]]) {
                break;
            }
            
        }
        
        NSArray *filters = [currentFilters copy];
        [self setCurrentCategory:oldCurrentCategory filters:filters item:currentItem];
        [filters release];
         */
    }
}

-(void) startSelectMode {
    NSLog(@"Editing");
    ListViewController *visibleController = [((UINavigationController*)tabBarController.selectedViewController).viewControllers lastObject];
    [visibleController setSelecting:YES];
}

-(void) stopSelectMode {
    ListViewController *visibleController = [((UINavigationController*)tabBarController.selectedViewController).viewControllers lastObject];
    [visibleController setSelecting:NO];
}

-(NSArray*) selectedData {
    ListViewController *visibleController = [((UINavigationController*)tabBarController.selectedViewController).viewControllers lastObject];
    NSDictionary *filter = visibleController.displayFilter;
    NSDictionary *itemData, *itemProperties;
    NSArray *selections = [visibleController selectedData];
    id filterProperty;
    NSString *selectedValue;
    NSMutableArray *selectedData = [NSMutableArray arrayWithCapacity:[filteredData count]];
    
    // The item list returns all we need anyway.
    if ([visibleController isKindOfClass:[ItemListViewController class]]) {
        return selections;
    }
    
    for (itemData in filteredData) {
        itemProperties = [itemData objectForKey:@"properties"];
        BOOL match = NO;
        for (selectedValue in selections) {
            if (filter) {                
                filterProperty = [filter objectForKey:@"property"];
                if ([self property:[itemProperties objectForKey:filterProperty] matchesValue:selectedValue]) {
                    match = YES;
                    break;
                }
            } else {
                if ([selectedValue isEqualToString:[itemData objectForKey:@"title"]]) {
                    match = YES;
                    break;
                }
            }
        }
        if (match) {
            [selectedData addObject:itemData];
        }
    }
    return selectedData;
}

-(void)setupTabBarWithInitialCategory:(NSString*)initialCategory {    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    NSArray *categories = [filtersdata objectForKey:@"categories"];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:([categories count]+1)];
    NSDictionary *categoryData;
    UIImage *icon;
    UINavigationController *navController;
    UITabBarItem *tabBarItem;
    BOOL doneMainItem = NO;
    NSUInteger selected = 0, i = 0, l = [categories count];
    for (;i < l; ++i) {
        categoryData = [categories objectAtIndex:i];
        icon = [UIImage imageNamed:[categoryData objectForKey:@"icon"]];
        
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
        if ([@"YES" isEqualToString:[categoryData objectForKey:@"mainItem"]]) {
            doneMainItem = YES;
        }
    }
    
    NSDictionary *itemDescription = [appdata objectForKey:@"itemData"];
    if (!doneMainItem && [@"YES" isEqualToString:[itemDescription objectForKey:@"canAppearAsCategory"]]) {
        icon = [UIImage imageNamed:[itemDescription objectForKey:@"categoryIcon"]];
        
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
    
    if (self.extraViewControllers) {
        [viewControllers addObjectsFromArray:self.extraViewControllers];
    }
    
    [tabBarController setViewControllers:viewControllers];
    tabBarController.selectedIndex = selected;
    //self.navigationController = (UINavigationController*)tabBarController.selectedViewController;
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    //self.navigationController = (UINavigationController*)viewController;
    NSLog(@"selected %@", viewController);
    NSLog(@"viewController.tag = %i", viewController.tabBarItem.tag);
    NSLog(@"viewController count = %i", [self.navigationController.viewControllers count]);
    if (self.extraViewControllers && [self.extraViewControllers indexOfObject:viewController] != NSNotFound) {
        // Don't want to set a category as this is nothing to do with the hierarchy controller.
        currentCategory = nil;
        return;
    }
    [self setCategoryByName:viewController.tabBarItem.title];
    NSLog(@"viewController count = %i", [self.navigationController.viewControllers count]);
}

-(BOOL)property:(id) property matchesValue:(NSString*) testString {
    if (testString == MATCH_ALL) {
        return YES;
    }
    if ([property isKindOfClass:[NSArray class]]) {
        NSString *propertyValue;
        for (propertyValue in property) {
            if ([testString isEqualToString:propertyValue]) {
                return YES;
            }
        }
        return NO;
    } else {
        return [testString isEqualToString:property];
    }
    
}

-(void)filterData {
    if ([currentFilters count] == 0 && [extraFilters count] == 0) {
        [filteredData setArray:maindata];
        return;
    }
    NSDictionary *itemData, *itemProperties;
    NSArray *allFilters, *filter;
    allFilters = [extraFilters arrayByAddingObjectsFromArray:currentFilters];
    id testValue;
    BOOL match;
    [filteredData removeAllObjects];
    for (itemData in maindata) {
        match = YES;
        itemProperties = [itemData objectForKey:@"properties"];
        
        for (filter in allFilters) {
            testValue = [itemProperties objectForKey:[filter objectAtIndex:0]];
            if (![self property:testValue matchesValue:[filter objectAtIndex:1]]) {
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
        if ([self property:[itemProperties objectForKey:property] matchesValue:value]) {
            ++i;
        } else {
            [filteredData removeObjectAtIndex:i];
            --count;
        }
    }
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
    [ignoredFilters removeAllObjects];
    [self filterData];
    if ([currentCategory isEqualToString:[categoryData objectForKey:@"title"]]) {
        [((UINavigationController*)tabBarController.selectedViewController) popToRootViewControllerAnimated:YES];
    } else {
        [currentCategory release];
        currentCategory = [[categoryData objectForKey:@"title"] retain];
        NSDictionary *currentFilter = [self getCurrentFilterAtPosition:categoryPathPosition];
        
        UIViewController *viewController;
        if (currentFilter) {
            NSArray *headings = [self filterHeadings:currentFilter];
            viewController = [ListViewController viewControllerDisplaying:currentFilter data:headings];
            ((ListViewController*)viewController).hierarchyController = self;
        } else {
            // Show a list of items
            viewController = [ItemListViewController viewControllerDisplaying:[appdata objectForKey:@"itemData"] data:filteredData];

            ((ItemListViewController*)viewController).hierarchyController = self;
        }
        if (self.leftMostItem) {
            viewController.navigationItem.leftBarButtonItem = self.leftMostItem;
        }
        if (self.rightBarButtonItem && ! viewController.navigationItem.rightBarButtonItem) {
            viewController.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
        }
        
        [((UINavigationController*)tabBarController.selectedViewController) setViewControllers:[NSArray arrayWithObject:viewController]];        
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self contains[cd] %@)", string];
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
    categoryPathPosition = ([navigationController.viewControllers count] - 1) + [ignoredFilters count];
    
    // Need this to make sure the list row is deselected
    [viewController viewWillAppear:animated];
    
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
    
    if ([viewController isKindOfClass:[ListViewController class]]|| !viewController.navigationItem.rightBarButtonItem) {
        if (!((ListViewController*)viewController).ignoreRightButton) {
            viewController.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
            NSLog(@"set right button");
        }
    }    
}
/*
 -(BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
 [currentFilters removeLastObject];
 NSLog(@"currentFilters now %@", currentFilters);
 return YES;
 }
 */

-(void) saveCurrentPosition {
    // FIXME - this should really be handled by a delegate
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
        NSDictionary *itemProperties;
        BOOL match = NO;
        for (itemData in filteredData) {
            itemProperties = [itemData objectForKey:@"properties"];
            if ([self property:[itemProperties objectForKey:name] matchesValue:value]) {
                match = YES;
                break;
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
    
    UIViewController *viewController;
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
        ListViewController *listViewController = [ListViewController viewControllerDisplaying:currentFilter data:headings];
        listViewController.hierarchyController = self;
        viewController = listViewController;
    } else {
        // Show a list of items
        ItemListViewController *itemViewController = [ItemListViewController viewControllerDisplaying:[appdata objectForKey:@"itemData"] data:filteredData];
        itemViewController.hierarchyController = self;
        viewController = itemViewController;
    }
    [((UINavigationController*)tabBarController.selectedViewController) pushViewController:viewController animated:!fromSave];
    return YES;
}

-(NSArray*) filterHeadings:(NSDictionary *)filter {
    NSMutableDictionary *tableHash = [NSMutableDictionary dictionaryWithCapacity:[filteredData count]];
    NSDictionary *itemData, *itemProperties;
    id propertyValue;
    NSString *itemName;
    for (itemData in filteredData) {
        itemProperties = [itemData objectForKey:@"properties"];
        propertyValue = [itemProperties objectForKey:[filter objectForKey:@"property"]];
        if ([propertyValue isKindOfClass:[NSArray class]]) {
            for (itemName in propertyValue) {
                if (![tableHash objectForKey:itemName]) {
                    [tableHash setObject:itemName forKey:itemName];
                }
            }
        } else if (![tableHash objectForKey:propertyValue]) {
            [tableHash setObject:propertyValue forKey:propertyValue];
        }
    }
    return [[tableHash allKeys] sortedArrayUsingDescriptors:
            [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES] autorelease]]
            ];
}

-(BOOL) showItem:(NSDictionary*)itemData fromSave:(BOOL) fromSave {
    if (fromSave) {
        NSDictionary *testItemData;
        NSString *itemID = [itemData objectForKey:@"id"];
        BOOL match = NO;
        for (testItemData in filteredData) {
            if ([itemID isEqualToString:[testItemData objectForKey:@"id"]]) {
                match = YES;
                break;
            }
        }
        if (!match) {
            return NO;
        }
    }
    
    
    NSString *viewControllerClassString = nil;
    Class viewControllerClass = nil;
    id viewController = nil;
    if ([itemData objectForKey:@"viewController"]) {
        viewControllerClassString = [itemData objectForKey:@"viewController"];
        viewControllerClass = NSClassFromString(viewControllerClassString);
        viewController = [viewControllerClass alloc];
        if ([viewController respondsToSelector:@selector(initWithItem:)]) {
            viewController = [viewController initWithItem:itemData];
        }
        if (viewController && [viewController respondsToSelector:@selector(setHierarchyController:)]) {
            [viewController setHierarchyController:self];
        }
    }
    if (!viewController) {
        NSDictionary *itemDataDescription = [self.appdata objectForKey:@"itemData"];
        if (itemDataDescription ) {
            viewControllerClassString = [itemDataDescription objectForKey:@"defaultViewController"];
        }
        if (viewControllerClassString) {
            viewControllerClass = NSClassFromString(viewControllerClassString);
        }
        viewController = [viewControllerClass alloc];
        if ([viewController respondsToSelector:@selector(initWithItem:)]) {
            viewController = [viewController initWithItem:itemData];
        }
        if (viewController && [viewController respondsToSelector:@selector(setHierarchyController:)]) {
            [viewController setHierarchyController:self];
        }
    }
    if (viewController) {
        // Do nothing, we're ready
    } else if ([itemData objectForKey:@"htmlfile"] || [itemData objectForKey:@"url"]) {
        viewController = [[ItemWebViewController alloc] initWithItem:itemData];
        ((ItemWebViewController*)viewController).hierarchyController = self;
    } else {
        viewController = [[ItemDetailViewController alloc] initWithItem:itemData];
        ((ItemDetailViewController*)viewController).hierarchyController = self;
    }
    currentItem = [itemData retain];
    [((UINavigationController*)tabBarController.selectedViewController) pushViewController:viewController animated:!fromSave];
    [viewController release];
    return YES;
}

-(void) loadURLRequestInLocalBrowser:(NSURLRequest*) request {
    WebBrowserViewController *viewController;
    viewController = [[[WebBrowserViewController alloc] initWithRequest:request] autorelease];
    [((UINavigationController*)tabBarController.selectedViewController) pushViewController:viewController animated:YES];
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





- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [extraFilters release], extraFilters = nil;
    
    [super dealloc];
}


@end
