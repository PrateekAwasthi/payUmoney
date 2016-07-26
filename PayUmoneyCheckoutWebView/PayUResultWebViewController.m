//
//  PayUResultWebViewController.m
//  PayUmoneyCheckoutWebView
//
//  Created by Ashish Kumar2 on 3/16/16.
//  Copyright © 2016 Ashish Kumar. All rights reserved.
//

#import "PayUResultWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "PayUWebViewResponse.h"


@interface PayUResultWebViewController ()
@property WebViewJavascriptBridge* PayU;
@property(strong, nonatomic) PayUWebViewResponse *webViewResponse;


@end

@implementation PayUResultWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;

    //comment below method (i.e.[self configurePayUResponse];) only if you wish to write JS at your server side for surl/furl
    
  // [self configurePayUResponse];

    self.resultWebView.delegate=self;
       [self.resultWebView loadRequest:self.requestResultWebView];
    
    [self handleBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
    
    // implement bridge only if you wish to write JS at your server side for surl/furl
    
    _PayU = [WebViewJavascriptBridge bridgeForWebView:self.resultWebView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback)
             
             {
                 NSLog(@"ObjC received message from JS: %@", data);
                 if(data)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"passData" object:[NSMutableData dataWithData:data ]];
                     responseCallback(@"Response for message from ObjC");
                 }
                 
             }];
}

-(void)configurePayUResponse{
    self.webViewResponse = [PayUWebViewResponse new];
    self.webViewResponse.delegate = self;
}


#pragma mark - WebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self.webViewResponse initialSetupForWebView:self.resultWebView];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView

{
    webView.scrollView.delegate = self; // set delegate method of UISrollView
    webView.scrollView.maximumZoomScale = 20; // set as you want.
    webView.scrollView.minimumZoomScale = 1; // set as you want.
    
    //// Below two line is for iOS 6, If your app only supported iOS 7 then no need to write this.
    webView.scrollView.zoomScale = 2;
    webView.scrollView.zoomScale = 1;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

#pragma mark - delegate methods for surl/furl callback depricated one
-(void)PayUSuccessResponse:(id)response{
    NSLog(@"%@",response);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"paymentResponse" object:[NSMutableData dataWithData:response ]];
    
}
-(void)PayUFailureResponse:(id)response{
    NSLog(@"%@",response);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"paymentResponse" object:[NSMutableData dataWithData:response ]];
}

#pragma mark - UIScrollView Delegate Method

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.resultWebView.scrollView.maximumZoomScale = 20; // set similar to previous.
}

#pragma mark - Methods for handling back button

-(void)handleBackButton
{
    
    UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(goBack:)];
    
    self.navigationItem.leftBarButtonItem = bbtnBack;
}
- (void)goBack:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel"
                                                    message:@"Do you want to cancel the transaction?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}
@end
