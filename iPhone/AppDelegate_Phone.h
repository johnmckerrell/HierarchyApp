//
//  AppDelegate_Phone.h
//  HierarchyApp
//
//  Created by John McKerrell on 25/05/2010.
//  Copyright MKE Computing Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HierarchyViewController.h"

@interface AppDelegate_Phone : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIImageView *splashView;
    HierarchyViewController *hierarchyController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void)slideSplashScreenOut;

@end

