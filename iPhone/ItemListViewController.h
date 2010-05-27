//
//  ItemListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemListViewController : UITableViewController {
    NSArray *tableData;
}

-(id) initDisplaying:(NSDictionary*)_itemData data:(NSArray*)data filteredBy:(NSArray*)_allFilters;
-(BOOL) validItem:(NSDictionary*)itemData;

@end
