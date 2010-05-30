//
//  ItemWebViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemWebViewController : UIViewController <UIWebViewDelegate> {
    NSDictionary *itemData;
    IBOutlet UIWebView *webView;
    BOOL initialLoadPerformed;
    IBOutlet UIView *statusIndicator;
}

-(id) initWithItem:(NSDictionary*)_itemData;
-(void) setStatusTimer;
-(void) hideStatusIndicator;

@end
