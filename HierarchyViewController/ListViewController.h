//
//  ListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HierarchyViewController;

@interface ListViewController : UITableViewController <UISearchDisplayDelegate> {
    NSDictionary *displayFilter;
    NSArray *tableData;
    NSArray *filteredData;
    UISearchDisplayController *searchDisplayController;
    HierarchyViewController *hierarchyController;
}

@property (nonatomic, retain) HierarchyViewController *hierarchyController;

-(id) initDisplaying:(NSDictionary*)_displayFilter data:(NSArray*)data;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
