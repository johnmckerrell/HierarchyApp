//
//  AppDelegate_Phone.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright MKE Computing Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate_Phone : NSObject <UIApplicationDelegate,UINavigationControllerDelegate> {
    UIWindow *window;
    IBOutlet UINavigationController *navigationController;
    NSArray *maindata;
    NSDictionary *filtersdata;
    NSDictionary *appdata;
    NSString *currentCategory;
    NSMutableArray *currentFilters;
    NSUInteger categoryPathPosition;
    UIImageView *splashView;
    NSDictionary *currentItem;
    NSMutableArray *filteredData;
    NSMutableArray *ignoredFilters;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, readonly) NSArray *maindata;
@property (nonatomic, readonly) NSDictionary *filtersdata;
@property (nonatomic, readonly) NSDictionary *appdata;

-(void)slideSplashScreenOut;
-(void) setCategoryByName:(NSString*) category;
-(BOOL) filterProperty:(NSString*)name value:(NSString*)value fromSave:(BOOL) fromSave;
-(BOOL) showItem:(NSDictionary*)itemData fromSave:(BOOL) fromSave;
-(void) loadURLRequestInLocalBrowser:(NSURLRequest*) request;
-(NSDictionary*) getCurrentFilterAtPosition:(NSUInteger)position;
-(NSDictionary*) getCategoryDataByName:(NSString*) category;
-(void) saveCurrentPosition;
-(void)filterData;
-(NSArray*)filterHeadings:(NSDictionary*)filter;

-(NSArray*)filterDataForSearchTerm:(NSString*)string usingFilters:(BOOL)useFilters;

@end

