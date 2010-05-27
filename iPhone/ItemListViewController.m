//
//  ItemListViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "ItemListViewController.h"
#import "AppDelegate_Phone.h"

@implementation ItemListViewController


#pragma mark -
#pragma mark Initialization

-(id) initDisplaying:(NSDictionary*)_itemData data:(NSArray*)data filteredBy:(NSArray*)allFilters {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.title = [_itemData objectForKey:@"title"];
        NSLog(@"Set title to %@", [_itemData objectForKey:@"title"] );
        NSLog(@"itemData = %@", _itemData);
        //tableData = [[NSMutableArray alloc] initWithCapacity:[data count]];
        
        NSMutableArray *newTableData = [NSMutableArray arrayWithCapacity:[data count]];
        NSDictionary *itemData, *itemProperties;
        NSArray *filter;
        NSString *testValue;
        for (itemData in data) {
            BOOL match = YES;
            itemProperties = [itemData objectForKey:@"properties"];
            
            // FIXME Do some checking against the filters
            for (filter in allFilters) {
                testValue = [itemProperties objectForKey:[filter objectAtIndex:0]];
                if (![testValue isEqualToString:[filter objectAtIndex:1]]) {
                    match = NO;
                    break;
                }
            }
            
            if (match) {
                [newTableData addObject:itemData];
            }
        }
        tableData = [[newTableData sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"self.title" ascending:YES] autorelease]]
                      ] retain];
    }
    return self;    
}

-(BOOL) validItem:(NSDictionary*)itemData {
    NSDictionary *other;
    NSString *itemID = [itemData objectForKey:@"id"];
    for (other in tableData) {
        if ([itemID isEqualToString:[other objectForKey:@"id"]]) {
            return YES;
        }
    }
    return NO;
    
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

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *itemData = [tableData objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text = [itemData objectForKey:@"title"];
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    AppDelegate_Phone *appDelegate = (AppDelegate_Phone*)[[UIApplication sharedApplication] delegate];
    NSDictionary *itemData = [tableData objectAtIndex:[indexPath indexAtPosition:1]];
    [appDelegate showItem:itemData confirm:NO];
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

