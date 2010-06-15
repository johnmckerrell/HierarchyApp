//
//  ItemListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HierarchyViewController;

@interface ItemListViewController : UITableViewController <UISearchDisplayDelegate> {
    NSArray *tableData;
    NSArray *filteredData;
    UISearchDisplayController *searchDisplayController;
    HierarchyViewController *hierarchyController;
}

@property (nonatomic, retain) HierarchyViewController *hierarchyController;

-(id) initDisplaying:(NSDictionary*)_itemData data:(NSArray*)data;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
