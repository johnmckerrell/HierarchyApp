    //
//  ItemWebViewController.m
//  HierarchyApp
//
//  Created by John McKerrell on 26/05/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "ItemWebViewController.h"
#import "HierarchyViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemWebViewController

@synthesize hierarchyController = _hierarchyController;
@synthesize itemData = _itemData;
@synthesize webView = _webView;
@synthesize initialLoadPerformed = _initialLoadPerformed;
@synthesize statusIndicator = _statusIndicator;

-(id) initWithItem:(NSDictionary*)itemData {
    if ((self = [super init])) {
        self.itemData = itemData;
        self.title = [self.itemData objectForKey:@"title"];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusIndicator.layer.cornerRadius = 10.0;
    
    NSURL *requestURL = nil;
    if ([self.itemData objectForKey:@"url"]) {
        requestURL = [NSURL URLWithString:[self.itemData objectForKey:@"url"]];
    } else if ([self.itemData objectForKey:@"htmlfile"]) {
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[self.itemData objectForKey:@"htmlfile"]];
        requestURL = [NSURL fileURLWithPath:path];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.initialLoadPerformed) {
        [self.hierarchyController loadURLRequestInLocalBrowser:request];
        return NO;
    } else {
        self.initialLoadPerformed = YES;
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setStatusTimer];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self setStatusTimer];
}

-(void) setStatusTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideStatusIndicator) userInfo:nil repeats:NO];
}

-(void) hideStatusIndicator {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.statusIndicator.alpha = 0;
    [UIView commitAnimations];
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
    self.statusIndicator = nil;
}


- (void)dealloc {
    self.itemData = nil;
    self.webView = nil;
    self.statusIndicator = nil;
    self.hierarchyController = nil;
    
    [super dealloc];
}


@end
