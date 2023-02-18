//
//  SimActivatorViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 05/11/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "SimActivatorViewController.h"
#import "Constants.h"

@interface SimActivatorViewController ()

@end

@implementation SimActivatorViewController
@synthesize lblServiceName, lblMSN, lblSimNo, lblLabel, phoneID, clientId, alertInt;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    alertInt = 0;
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *getPhoneDetailsData = [userLogin objectForKey:@"getPhoneDetails"];
    NSMutableDictionary *resultData = [getPhoneDetailsData objectForKey:@"result"];
    NSString *strSIMNo = [resultData objectForKey:@"sim"];
    NSString *strLabel = [resultData objectForKey:@"label"];
    phoneID =  [[resultData objectForKey:@"id"] intValue];
    
    NSMutableArray *arrayPhoneNum =[self numberToArray:[resultData objectForKey:@"phonenumber"]];

    NSString *strPhoneNum = @"0";
    
    if (arrayPhoneNum.count >= 9) {
        
        strPhoneNum = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
    }

    lblServiceName.text = [NSString stringWithFormat:@"%@ - %@", strLabel, strPhoneNum];
    lblMSN.text = strPhoneNum;
    lblLabel.text = strLabel;
    NSString *phoneNumber = [strSIMNo stringByReplacingOccurrencesOfString:@"896102"
                                                               withString:@""];
    
    // checking if phone number can be formated
    if (phoneNumber.length == 13) {
        NSString *formatted = [NSString stringWithFormat: @"%@ %@ %@ %@", [phoneNumber substringWithRange:NSMakeRange(0,2)],[phoneNumber substringWithRange:NSMakeRange(2,5)],
                               [phoneNumber substringWithRange:NSMakeRange(7,5)],[phoneNumber substringWithRange:NSMakeRange(12,1)]];
        lblSimNo.text = formatted;
    } else {
        lblSimNo.text = phoneNumber;
    }
}

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCancel:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSubmit:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(startActivation) onTarget:self withObject:nil animated:YES];
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

- (void) startActivation {
    //activatesim?iccid=iccid&phoneid=phoneid
    //activateretailsim?iccid=iccid&nickname=nickname&subscription=subscription&clientid=clientid
    //changedate?new_date=dd/mm/yyyy&phoneid=phoneid&session_var=session_var
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *getPhoneDetailsData = [userLogin objectForKey:@"getPhoneDetails"];
    NSMutableDictionary *resultData = [getPhoneDetailsData objectForKey:@"result"];
    NSString *strSIMNo = [resultData objectForKey:@"sim"];
    phoneID =  [[resultData objectForKey:@"id"] intValue];
    NSString *txtSimNo = [strSIMNo stringByReplacingOccurrencesOfString:@"896102"
                                        withString:@""];


//https://yomojo.com.au/api/activatesim?iccid=5415429420478&phoneid=408570
//https://yomojo.com.au/api/activatesim?iccid=5415429420478&phoneid=408570&clientid=905841
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/activatesim?iccid=%@&phoneid=%d&clientid=%@",PORTAL_URL, txtSimNo, phoneID, clientId];
    
    NSLog(@"callURL: %@", strPortalURL);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSError * err = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if (!error) {
//        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary* dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL
                                                             options:NSJSONReadingAllowFragments
                                                               error:&err];
        
        int errorNum = [[dictData objectForKey:@"error"] intValue];
        
        if (errorNum == 1) {
            NSString *errorMsg = [dictData objectForKey:@"errormsg"];
            errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"func_doActivation.cfm Failed - ERROR -"
                                                withString:@""];
            [self alertStatus:errorMsg :@"Unsuccessful Activation"];
        }
        else{
            alertInt = 1;
            //            [self alertStatus:@"Your SIM will take up to 1 hour to activate. We’ll email you once it’s done and then just come back and choose your plan here in the dashboard." :@"Success"];
            
            [self alertStatus:@"Welcome to Yomojo—we're thrilled to have you as part of our awesome community! Your service may take up to 1 hour to activate. Keep an eye on your inbox as we'll email you once it's done." :@"Success"];
            
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertInt == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
