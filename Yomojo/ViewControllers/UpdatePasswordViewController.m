//
//  UpdatePasswordViewController.m
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "LoginViewController.h"
//#import <Google/Analytics.h>

@interface UpdatePasswordViewController ()

@end

@implementation UpdatePasswordViewController
@synthesize urlData,phonesArrayIndex,phonesArray,txtNewPassword,txtExistingPassword,txtConfirmPassword,btnShowPass;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"UpdatePassword Page"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    btnShowPass.layer.borderWidth = 0.5;
    btnShowPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
    alertError = 0;
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [txtNewPassword resignFirstResponder];
    [txtConfirmPassword resignFirstResponder];
    [txtExistingPassword resignFirstResponder];
}


-(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currrentStatus = [reachability currentReachabilityStatus];
    return currrentStatus;
}

-(IBAction)backBtnAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSString*) isPasswordValid:(NSString *)pwd {
//    NSCharacterSet *upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
//    NSCharacterSet *lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];

    if ( [pwd length]< 8 || [pwd length]> 32 )
        return @"Your password must be between 8-32 characters";

//    NSRange rang;
//    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
//    if ( !rang.length )
//        return @"Your password must contain at least one letter - (a-z, A-Z)";
//    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
//    if ( !rang.length )
//        return @"Your password must contain at least one number - (0-9)";
//    rang = [pwd rangeOfCharacterFromSet:upperCaseChars];
//    if ( !rang.length )
//        return NO;  // no uppercase letter;
//    rang = [pwd rangeOfCharacterFromSet:lowerCaseChars];
//    if ( !rang.length )
//        return NO;  // no lowerCase Chars;

    return nil;
}

- (IBAction)btnSave:(id)sender {
    if ([txtExistingPassword.text isEqualToString:@""]) {
        alertError = 1;
        [self alertStatus:@"Enter existing password." :@"Error"];
    }
    else{
        NSString *newPassValid = [self isPasswordValid:txtNewPassword.text];
        if ([txtNewPassword.text isEqualToString:@""]) {
             alertError = 1;
            [self alertStatus:@"Enter new password." :@"Error"];
        }
        else if ([txtConfirmPassword.text isEqualToString:@""]) {
             alertError = 1;
            [self alertStatus:@"Please confirm your password." :@"Error"];
        }
        else if (newPassValid){
            alertError = 1;
            [self alertStatus:newPassValid :@"Error"];
        }
        else if ([txtNewPassword.text isEqual:txtConfirmPassword.text]) {
            if ([self connected] == NotReachable){
                 alertError = 1;
                [self alertStatus:@"No Network connection." :@"Error"];
            }
            else{
                HUB = [[MBProgressHUD alloc]initWithView:self.view];
                [self.view addSubview:HUB];
                [HUB showWhileExecuting:@selector(callURLChangePass) onTarget:self withObject:nil animated:YES];
            }
        }
        else{
            alertError = 1;
            [self alertStatus:@"Password did not match" :@"Error"];
        }
    }
}

- (IBAction)btnCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnShowPass:(id)sender {
    if (!showPassCheckbox) {
        [btnShowPass setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
        showPassCheckbox = YES;
        txtNewPassword.secureTextEntry = NO;
        txtExistingPassword.secureTextEntry = NO;
        txtConfirmPassword.secureTextEntry = NO;
    }
    else{
        [btnShowPass setImage:nil forState:UIControlStateNormal];
        showPassCheckbox = NO;
        txtNewPassword.secureTextEntry = YES;
        txtExistingPassword.secureTextEntry = YES;
        txtConfirmPassword.secureTextEntry = YES;
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

- (void) callURLChangePass{
    //NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];

    
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/update_password2?clientid=%@&sess_var=%@&existing_password=%@&new_password=%@&confirm_password=%@",clientID,sessionID,[self urlencode:txtExistingPassword.text],[self urlencode:txtNewPassword.text],[self urlencode:txtConfirmPassword.text]];

    strPortalURL = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
        NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
        NSMutableDictionary *attributes = [resultData objectForKey:@"@attributes"];
        NSString *resultText = [attributes objectForKey:@"RESULTTEXT"];
        
        if ([resultText  isEqual: @"Success"]){
            alertError = 0;
            [self alertStatus:@"Password has been UPDATED." :@"Success"];
        }
        else{
            resultText = [resultData objectForKey:@"RESULTTEXT"];
            alertError = 1;
            if (resultText) {
                resultText = [resultText stringByReplacingOccurrencesOfString:@"func_setPassword.cfm Failed -" withString:@""];
                resultText = [resultText stringByReplacingOccurrencesOfString:@"ERROR -" withString:@""];
                resultText = [resultText stringByReplacingOccurrencesOfString:@"old password incorrect" withString:@"Invalid existing password"];
                
                [self alertStatus:resultText :@"Error"];
            }
            else{
                [self alertStatus:@"An error was occured, Please check your current password." :@"Error"];
            }
        }
    }
    else{
        alertError = 1;
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
