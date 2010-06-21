//
//  HierarchyViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 15/06/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HierarchyViewController : UIViewController <UINavigationControllerDelegate, UITabBarControllerDelegate> {
    UITabBarController *tabBarController;
    NSArray *maindata;
    NSDictionary *filtersdata;
    NSDictionary *appdata;
    NSString *currentCategory;
    NSMutableArray *currentFilters;
    NSArray  *extraFilters;
    NSUInteger categoryPathPosition;
    NSDictionary *currentItem;
    NSMutableArray *filteredData;
    NSMutableArray *ignoredFilters;
    UIColor *tintColor;

    NSString *startCategory;
    NSArray *startFilters;
    NSDictionary *startItem;
    
    NSArray *extraViewControllers;
    
    UIBarButtonItem *leftMostItem;
    UIBarButtonItem *rightBarButtonItem;
    UINavigationItem *selectModeNavigationItem;
}

@property (nonatomic, readonly) NSArray *filteredData;
@property (nonatomic, retain) NSArray *extraViewControllers;
@property (nonatomic, retain) UIBarButtonItem *leftMostItem;
@property (nonatomic, retain) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) UINavigationItem *selectModeNavigationItem;
@property (nonatomic, retain) NSString *startCategory;
@property (nonatomic, retain) NSArray *startFilters;
@property (nonatomic, retain) NSDictionary *startItem;
@property (nonatomic, retain) NSArray *extraFilters;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, readonly) NSArray *maindata;
@property (nonatomic, readonly) NSDictionary *filtersdata;
@property (nonatomic, readonly) NSDictionary *appdata;
@property (nonatomic, readonly) NSString *currentCategory;
@property (nonatomic, readonly) NSMutableArray *currentFilters;
@property (nonatomic, readonly) NSDictionary *currentItem;

- (id)initWithAppData:(NSDictionary*)_appdata filtersData:(NSDictionary*)_filtersdata mainData:(NSArray*)_maindata;

-(void) startSelectMode;
-(void) stopSelectMode;
-(NSArray*) selectedData;
-(void) setCurrentCategory:(NSString*)_category filters:(NSArray*) _filters item:(NSDictionary*)_itemData;
-(void) setupTabBarWithInitialCategory:(NSString*)initialCategory;
-(void) setCategoryByName:(NSString*) category;
-(BOOL) filterProperty:(NSString*)name value:(NSString*)value fromSave:(BOOL) fromSave;
-(BOOL) showItem:(NSDictionary*)itemData fromSave:(BOOL) fromSave;
-(void) loadURLRequestInLocalBrowser:(NSURLRequest*) request;
-(NSDictionary*) getCurrentFilterAtPosition:(NSUInteger)position;
-(NSDictionary*) getCategoryDataByName:(NSString*) category;
-(void) saveCurrentPosition;
-(void)filterData;
-(NSArray*)filterHeadings:(NSDictionary*)filter;
-(void) updateData:(NSArray*)_data;

-(NSArray*)filterDataForSearchTerm:(NSString*)string usingFilters:(BOOL)useFilters;

-(BOOL)property:(id) property matchesValue:(NSString*) testString;

@end
