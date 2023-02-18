//
//  BiometricViewController.m
//  Yomojo
//
//  Created by Lilit on 12/11/18.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "BiometricViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <PKRevealController/PKRevealController.h>
#import "NoServiceViewController.h"
#import "SideMenuViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "NSDate+Compare.h"
#import <Foundation/Foundation.h>

@interface NSDate (Compare)

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date;
-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date;
-(BOOL) isLaterThan:(NSDate*)date;
-(BOOL) isEarlierThan:(NSDate*)date;
//- (BOOL)isEqualToDate:(NSDate *)date; already part of the NSDate API

@end

@import Firebase;

@interface BiometricViewController ()

@property (strong, nonatomic) NSString *showChildMenuOnly;
@property (strong, nonatomic) NSString *withFamily;
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) NSDate *dateWithTimer;
@property (weak, nonatomic) NSDate *timerIncorrectCode;
@property (weak, nonatomic) NSString *loginCode;

@end

@implementation BiometricViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleBiometricLoginWithLoginAction];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    _dateWithTimer = [userLogin objectForKey:@"dateWithTimer"];
    _timerIncorrectCode = [userLogin objectForKey:@"timerIncorrectCode"];
    _loginCode = [userLogin objectForKey:@"loginCode"];
    
}

- (void)handleBiometricLoginWithLoginAction {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        context.localizedFallbackTitle = @"";
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Touch ID to Log In to Yomojo"
                          reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success && ([self->_timerIncorrectCode isEarlierThan:[NSDate date]] || self->_timerIncorrectCode == nil)) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"biometricLogin"];
                    MBProgressHUD *HUB = [[MBProgressHUD alloc]initWithView:self.view];
                    [self.view addSubview:HUB];
                    [self.view bringSubviewToFront:HUB];
                    [HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
                    
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Authentication Failed." preferredStyle:UIAlertControllerStyleAlert];
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"NO" forKey:@"loginWithCodeBool"];
                    [self openLoginViewController];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self openLoginViewController];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    }
}

- (NSString *)urlencode:(NSString *)stringToEncode{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[stringToEncode UTF8String];
    u_long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(void) userLogin {
    
    if([_dateWithTimer isLaterThanOrEqualTo:[NSDate date]] && _loginCode != nil) // [NSDate date] is now
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
            [userLogin setObject:@"onTimer" forKey:@"loginWithCodeBool"];
            [self openLoginViewController];
        });
    }else {
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/mfa_login?username=%@&password=%@&os=ios",PORTAL_URL, [self urlencode:[userLogin objectForKey:@"Username"]], [self urlencode:[userLogin objectForKey:@"Password"]]];
        
        NSLog(@"strURL: %@",strPortalURL);
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        request.HTTPMethod = @"GET";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                [userLogin setObject:@"YES" forKey:@"loginWithCodeBool"];
                [self openLoginViewController];
            } else {
                NSLog(@"Error: %@",error);
                NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
                strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:strError preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }
    
    
}

- (void)openLoginViewController {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [navController setNavigationBarHidden:YES];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController: navController];
    [self.window makeKeyAndVisible];
}

-(NSMutableArray*) getPhones:(NSString *) clientID andSessionId:(NSString *)sessionId {
    NSMutableArray *tempPhonesArray = [[NSMutableArray alloc]init];
    NSMutableArray *phonesArray = [[NSMutableArray alloc]init];
    //NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/get_phones/%@/",clientID];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/get_phones/%@/", PORTAL_URL, clientID];
    
    NSLog(@"strURL: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        tempPhonesArray = [dictData objectForKey:@"result"];
        self.showChildMenuOnly = @"NO";
        for (int i = 0; i < [tempPhonesArray count]; i++) {
            NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
            NSString *phoneStatus = [dictPhones objectForKey:@"phone_status"];
            //            NSString *planid = [dictPhones objectForKey:@"planid"];
            NSString *network = [dictPhones objectForKey:@"network"];
            if ([network isEqualToString:@"HWBB"]) {
                [dictPhones addEntriesFromDictionary:[self getUsageTotals:dictPhones withClientId:clientID andSessionId:sessionId]];
            }
            if ([phoneStatus isEqual: @"Active"]) {
              
                if ([network  isEqual: @"Subscription"]) {
                
                    NSLog(@"Child account");
                    self.withFamily = @"YES";
                    
                } else {
                    
                    [phonesArray addObject:dictPhones];
                    self.showChildMenuOnly = @"NO";
                    
                }
                
            } else if ([phoneStatus isEqual: @"Waiting For Activation"]) {
                
                [phonesArray addObject:dictPhones];
                
            } else if ([phoneStatus isEqual: @"Activate Processing"]) {
              
                [phonesArray addObject:dictPhones];
                
            } else if ([phoneStatus isEqual: @"Port In Processing"]) {
                
                [phonesArray addObject:dictPhones];
                
            }
        }
        
        if ([phonesArray count] <= 0){
            for (int i = 0; i < [tempPhonesArray count]; i++) {
                NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
                NSString *phoneStatus = [dictPhones objectForKey:@"phone_status"];
                //                NSString *planid = [dictPhones objectForKey:@"planid"];
                NSString *network = [dictPhones objectForKey:@"network"];
                
                if ([network  isEqual: @"Subscription"]) {
                    if ([phoneStatus isEqual: @"Active"]) {
                        NSLog(@"Child account");
                        self.withFamily = @"YES";
                        self.showChildMenuOnly = @"YES";
                    }
                } else if ([network isEqualToString:@"HWBB"]) {
                    [dictPhones addEntriesFromDictionary:[self getUsageTotals:dictPhones withClientId:clientID andSessionId:sessionId]];
                }
            }
        }
    }
    else{
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:strError preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    return phonesArray;
}

- (NSDictionary *) getUsageTotals:(NSDictionary *)phoneDetail withClientId:(NSString *)clientId andSessionId:(NSString *)sessionId{
    
    NSString *phoneID = [phoneDetail objectForKey:@"id"];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getusagetotals?phoneid=%@&clientid=%@&session_var=%@", PORTAL_URL, phoneID, clientId, sessionId];
    
    NSLog(@"strURL: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        
        NSString *datausageMB = @"";
        NSString *datausageLimitMB = @"";
        
        NSString *datausageMBmur = [NSString stringWithFormat:@"%@", dictData[@"result"][@"mur"][@"datausageMB"]];
        NSString *datausageMBcdr = [NSString stringWithFormat:@"%@", dictData[@"result"][@"cdr"][@"datausageMB"]];
        
        NSString *datausageLimitMBmur = [NSString stringWithFormat:@"%@", dictData[@"result"][@"mur"][@"datausagelimitMB"]];
        NSString *datausageLimitMBcdr = [NSString stringWithFormat:@"%@", dictData[@"result"][@"cdr"][@"datausagelimitMB"]];
        
        if ([datausageMBcdr floatValue] > [datausageMBmur floatValue]) {
            datausageMB = datausageMBcdr;
        } else {
            datausageMB = datausageMBmur;
        }
        
        if ([datausageLimitMBcdr floatValue] > [datausageLimitMBmur floatValue]) {
            datausageLimitMB = datausageLimitMBcdr;
        } else {
            datausageLimitMB = datausageLimitMBmur;
        }
        return @{@"datausageMB":datausageMB,
                 @"datausagelimitMB":datausageLimitMB
        };
    } else {
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError:@"Error"];
        return [NSDictionary new];
    }
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

- (void) alertStatusWithButton:(NSString *)msg :(NSString *)title :(NSString *)buttonName
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

@end
