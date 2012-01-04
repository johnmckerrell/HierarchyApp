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
    NSDictionary *_displayFilter;
    NSArray *_tableData;
    NSArray *_filteredData;
    HierarchyViewController *_hierarchyController;
    UISearchDisplayController *_searchController;
    NSMutableArray *_selectedCells;
    NSUInteger _totalRowCount;
    BOOL _selecting;
    BOOL _ignoreRightButton;
    BOOL _viewLoaded;
}

@property (nonatomic, retain) NSArray *tableData;
@property (nonatomic, retain) NSArray *filteredData;
@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) NSMutableArray *selectedCells;
@property (nonatomic, assign) NSUInteger totalRowCount;
@property (nonatomic, assign) BOOL selecting;
@property (nonatomic, assign) BOOL viewLoaded;
@property (nonatomic, retain) HierarchyViewController *hierarchyController;
@property (nonatomic, retain) NSDictionary *displayFilter;
@property (nonatomic, assign) BOOL ignoreRightButton;

+(ListViewController*)viewControllerDisplaying:(NSDictionary*)displayFilter data:(NSArray*)data;

-(id) initDisplaying:(NSDictionary*)displayFilter data:(NSArray*)data;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void)setSelecting:(BOOL)selecting;
-(NSArray*) selectedData;
-(BOOL)updateData:(NSArray*)data forFilter:(NSDictionary*)_displayFilter;

@end
