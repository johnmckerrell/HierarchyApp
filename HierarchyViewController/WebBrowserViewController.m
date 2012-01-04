    //
//  WebBrowserViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "WebBrowserViewController.h"


@implementation WebBrowserViewController

@synthesize webView = _webView;
@synthesize statusView = _statusView;
@synthesize statusURL = _statusURL;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize spacerButton = _spacerButton;
@synthesize actionButton = _actionButton;
@synthesize stopButton = _stopButton;
@synthesize refreshButton = _refreshButton;
@synthesize doneButton = _doneButton;
@synthesize request = _request;
@synthesize toolbar = _toolbar;

-(id) initWithRequest:(NSURLRequest*)request {
    if ((self = [super init])) {
        self.request = request;
        // Don't need to do stuff with these if we're hiding the
        // navigation bar, which we do in viewWillAppear
        //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeWebBrowser:)] autorelease];
        //self.navigationItem.hidesBackButton = YES;
        // Test Comment
        // Test Comment 2
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(IBAction) closeWebBrowser:(id)sender {
    [self viewWillDisappear:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.statusURL.text = [[self.request URL] absoluteString];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:self.request];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSString *url = [[webView.request URL] absoluteString];
    if (url && ! [url isEqualToString:@""]) {
        self.statusURL.text = url;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.statusView.alpha = 1.0;
    [UIView commitAnimations];
    [self.toolbar setItems:[NSArray arrayWithObjects:self.backButton, self.forwardButton, self.actionButton, self.spacerButton, self.stopButton, self.doneButton, nil] animated:NO];
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)goBack:(id)sender {
    [self.webView goBack];
}

- (void)goForward:(id)sender {
    [self.webView goForward];
}

- (void)stopRequest:(id)sender {
    [self.webView stopLoading];
}

- (void)refreshPage:(id)sender {
    [self.webView reload];
}

- (void)showActions:(id)sender {
    UIActionSheet *actions = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil] autorelease];
    [actions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[[self.webView request] URL]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self requestStopped];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] != NSURLErrorCancelled && [error code] != 204) {
        [[[[UIAlertView alloc] initWithTitle:@"Error"
                                     message:@"Failed to load the page, please make sure you're connected to the internet."
                                    delegate:nil
                           cancelButtonTitle:@"Close"
                           otherButtonTitles:nil] autorelease] show];
    }
    [self requestStopped];
}

- (void)requestStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.statusView.alpha = 0.0;
    [UIView commitAnimations];
    [self.toolbar setItems:[NSArray arrayWithObjects:self.backButton, self.forwardButton, self.actionButton, self.spacerButton, self.refreshButton, self.doneButton, nil] animated:NO];
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.statusView = nil;
    self.statusURL = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.spacerButton = nil;
    self.actionButton = nil;
    self.stopButton = nil;
    self.refreshButton = nil;
    self.doneButton = nil;
    self.toolbar = nil;
}


- (void)dealloc {
    self.webView = nil;
    self.statusView = nil;
    self.statusURL = nil;
    self.backButton = nil;
    self.forwardButton = nil;
    self.spacerButton = nil;
    self.actionButton = nil;
    self.stopButton = nil;
    self.refreshButton = nil;
    self.doneButton = nil;
    self.toolbar = nil;
    self.request = nil;
    
    [super dealloc];
}


@end
