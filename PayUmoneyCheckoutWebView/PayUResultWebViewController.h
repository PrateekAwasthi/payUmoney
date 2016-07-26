//
//  PayUResultWebViewController.h
//  PayUmoneyCheckoutWebView
//
//  Created by Ashish Kumar2 on 3/16/16.
//  Copyright © 2016 Ashish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayUResultWebViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)NSURLRequest *requestResultWebView;
@property (weak, nonatomic) IBOutlet UIWebView *resultWebView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewWeb;

@end
