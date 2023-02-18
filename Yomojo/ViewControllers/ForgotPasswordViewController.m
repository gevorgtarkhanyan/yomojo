//
//  ForgotPasswordViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 10/03/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "LoginViewController.h"
//#import <Google/Analytics.h>


@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController
@synthesize txtEmail;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"ForgotPassword Page"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    alertError = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currrentStatus = [reachability currentReachabilityStatus];
    return currrentStatus;
}



-(void)dismissKeyboard {
    [txtEmail resignFirstResponder];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnResetPass:(id)sender {
    BOOL validEmailAdd = [self NSStringIsValidEmail:txtEmail.text];
    if ([txtEmail.text isEqual: @""]){
        alertError = 1;
        [self alertStatus:@"Enter your email address" :@"Failed"];
    }
    else if (validEmailAdd == NO) {
        alertError = 1;
        [self alertStatus:@"Invalid email address" :@"Failed"];
    }
    else{
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        HUB.labelText = @"";
        [HUB showWhileExecuting:@selector(resetPass) onTarget:self withObject:nil animated:YES];
    }
}

- (void) resetPass{
    //https://yomojo.com.au/api/resetpassword/$email
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/resetpassword/%@",txtEmail.text];
    NSLog(@"strURL: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseString: %@",responseData);
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        
        NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
        NSMutableDictionary *attributesData = [resultData objectForKey:@"@attributes"];
        NSString *resultText = [NSString stringWithFormat:@"%@",[attributesData objectForKey:@"RESULTTEXT"]];
        
        if ([resultText isEqualToString:@"Success"]){
            [self alertStatus:@"Password reset instructions sent to your email":@"Success"];
        }
        else{
            alertError = 1;
            [self alertStatus:@"Client not found":@"Error"];
        }
    }
    else{
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError:@"Error"];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertError == 0) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end
