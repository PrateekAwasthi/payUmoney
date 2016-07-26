//
//  PayUWebViewResponse.m
//  SampleAppPayUMoneyWeb
//
//  Created by Ashish Kumar2 on 2/16/16.
//  Copyright © 2016 Ashish Kumar2. All rights reserved.
//

#import "PayUWebViewResponse.h"
@interface PayUWebViewResponse()
@property BOOL delegateMethodCalled;

@end
@implementation PayUWebViewResponse

-(instancetype)init{
    self = [super init];
    if (self) {
        self.delegateMethodCalled = false;
    }
    return self;
}

// This method creates interface between JS and Webview
-(void)initialSetupForWebView:(UIWebView *)webview{
    if (!self.delegateMethodCalled) {
        self.js = [webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        self.js[@"PayU"] = self;
        [self.js evaluateScript:@"payu_js_callback();"];
    }
}

// This method gives callback in webview on successfull transaction
-(void)onPayuSuccess:(id)response{
    if([self.delegate respondsToSelector:@selector(PayUSuccessResponse:)])
    {
        [self.delegate PayUSuccessResponse:response];
        self.delegateMethodCalled = true;
    }
}

// This method gives callback in webview on failure transaction
-(void)onPayuFailure:(id)response{
    

    NSLog(@"The response from furl within:%@",response);
    if([self.delegate respondsToSelector:@selector(PayUFailureResponse:)])
    {
        [self.delegate PayUFailureResponse:response];
        self.delegateMethodCalled = true;
    }
}
-(void)dealloc{
    NSLog(@"Inside dealloc of bridge");
}

@end
