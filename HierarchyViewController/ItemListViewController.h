//
//  ItemListViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "ItemListTableViewCell.h"

@class HierarchyViewController;

@interface ItemListViewController : ListViewController {
}

+(ItemListViewController*)viewControllerDisplaying:(NSDictionary*)itemData data:(NSArray*)data;

-(id) initDisplaying:(NSDictionary*)itemData data:(NSArray*)data;

-(BOOL)updateData:(NSArray*)data;

@end
