//
//  ItemListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@class HierarchyViewController;

@interface ItemListViewController : ListViewController {
}


-(id) initDisplaying:(NSDictionary*)_itemData data:(NSArray*)data;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
