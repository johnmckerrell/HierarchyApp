//
//  ItemWebViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HierarchyViewController;


@interface ItemWebViewController : UIViewController <UIWebViewDelegate> {
    NSDictionary *_itemData;
    UIWebView *_webView;
    BOOL _initialLoadPerformed;
    UIView *_statusIndicator;
    HierarchyViewController *_hierarchyController;
}

@property (nonatomic, retain) HierarchyViewController *hierarchyController;
@property (nonatomic, retain) NSDictionary *itemData;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, assign) BOOL initialLoadPerformed;
@property (nonatomic, retain) IBOutlet UIView *statusIndicator;

-(id) initWithItem:(NSDictionary*)itemData;
-(void) setStatusTimer;
-(void) hideStatusIndicator;

@end
