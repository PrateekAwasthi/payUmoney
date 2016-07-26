//
//  HomeViewController.m
//  PayUmoneyCheckoutWebView
//
//  Created by Ashish Kumar2 on 3/16/16.
//  Copyright © 2016 Ashish Kumar. All rights reserved.
//
// Mendatory Paramameters to send to PayU server while requesting for payment
#import "HomeViewController.h"
#include <CommonCrypto/CommonDigest.h>
#define KEY_PRODUCTION @""
#define KEY_TEST @"OygoFs"
#define AMOUNT @"1.0"
#define PRODUCT_INFO @"i Phone"
#define FIRST_NAME @"Some Name"
#define EMAIL_ID @"someEmail@gmail.com"
#define UDF1 @"u1"
#define UDF2 @"u2"
#define UDF3 @"u3"
#define UDF4 @"u4"
#define UDF5 @"u5"
#define SURL @"https://payu.herokuapp.com/ios_success"
#define FURL @"https://payu.herokuapp.com/ios_failure"

#define SALT_PRODUCTION @""
#define SALT_TEST @"BV1QBwCv"

// optional parameters

#define PHONE @"1111111111"
#define OFFER_KEY @"test123@6622"

@interface HomeViewController ()
@property(nonatomic,strong)NSString *transactionID;
@property(nonatomic,strong)NSString *paymentHash;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldKey;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldTransactionID;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldAmount;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldProductInfo;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUdf1;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUdf2;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUdf3;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUdf4;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUdf5;
typedef void (^urlRequestCompletionBlock)(NSURLResponse *response, NSData *data, NSError *connectionError);

@property(nonatomic,strong)NSMutableURLRequest *req;
@property(nonatomic,strong)NSMutableData *dataResponse;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) UITextField *txtFieldActive;
@property (weak, nonatomic) IBOutlet UIButton *payNowBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // notifications for surl/furl responses
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"passData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"paymentResponse" object:nil];
   
    [self addKeyboardNotifications];
    [self dismissKeyboardOnTapOutsideTextField];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.transactionID=[self getTransactionID];
    self.txtFieldKey.text=KEY_TEST;
    self.txtFieldTransactionID.text=self.transactionID;
    self.txtFieldAmount.text=AMOUNT;
    self.txtFieldProductInfo.text=PRODUCT_INFO;
    self.txtFieldFirstName.text=FIRST_NAME;
    self.txtFieldEmail.text=EMAIL_ID;
    self.txtFieldUdf1.text=@"u1";
    self.txtFieldUdf2.text=@"u2";
    self.txtFieldUdf3.text=@"u3";
    self.txtFieldUdf4.text=@"u4";
    self.txtFieldUdf5.text=@"u5";
    self.navigationController.navigationBarHidden=YES;
    [self keyBoardHandlingMethods];
    self.payNowBtn.enabled=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - surl/furl response method

-(void)dataReceived:(NSNotification *)noti
{
    NSLog(@"dataReceived internally from surl/furl:%@", noti.object);
    [self.navigationController popToRootViewControllerAnimated:YES];
    _dataResponse=noti.object;
    if(_dataResponse)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"paymentResponse" message:_dataResponse delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
        [alert show];
    }

}

#pragma mark - Method for Pay Now Button

- (IBAction)PayNowBtn:(id)sender {
    // PayU Test URL
    //NSURL *restURL=[NSURL URLWithString:@"https://test.payu.in/_payment"];
    // PayU Production URL
  NSURL *restURL=[NSURL URLWithString:@"https://secure.payu.in/_payment"];
    self.req=[NSMutableURLRequest requestWithURL:restURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.req.HTTPMethod = @"POST";
    NSString *hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@||||||%@",KEY_TEST,self.txtFieldTransactionID.text,self.txtFieldAmount.text,self.txtFieldProductInfo.text,self.txtFieldFirstName.text,self.txtFieldEmail.text,self.txtFieldUdf1.text,self.txtFieldUdf2.text,self.txtFieldUdf3.text,self.txtFieldUdf4.text,self.txtFieldUdf5.text,SALT_TEST];
    self.paymentHash = [self createCheckSumString :hashValue];

   
            
            // this is the data need to send at PayU Server
           NSString *postData=[NSString stringWithFormat:@"service_provider=payu_paisa&key=%@&txnid=%@&amount=%@&productinfo=%@&firstname=%@&email=%@&udf1=%@&udf2=%@&udf3=%@&udf4=%@&udf5=%@&surl=%@&furl=%@&phone=%@&hash=%@",self.txtFieldKey.text,self.txtFieldTransactionID.text,self.txtFieldAmount.text,self.txtFieldProductInfo.text,self.txtFieldFirstName.text,self.txtFieldEmail.text,self.txtFieldUdf1.text,self.txtFieldUdf2.text,self.txtFieldUdf3.text,self.txtFieldUdf4.text,self.txtFieldUdf5.text,SURL,FURL,PHONE,self.paymentHash];
                            [self.req setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [self.req setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    PayUResultWebViewController *resultVC=[[PayUResultWebViewController alloc]initWithNibName:@"PayUResultWebViewController" bundle:nil];
            resultVC.requestResultWebView=self.req;
    [self.navigationController pushViewController:resultVC animated:YES];
    
    
    self.payNowBtn.enabled=NO;
}
-(NSString*)getTransactionID
{
    NSDateFormatter *currentDate=[[NSDateFormatter alloc]init];
    [currentDate setDateFormat:@"yyyyMMddhhmmss"];
    NSLog(@"The date is: %@",[currentDate stringFromDate:[NSDate date]]);
    NSString *dateString=[currentDate stringFromDate:[NSDate date]];
    NSLog(@" Now the date is:%@",dateString);
    return dateString;
}



-(void)keyBoardHandlingMethods
{
    self.txtFieldKey.delegate=self;
    self.txtFieldTransactionID.delegate=self;
    self.txtFieldAmount.delegate=self;
    self.txtFieldProductInfo.delegate=self;
    self.txtFieldFirstName.delegate=self;
    self.txtFieldEmail.delegate=self;
    self.txtFieldUdf1.delegate=self;
    self.txtFieldUdf2.delegate=self;
    self.txtFieldUdf3.delegate=self;
    self.txtFieldUdf4.delegate=self;
    self.txtFieldUdf5.delegate=self;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    [self.txtFieldKey resignFirstResponder];
    [self.txtFieldAmount resignFirstResponder];
    [self.txtFieldTransactionID resignFirstResponder];
    [self.txtFieldTransactionID resignFirstResponder];
    [self.txtFieldFirstName resignFirstResponder];
    [self.txtFieldEmail resignFirstResponder];
    [self.txtFieldUdf1 resignFirstResponder];
    [self.txtFieldUdf2 resignFirstResponder];
    [self.txtFieldUdf3 resignFirstResponder];
    [self.txtFieldUdf4 resignFirstResponder];
    [self.txtFieldUdf5 resignFirstResponder];
    return YES;
}
#pragma mark - Keyboard notification add or remove

-(void)addKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)removeKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma Dismiss Keyboard On Tap Outside TextField

-(void)dismissKeyboardOnTapOutsideTextField{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.view endEditing:NO];
    //    [self.txtFieldActive resignFirstResponder];
}
#pragma Keyboard delegate methods

// Called when the UIKeyboardDidShowNotification is received
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+0, 0.0);
    self.scrollView.contentInset = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    int height = self.txtFieldActive.superview.frame.origin.y;
    CGPoint point = CGPointMake(self.txtFieldActive.frame.origin.x, height + self.txtFieldActive.frame.origin.y);
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, point) ) {
        CGRect rect = self.txtFieldActive.frame;
        rect.origin.y = height + self.txtFieldActive.frame.origin.y;
        [self.scrollView scrollRectToVisible:rect animated:YES];
    }
}
// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    // scroll back..
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}




- (NSString *) createCheckSumString:(NSString *)input

{
    
          const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    
        NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
        uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    
    
        // This is an iOS5-specific method.
    
        // It takes in the data, how much data, and then output format, which in this case is an int array.
    
        CC_SHA512(data.bytes, (int)data.length, digest);
    
    
    
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    
        for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
    
            [output appendFormat:@"%02x", digest[i]];
    
        }
    
        return output;
    
   // return @"YUNOGENERATEHASHFROMSERVER";
    
}


@end
