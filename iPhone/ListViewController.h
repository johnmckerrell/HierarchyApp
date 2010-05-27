//
//  ListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListViewController : UITableViewController {
    NSDictionary *displayFilter;
    NSArray *tableData;
}
// Create a ListViewController with
//  displaying firstFilter
//  [filteredBy currentFilters copy]

-(id) initDisplaying:(NSDictionary*)_displayFilter data:(NSArray*)data filteredBy:(NSArray*)_allFilters;

@end
