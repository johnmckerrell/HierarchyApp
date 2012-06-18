//
//  ListViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "ListViewController.h"
#import "HierarchyViewController.h"

@implementation ListViewController

@synthesize tableData = _tableData;
@synthesize filteredData = _filteredData;
@synthesize selectedCells = _selectedCells;
@synthesize totalRowCount = _totalRowCount;
@synthesize viewLoaded = _viewLoaded;
@synthesize hierarchyController = _hierarchyController;
@synthesize displayFilter = _displayFilter;
@synthesize ignoreRightButton = _ignoreRightButton;
@synthesize searchController = _searchController;


#pragma mark -
#pragma mark Initialization

+(ListViewController*)viewControllerDisplaying:(NSDictionary*)displayFilter data:(NSArray*)data {
    NSString *cellViewClassString = nil;
    Class cellViewClass = nil;
    if (!cellViewClass && [displayFilter objectForKey:@"listViewController"]) {
        cellViewClassString = [displayFilter objectForKey:@"listViewController"];
        cellViewClass = NSClassFromString(cellViewClassString);
        [cellViewClass isKindOfClass:[ListViewController class]];
    }
    if (!cellViewClass) {
        cellViewClass = [ListViewController class];
    }
    
    ListViewController *viewController = [[cellViewClass alloc] initDisplaying:displayFilter data:data];
    return [viewController autorelease];
}

-(id) initDisplaying:(NSDictionary*)displayFilter data:(NSArray*)data {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.displayFilter = displayFilter;
        self.title = NSLocalizedString([displayFilter objectForKey:@"title"],@"");
        //tableData = [[NSMutableArray alloc] initWithCapacity:[data count]];
        
        self.selectedCells = [NSMutableArray arrayWithCapacity:[data count]];
        [self updateData:data forFilter:self.displayFilter];
    }
    return self;    
}
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

-(BOOL)updateData:(NSArray*)data forFilter:(NSDictionary*)_displayFilter {
    // Make sure we're displaying the same filter, if not just give up
    if (![[self.displayFilter objectForKey:@"title"] isEqualToString:[self.displayFilter objectForKey:@"title"]]) {
        return NO;
    }
    
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *collationData = [NSMutableArray arrayWithCapacity:30];
    self.totalRowCount = [data count];

    NSString *headerName;
    NSUInteger section;
    
    NSString *collationSelectorName = [self.displayFilter objectForKey:@"collationSelector"];
    SEL collationSelector;
    if (collationSelectorName) {
        collationSelector = NSSelectorFromString(collationSelectorName);
    } else {
        collationSelector = @selector(uppercaseString);
    }
    for (headerName in data) {
        section = [theCollation sectionForObject:headerName collationStringSelector:collationSelector];
        while ([collationData count] <= section) {
            [collationData addObject:[NSMutableArray arrayWithCapacity:1]];
        }
        [[collationData objectAtIndex:section] addObject:headerName];
    }
    @synchronized(self.tableData) {
        self.tableData = collationData;
    }
    if (self.viewLoaded) {
        [self.tableView reloadData];
    }
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.sectionIndexMinimumDisplayRowCount = self.hierarchyController.sectionIndexMinimumDisplayRowCount;
    self.viewLoaded = YES;
    NSDictionary *appFeatures = [self.hierarchyController.appdata objectForKey:@"features"];
    if (appFeatures && [[appFeatures objectForKey:@"searchSupported"] isEqualToString:@"YES"] ) {
        UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Using filters", @"All entries", nil];
        self.tableView.tableHeaderView = searchBar;
        
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        if (searchDisplayController == self.searchDisplayController) {
            NSLog(@"YES");
        }
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.searchResultsDataSource = self;
        self.searchController = searchDisplayController;
        [searchDisplayController release]; searchDisplayController = nil;
    }
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    //UISearchDisplayController *sdc = [[UISearchDisplayController alloc] initWithSearchBar:<#(UISearchBar *)searchBar#> contentsController:<#(UIViewController *)viewController#>
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)setSelecting:(BOOL)selecting {
    static UIBarButtonItem *oldRightBarButtonItem = nil;
    static UIBarButtonItem *oldLeftBarButtonItem = nil;
    _selecting = selecting;
    if (self.selecting) {
        UINavigationItem *item = self.hierarchyController.selectModeNavigationItem;
        if (item.title) {
            self.navigationItem.title = item.title;
        }
        if (item.leftBarButtonItem) {
            oldLeftBarButtonItem = self.navigationItem.leftBarButtonItem;
            self.navigationItem.leftBarButtonItem = item.leftBarButtonItem;
        }
        if (item.rightBarButtonItem) {
            oldRightBarButtonItem = self.navigationItem.rightBarButtonItem;
            self.navigationItem.rightBarButtonItem = item.rightBarButtonItem;
        }
        self.tableView.tableHeaderView = nil;
        [self.selectedCells removeAllObjects];
    } else {
        self.navigationItem.title = NSLocalizedString([self.displayFilter objectForKey:@"title"],@"");
        self.navigationItem.leftBarButtonItem = oldLeftBarButtonItem;
        self.navigationItem.rightBarButtonItem = oldRightBarButtonItem;
        self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    }
    [self.tableView reloadData];

}

-(BOOL) selecting {
    return _selecting;
}

-(NSArray*) selectedData {
    NSUInteger i, count = [self.selectedCells count];
    NSMutableArray *selections = [NSMutableArray arrayWithCapacity:count];
    for (i = 0; i < count; i++) {
        NSIndexPath * selection = [self.selectedCells objectAtIndex:i];
        [selections addObject:[self.tableData objectAtIndex:[selection indexAtPosition:1]]];
    }
    return selections;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredData count];
    } else {
        return [self.tableData count];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.filteredData) {
            return [[[self.filteredData objectAtIndex:section] objectForKey:@"results"] count];
        } else {
            return 0;
        }
    } else {
        if (section < [self.tableData count]) {
            return [[self.tableData objectAtIndex:section] count];        
        }
    }
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView && self.totalRowCount > self.tableView.sectionIndexMinimumDisplayRowCount) {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
    return nil;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.filteredData) {
            return [[self.filteredData objectAtIndex:section] objectForKey:@"type"];
        } else {
            return nil;
        }
    } else if (tableView == self.tableView && self.totalRowCount > self.tableView.sectionIndexMinimumDisplayRowCount) {
        if (section < [self.tableData count] && [[self.tableData objectAtIndex:section] count] > 0) {
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        }
        return nil;    
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tableView && [self.tableData count] > self.tableView.sectionIndexMinimumDisplayRowCount) {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *result = [[[self.filteredData objectAtIndex:[indexPath indexAtPosition:0]] objectForKey:@"results"] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [result objectForKey:@"title"];
    } else {
        NSString *itemValue = nil;
        NSArray *sectionData = nil;
        if (indexPath.section < [self.tableData count]) {
            sectionData = [self.tableData objectAtIndex:indexPath.section];
        }
        if (sectionData && indexPath.row < [sectionData count]) {
            itemValue = [sectionData objectAtIndex:indexPath.row];
        }
        cell.textLabel.text = itemValue;
        if (self.selecting) {
            if ([self.selectedCells indexOfObject:indexPath]!= NSNotFound) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            if (self.totalRowCount > self.tableView.sectionIndexMinimumDisplayRowCount) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }

    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
    self.filteredData = [self.hierarchyController filterDataForSearchTerm:searchText usingFilters:[scope isEqualToString:@"Using filters"]];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *result = [[[self.filteredData objectAtIndex:[indexPath indexAtPosition:0]] objectForKey:@"results"] objectAtIndex:[indexPath indexAtPosition:1]];
        if ([result objectForKey:@"itemData"]) {
            [self.hierarchyController showItem:[result objectForKey:@"itemData"] fromSave:NO];
        } else {
            // Load a filter
        }

    } else if (self.selecting) {
        NSUInteger index = [self.selectedCells indexOfObject:indexPath];
        if (index!=NSNotFound) {
            [self.selectedCells removeObjectAtIndex:index];
        } else {
            [self.selectedCells addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSString *itemValue = nil;
        NSArray *sectionData = nil;
        if (indexPath.section < [self.tableData count]) {
            sectionData = [self.tableData objectAtIndex:indexPath.section];
        }
        if (sectionData && indexPath.row < [sectionData count]) {
            itemValue = [sectionData objectAtIndex:indexPath.row];
        }
        if (itemValue) {
            [self.hierarchyController filterProperty:[self.displayFilter objectForKey:@"property"] value:itemValue fromSave:NO];
        }
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.viewLoaded = NO;
    self.searchController = nil;
}


- (void)dealloc {
    self.tableData = nil;
    self.filteredData = nil;
    self.selectedCells = nil;
    self.hierarchyController = nil;
    self.displayFilter = nil;
    self.searchController = nil;

    [super dealloc];
}


@end

