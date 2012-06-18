//
//  ItemListViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "ItemListViewController.h"
#import "HierarchyViewController.h"

@implementation ItemListViewController

#pragma mark -
#pragma mark Initialization

+(ItemListViewController*)viewControllerDisplaying:(NSDictionary*)itemDesc data:(NSArray*)data {
    NSString *cellViewClassString = nil;
    Class cellViewClass = nil;
    if (!cellViewClass && [itemDesc objectForKey:@"listViewController"]) {
        cellViewClassString = [itemDesc objectForKey:@"listViewController"];
        cellViewClass = NSClassFromString(cellViewClassString);
        [cellViewClass isKindOfClass:[ItemListViewController class]];
    }
    if (!cellViewClass) {
        cellViewClass = [ItemListViewController class];
    }

    ItemListViewController *viewController = [[cellViewClass alloc] initDisplaying:itemDesc data:data];
    return [viewController autorelease];
}

-(id) initDisplaying:(NSDictionary*)itemData data:(NSArray*)data {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.title = [itemData objectForKey:@"title"];
        
        self.selectedCells = [NSMutableArray arrayWithCapacity:[data count]];
        [self updateData:data];
    }
    return self;    
}

-(BOOL)updateData:(NSArray*)data {
    NSArray *sortedData = [data sortedArrayUsingDescriptors:
                  [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease]]
                  ];
        
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *collationData = [NSMutableArray arrayWithCapacity:30];
    
    NSString *itemName;
    NSUInteger section;
    self.totalRowCount = [sortedData count];
    
    NSMutableDictionary *itemData;
    for (itemData in sortedData) {
        itemName = [itemData objectForKey:@"title"];
        section = [theCollation sectionForObject:itemName collationStringSelector:@selector(uppercaseString)];
        while ([collationData count] <= section) {
            [collationData addObject:[NSMutableArray arrayWithCapacity:1]];
        }
        [[collationData objectAtIndex:section] addObject:itemData];
    }
    @synchronized(self.tableData) {
        self.tableData = collationData;
    }
    
    if ([self viewLoaded]) {
        [self.tableView reloadData];
    }
    return YES;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    if ([hierarchyController.currentFilters count] > 0) {
        searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Using filters", @"All entries", nil];
    }
    self.tableView.tableHeaderView = searchBar;
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    //UISearchDisplayController *sdc = [[UISearchDisplayController alloc] initWithSearchBar:<#(UISearchBar *)searchBar#> contentsController:<#(UIViewController *)viewController#>
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}
*/

#pragma mark -
#pragma mark Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredData count];
    } else {
        return 1;
    }
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (filteredData) {
            return [[[filteredData objectAtIndex:section] objectForKey:@"results"] count];
        } else {
            return 0;
        }
    } else {
        return [tableData count];        
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (filteredData) {
            return [[filteredData objectAtIndex:section] objectForKey:@"type"];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    NSDictionary *itemDesc = [self.hierarchyController.appdata objectForKey:@"itemData"];
    
    NSString *cellViewClassString = nil;
    Class cellViewClass = nil;
    if (!cellViewClass && [itemDesc objectForKey:@"defaultItemCellClass"]) {
        cellViewClassString = [itemDesc objectForKey:@"defaultItemCellClass"];
        cellViewClass = NSClassFromString(cellViewClassString);
    }
    if (!cellViewClass) {
        cellViewClass = [ItemListTableViewCell class];
    }
    
    ItemListTableViewCell *cell = (ItemListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[cellViewClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *result = [[[self.filteredData objectAtIndex:[indexPath indexAtPosition:0]] objectForKey:@"results"] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.itemData = result;
    } else {
        NSDictionary *itemData = nil;
        NSArray *sectionData = nil;
        if (indexPath.section < [self.tableData count]) {
            sectionData = [self.tableData objectAtIndex:indexPath.section];
        }
        if (indexPath.row < [sectionData count]) {
            itemData = [sectionData objectAtIndex:indexPath.row];
        }
        cell.itemData = itemData;
        if (self.selecting) {
            cell.checking = YES;
            if ([self.selectedCells indexOfObject:indexPath]!= NSNotFound) {
                cell.checked = YES;
            } else {
                cell.checked = NO;
            }
        }

    }
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
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

/*
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	// Update the filtered array based on the search text and scope.
    
    [filteredData release];
    filteredData = [hierarchyController filterDataForSearchTerm:searchText usingFilters:[scope isEqualToString:@"Using filters"]];
    [filteredData retain];
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

*/

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
        NSDictionary *itemData = nil;
        NSArray *sectionData = nil;
        if (indexPath.section < [self.tableData count]) {
            sectionData = [self.tableData objectAtIndex:indexPath.section];
        }
        if (indexPath.row < [sectionData count]) {
            itemData = [sectionData objectAtIndex:indexPath.row];
        }
        if (itemData) {
            [self.hierarchyController showItem:itemData fromSave:NO];
        }
    }
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
}


- (void)dealloc {
    [super dealloc];
}


@end

