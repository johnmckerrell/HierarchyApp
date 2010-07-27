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

@synthesize hierarchyController;

-(id) initWithItem:(NSDictionary*)_itemData {
    if ((self = [super init])) {
        itemData = [_itemData retain];
        self.title = [itemData objectForKey:@"title"];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        NSLog(@"webView=%@", webView);
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
    
    statusIndicator.layer.cornerRadius = 10.0;
    
    NSURL *requestURL = nil;
    if ([itemData objectForKey:@"url"]) {
        requestURL = [NSURL URLWithString:[itemData objectForKey:@"url"]];
    } else if ([itemData objectForKey:@"htmlfile"]) {
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[itemData objectForKey:@"htmlfile"]];
        requestURL = [NSURL fileURLWithPath:path];
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoad? %i", navigationType);
    if (initialLoadPerformed) {
        [hierarchyController loadURLRequestInLocalBrowser:request];
        return NO;
    } else {
        initialLoadPerformed = YES;
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Did start load.");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Did finish load.");
    [self setStatusTimer];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Did fail load with error: %@", error);
    [self setStatusTimer];
}

-(void) setStatusTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideStatusIndicator) userInfo:nil repeats:NO];
}

-(void) hideStatusIndicator {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    statusIndicator.alpha = 0;
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
}


- (void)dealloc {
    [itemData release], itemData = nil;
    [webView release], webView = nil;
    [statusIndicator release], statusIndicator = nil;
    self.hierarchyController = nil;
    [super dealloc];
}


@end
