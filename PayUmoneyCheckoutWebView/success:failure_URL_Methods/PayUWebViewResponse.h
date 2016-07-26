//
//  PayUWebViewResponse.h
//  SampleAppPayUMoneyWeb
//
//  Created by Ashish Kumar2 on 2/16/16.
//  Copyright © 2016 Ashish Kumar2. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;
@import WebKit;

@protocol JavaScriptCallbackToApp <JSExport>

-(void)onPayuSuccess:(id)response;
-(void)onPayuFailure:(id)response;

@end

@protocol PayUAppWebViewResponseDelegate <NSObject>

-(void)PayUSuccessResponse:(id)response;
-(void)PayUFailureResponse:(id)response;

@end

@interface PayUWebViewResponse : NSObject<JavaScriptCallbackToApp>
-(void)initialSetupForWebView:(UIWebView *)webview;
@property (nonatomic,weak) id <PayUAppWebViewResponseDelegate> delegate;
@property (weak,nonatomic) JSContext *js;


@end
