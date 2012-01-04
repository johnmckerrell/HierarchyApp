//
//  WebBrowserViewController.h
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebBrowserViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate> {
    UIWebView *_webView;
    UIView *_statusView;
    UILabel *_statusURL;
    UIBarButtonItem *_backButton, *_forwardButton, *_spacerButton, *_actionButton, *_stopButton, *_refreshButton, *_doneButton;
    NSURLRequest *_request;
    UIToolbar *_toolbar;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *statusView;
@property (nonatomic, retain) IBOutlet UILabel *statusURL;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *spacerButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

-(id) initWithRequest:(NSURLRequest*)request;
-(IBAction) closeWebBrowser:(id)sender;
- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)stopRequest:(id)sender;
- (void)refreshPage:(id)sender;
- (void)showActions:(id)sender;
- (void)requestStopped;

@end
