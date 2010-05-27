//
//  ItemDetailViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemDetailViewController : UITableViewController {
    NSDictionary *itemData;
}

-(id) initWithItem:(NSDictionary*)_itemData;

@end
