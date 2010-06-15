    //
//  WebBrowserViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "WebBrowserViewController.h"


@implementation WebBrowserViewController

@synthesize toolbar;

-(id) initWithRequest:(NSURLRequest*)_request {
    if ((self = [super init])) {
        request = [_request retain];
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
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"1:statusURL.text=%@", statusURL.text);
    statusURL.text = [[request URL] absoluteString];
    NSLog(@"2:statusURL.text=%@", statusURL.text);
    webView.scalesPageToFit = YES;
    [webView loadRequest:request];
    
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

- (void)webViewDidStartLoad:(UIWebView *)_webView {
    NSLog(@"web browser Did start load.");
    NSLog(@"3:statusURL.text=%@", statusURL.text);
    NSString *url = [[webView.request URL] absoluteString];
    if (url && ! [url isEqualToString:@""]) {
        statusURL.text = url;
    }
    NSLog(@"4:statusURL.text=%@", statusURL.text);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    statusView.alpha = 1.0;
    [UIView commitAnimations];
    [toolbar setItems:[NSArray arrayWithObjects:backButton, forwardButton, actionButton, spacerButton, stopButton, doneButton, nil] animated:NO];
    backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
}

- (void)goBack:(id)sender {
    [webView goBack];
}

- (void)goForward:(id)sender {
    [webView goForward];
}

- (void)stopRequest:(id)sender {
    [webView stopLoading];
}

- (void)refreshPage:(id)sender {
    [webView reload];
}

- (void)showActions:(id)sender {
    UIActionSheet *actions = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil] autorelease];
    [actions showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[[webView request] URL]];
    }
    NSLog(@"buttonIndex=%i", buttonIndex);
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    NSLog(@"web browser Did finish load.");
    [self requestStopped];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error code] != NSURLErrorCancelled) {
    }
    NSLog(@"web browser Did fail load with error: %@", error);
    [self requestStopped];
}

- (void)requestStopped {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    statusView.alpha = 0.0;
    [UIView commitAnimations];
    [toolbar setItems:[NSArray arrayWithObjects:backButton, forwardButton, actionButton, spacerButton, refreshButton, doneButton, nil] animated:NO];
    backButton.enabled = webView.canGoBack;
    forwardButton.enabled = webView.canGoForward;
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
}


- (void)dealloc {
    [request release], request = nil;
    [super dealloc];
}


@end
