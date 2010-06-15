//
//  ItemDetailViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HierarchyViewController;


@interface ItemDetailViewController : UITableViewController {
    NSDictionary *itemData;
    HierarchyViewController *hierarchyController;
}

@property (nonatomic, retain) HierarchyViewController *hierarchyController;

-(id) initWithItem:(NSDictionary*)_itemData;

@end
