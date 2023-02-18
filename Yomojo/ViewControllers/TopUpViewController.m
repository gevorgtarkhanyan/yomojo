//
//  TopUpViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 15/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "TopUpViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import <PKRevealController/PKRevealController.h>

@interface TopUpViewController ()

@end

@implementation TopUpViewController
@synthesize urlData,lblEmail,lblAmountSlider,lblTotalAmount,SliderTopUp,phoneID;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    NSMutableArray *arrayDetails = [responseDict objectForKey:@"PERSONDETAILS"];
    NSMutableDictionary *personalDetails = [arrayDetails objectAtIndex:0];
    NSString *emailAdd = [personalDetails objectForKey:@"EMAILADDRESS"];
    lblEmail.text = [NSString stringWithFormat:@"The receipt will be emailed to: %@",emailAdd];
    
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    lblTotalAmount.text = @"$10";
}

- (IBAction)btnCancel:(id)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"0" forKey:@"fromNotification"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnConfirm:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(goTopUp) onTarget:self withObject:nil animated:YES];
    
}

- (IBAction)sliderValueChange:(id)sender {
    lblTotalAmount.text = [NSString stringWithFormat:@"$%.0f",SliderTopUp.value];
}

- (IBAction)btnBack:(id)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"0" forKey:@"fromNotification"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


-(void) goTopUp {
        NSString * strAmount = [self.lblTotalAmount.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/topup_credit/%@/%@/%@",strAmount, self.phoneID, self->sessionID];
        NSLog(@"strURL: %@",strPortalURL);
        
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
                NSString *errorMsg = [dictData objectForKey:@"errormsg"];
                if (errorMsg) {
                    errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"func_doTopup.cfm Failed -" withString:@""];
                    errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"ERROR" withString:@""];
                    [self alertStatus:errorMsg :@"Error"];
                } else {
                    NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
                    NSLog(@"responseData: %@",responseData);
                    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
                    NSString *responseText = [resultData objectForKey:@"responseText"];
                    NSString *RESULTTEXT = [resultData objectForKey:@"RESULTTEXT"];
                    
                    if (responseText) {
                        responseText = [responseText stringByReplacingOccurrencesOfString:@"func_doTopup.cfm Failed -" withString:@""];
                        responseText = [responseText stringByReplacingOccurrencesOfString:@"ERROR -" withString:@""];
                        
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@"Notification"
                                                     message:responseText
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                            self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
                            [self.view addSubview:self->HUB];
                            [self->HUB showWhileExecuting:@selector(gotoMainPage) onTarget:self withObject:nil animated:YES];
                        }];
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    }
                    if (RESULTTEXT) {
                        RESULTTEXT = [RESULTTEXT stringByReplacingOccurrencesOfString:@"func_doTopup.cfm Failed -" withString:@""];
                        RESULTTEXT = [RESULTTEXT stringByReplacingOccurrencesOfString:@"ERROR -" withString:@""];
                        [self alertStatus:RESULTTEXT :@"Notification"];
                    }
                }
            } else {
                NSLog(@"Error: %@",error);
                NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
                strError = [strError stringByReplacingOccurrencesOfString:@"ERROR -" withString:@""];
                [self alertStatus:strError:@"Error"];
            }
        });
}


- (void) gotoMainPage{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *phonesArray = [userLogin objectForKey:@"phonesArray"];
        NSString *withFamily = [userLogin objectForKey:@"withFamily"];
        NSString *showChildMenuOnly = [userLogin objectForKey:@"showChildMenuOnly"];
        
        MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
        mvc.urlData = self.urlData;
        mvc.phonesArray = phonesArray;
        mvc.withFamily = withFamily;
        mvc.fromFB = NO;
        
        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
        smvc.urlData = self.urlData;
        smvc.phonesArray = phonesArray;
        smvc.fromFB = NO;
        smvc.withFamily = withFamily;
        smvc.showChildMenuOnly = showChildMenuOnly;
        
        UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
        UIViewController *leftViewController = smvc;
        
        PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: revealController];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [navController setNavigationBarHidden:YES];
        self.window.backgroundColor = [UIColor whiteColor];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController: navController];
        [self.window makeKeyAndVisible];
    });
}

@end
