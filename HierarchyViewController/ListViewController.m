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

@synthesize hierarchyController, displayFilter;


#pragma mark -
#pragma mark Initialization

-(id) initDisplaying:(NSDictionary*)_displayFilter data:(NSArray*)data {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        displayFilter = [_displayFilter retain];
        self.title = [displayFilter objectForKey:@"title"];
        NSLog(@"Set title to %@", [displayFilter objectForKey:@"title"] );
        //tableData = [[NSMutableArray alloc] initWithCapacity:[data count]];
        
        tableData = [data retain];
        selectedCells = [[NSMutableArray arrayWithCapacity:[data count]] retain];
        filteredData = nil;
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

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Using filters", @"All entries", nil];
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

- (void)setSelecting:(BOOL)_selecting {
    static UIBarButtonItem *oldRightBarButtonItem = nil;
    static UIBarButtonItem *oldLeftBarButtonItem = nil;
    selecting = _selecting;
    if (selecting) {
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
        [selectedCells removeAllObjects];
    } else {
        self.navigationItem.title = [displayFilter objectForKey:@"title"];
        self.navigationItem.leftBarButtonItem = oldLeftBarButtonItem;
        self.navigationItem.rightBarButtonItem = oldRightBarButtonItem;
        self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    }
    [self.tableView reloadData];

}

-(NSArray*) selectedData {
    NSUInteger i, count = [selectedCells count];
    NSMutableArray *selections = [NSMutableArray arrayWithCapacity:count];
    for (i = 0; i < count; i++) {
        NSIndexPath * selection = [selectedCells objectAtIndex:i];
        [selections addObject:[tableData objectAtIndex:[selection indexAtPosition:1]]];
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
        return [filteredData count];
    } else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (filteredData) {
            NSLog(@"For section %i returning %i rows", section, [[[filteredData objectAtIndex:section] objectForKey:@"results"] count]);
            NSLog(@"Section %i has this data: %@", section, [filteredData objectAtIndex:section]);
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *result = [[[filteredData objectAtIndex:[indexPath indexAtPosition:0]] objectForKey:@"results"] objectAtIndex:[indexPath indexAtPosition:1]];
        cell.textLabel.text = [result objectForKey:@"title"];
    } else {
        cell.textLabel.text = [tableData objectAtIndex:[indexPath indexAtPosition:1]];
        if (selecting) {
            if ([selectedCells indexOfObject:indexPath]!= NSNotFound) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *result = [[[filteredData objectAtIndex:[indexPath indexAtPosition:0]] objectForKey:@"results"] objectAtIndex:[indexPath indexAtPosition:1]];
        if ([result objectForKey:@"itemData"]) {
            [hierarchyController showItem:[result objectForKey:@"itemData"] fromSave:NO];
        } else {
            // Load a filter
        }

    } else if (selecting) {
        NSUInteger index = [selectedCells indexOfObject:indexPath];
        if (index!=NSNotFound) {
            NSLog(@"deselecting");
            [selectedCells removeObjectAtIndex:index];
        } else {
            NSLog(@"selecting");
            [selectedCells addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [hierarchyController filterProperty:[displayFilter objectForKey:@"property"] value:[tableData objectAtIndex:[indexPath indexAtPosition:1]] fromSave:NO];
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
}


- (void)dealloc {
    [super dealloc];
}


@end
