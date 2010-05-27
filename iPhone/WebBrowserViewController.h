//
//  WebBrowserViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebBrowserViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UIView *statusView;
    IBOutlet UILabel *statusURL;
    IBOutlet UIBarButtonItem *backButton, *forwardButton, *spacerButton, *actionButton, *stopButton, *refreshButton, *doneButton;
    NSURLRequest *request;
    IBOutlet UIToolbar *toolbar;
}

-(id) initWithRequest:(NSURLRequest*)_request;
-(IBAction) closeWebBrowser:(id)sender;
- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)stopRequest:(id)sender;
- (void)refreshPage:(id)sender;
- (void)showActions:(id)sender;
- (void)requestStopped;

@end
