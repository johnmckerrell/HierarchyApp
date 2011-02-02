//
//  HierarchyViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 15/06/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MATCH_ALL @"com.7digital.MATCH_ALL"

@interface HierarchyViewController : UIViewController <UINavigationControllerDelegate, UITabBarControllerDelegate> {
    UITabBarController *_tabBarController;
    NSArray *_maindata;
    NSDictionary *_filtersdata;
    NSDictionary *_appdata;
    NSString *_currentCategory;
    NSMutableArray *_currentFilters;
    NSArray  *_extraFilters;
    NSUInteger _categoryPathPosition;
    NSDictionary *_currentItem;
    NSMutableArray *_filteredData;
    NSMutableArray *_ignoredFilters;
    NSDictionary *_localizedCategoriesMap;
    UIColor *_tintColor;

    NSString *_startCategory;
    NSArray *_startFilters;
    NSDictionary *_startItem;
    
    NSArray *_extraViewControllers;
    
    UIBarButtonItem *_leftMostItem;
    UIBarButtonItem *_rightBarButtonItem;
    UINavigationItem *_selectModeNavigationItem;
    
    NSInteger _sectionIndexMinimumDisplayRowCount;
}

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
@property (nonatomic, readonly) NSUInteger categoryPathPosition;
@property (nonatomic, retain, readonly) NSMutableArray *ignoredFilters;
@property (nonatomic, retain, readonly) NSMutableArray *filteredData;
@property (nonatomic, retain, readonly) NSArray *maindata;
@property (nonatomic, retain, readonly) NSDictionary *filtersdata;
@property (nonatomic, retain, readonly) NSDictionary *appdata;
@property (nonatomic, retain, readonly) NSString *currentCategory;
@property (nonatomic, retain, readonly) NSMutableArray *currentFilters;
@property (nonatomic, retain, readonly) NSDictionary *currentItem;
@property (nonatomic, retain, readonly) NSDictionary *localizedCategoriesMap;
@property (nonatomic) NSInteger sectionIndexMinimumDisplayRowCount;

- (id)initWithAppData:(NSDictionary*)appdata filtersData:(NSDictionary*)filtersdata mainData:(NSArray*)maindata;

-(void) startSelectMode;
-(void) stopSelectMode;
-(NSArray*) selectedData;
-(void) setCurrentCategory:(NSString*)category filters:(NSArray*) filters item:(NSDictionary*)itemData;
-(void) setupTabBarWithInitialCategory:(NSString*)initialCategory;
-(void) setCategoryByName:(NSString*) category;
-(BOOL) filterProperty:(NSString*)name value:(NSString*)value fromSave:(BOOL) fromSave;
-(BOOL) showItem:(NSDictionary*)itemData fromSave:(BOOL) fromSave;
-(void) loadURLRequestInLocalBrowser:(NSURLRequest*) request;
-(NSDictionary*) getCurrentFilterAtPosition:(NSUInteger)position;
-(NSDictionary*) getCategoryDataByName:(NSString*) category;
-(void) saveCurrentPosition;
-(void)filterData;
-(void)filterDataWhereProperty:(NSString*)property hasValue:(NSString*)value;
-(NSArray*)filterHeadings:(NSDictionary*)filter;
-(BOOL) filter:(NSDictionary*)aFilterData isEqualTo:(NSDictionary*)bFilterData;
-(void)reloadData;
-(void) updateData:(NSArray*)data;

-(NSArray*)filterDataForSearchTerm:(NSString*)string usingFilters:(BOOL)useFilters;

-(BOOL)property:(id) property matchesValue:(NSString*) testString;

@end
