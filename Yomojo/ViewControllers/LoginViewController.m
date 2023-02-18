//
//  LoginViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 06/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "LoginViewController.h"
#import "AppManager.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import "AccountListViewController.h"
#import "ForgotPasswordViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import "XmlReader.h"
#import "XMLDictionary.h"
#import "QuickGlanceViewController.h"
#import <PKRevealController/PKRevealController.h>
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "NoServiceViewController.h"
#import "Constants.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <SafariServices/SafariServices.h>
#import <Foundation/Foundation.h>
#define SIGN_UP_URL_STRING "https://yomojo.com.au"
#import "NSDate+Compare.h"

@interface NSDate (Compare)

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date;
-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date;
-(BOOL) isLaterThan:(NSDate*)date;
-(BOOL) isEarlierThan:(NSDate*)date;
//- (BOOL)isEqualToDate:(NSDate *)date; already part of the NSDate API

@end

@import Firebase;

@interface LoginViewController ()<UIViewControllerTransitioningDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnX_email;
@property (weak, nonatomic) IBOutlet UIButton *btnX_pass;
@property (weak, nonatomic) IBOutlet UIButton *btnEye;

@property (assign, nonatomic) BOOL showingPassword;
@property (assign, nonatomic) BOOL quickGlanceOpened;
@property (assign, nonatomic) BOOL tryAgainButtonSelected;

@property (strong, nonatomic) NSString *changedPassword;
@property (weak, nonatomic) NSDate *dateWithTimer;
@property (weak, nonatomic) NSDate *timerIncorrectCode;
@property (assign, nonatomic) int8_t *repeatedIncorrectCode;
@property (weak, nonatomic) NSTimer *codeTimer;
@property (weak, nonatomic) NSString *loginCode;
@property (weak, nonatomic) NSString *alertStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnX_email_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnX_email_trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnX_pass_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnX_pass_trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnEyeWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnEyeTrailing;

@end

@implementation LoginViewController
@synthesize txtEmailAdd, txtPassword,fbLoginURL,btnRemember,loginBtn,txtDeviceToken,btnQuickGlance,withFamily, scrollView, showChildMenuOnly, lblVersion, btnQuickGlanceHeight, btnQuickGlanceTop, backgroundView;

- (void)viewDidLoad {
    [super viewDidLoad];
    txtPassword.clearsOnBeginEditing = NO;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.backgroundView.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:240/255.0f green:64/255.0f blue:56/255.0f alpha:1.0f].CGColor, (id)[UIColor colorWithRed:252/255.0f green:130/255.0f blue:35/255.0f alpha:1.0f].CGColor];
    
    [self.backgroundView.layer insertSublayer:gradient atIndex:0];
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    
    lblVersion.text = [NSString stringWithFormat:@"v%@ (%@)",appVersionString, appBuildString];
    
    rememberCheckbox = YES;
    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = YES;
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:nil forKey:@"urlData"];
    NSString *userLoginData = [userLogin objectForKey:@"Username"];
    if(![userLoginData  isEqual: @""]) {
        txtEmailAdd.text = [userLogin objectForKey:@"Username"];
        txtPassword.text = [userLogin objectForKey:@"Password"];
        self.changedPassword = [userLogin objectForKey:@"Password"];
        rememberCheckbox = YES;
        
        self.btnX_email_width.constant = 20.0f;
        self.btnX_email.hidden = NO;
        self.btnX_email_trailing.constant = 10.0f;
        self.btnX_pass_width.constant = 20.0f;
        self.btnX_pass_trailing.constant = 10.0f;
        self.btnX_pass.hidden = NO;
        
        [btnRemember setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
    } else {
        rememberCheckbox = NO;
        txtEmailAdd.text = @"";
        txtPassword.text = @"";
        self.changedPassword = @"";
        [btnRemember setImage:nil forState:UIControlStateNormal];
    }
    
    CGRect scrollFrame;
    scrollFrame.origin = scrollView.frame.origin;
    scrollFrame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    scrollView.frame = scrollFrame;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width *2, self.view.frame.size.height);
    
    alertInt = 0;
    
    withFamily = @"NO";
    showChildMenuOnly = @"NO";
    
    self.title = @"Login";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    txtEmailAdd.clipsToBounds = YES;
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    if ([FBSDKAccessToken currentAccessToken]){
        [[FBSDKLoginManager new] logOut];
    }
    
    txtDeviceToken.text = [userLogin objectForKey:@"DeviceToken"];
    [txtPassword setReturnKeyType:UIReturnKeyDone];
    txtPassword.delegate = self;
    
    passedFBMethod = NO;
    
    NSString* enableQuickGlance = [userLogin objectForKey:@"quickGlanceEnable"];
    
    btnQuickGlance.hidden = ([enableQuickGlance isEqualToString:@"YES"]) ? NO : YES;
    btnQuickGlanceTop.constant = ([enableQuickGlance isEqualToString:@"YES"]) ? 15.0f : 0.0f;
    btnQuickGlanceHeight.constant = ([enableQuickGlance isEqualToString:@"YES"]) ? 22.0f : 0.0f;
    
    self->HUB = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self->HUB];
    [self.view bringSubviewToFront:self->HUB];
    [self.view layoutIfNeeded];
    
    
    if ([[userLogin objectForKey:@"loginWithCodeBool"]  isEqual: @"YES"]) {
        [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
    }else if ([[userLogin objectForKey:@"loginWithCodeBool"]  isEqual: @"NO"]) {
        _loginWithCodeView.hidden = YES;
        _loginWithCodeView.alpha = 0.0;
    } else if ([[userLogin objectForKey:@"loginWithCodeBool"]  isEqual: @"onTimer"]) {
        _loginWithCodeView.hidden = YES;
        _loginWithCodeView.alpha = 0.0;
        [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
    }
    
    _loginCode = [userLogin objectForKey:@"loginCode"];
    _loginWithCodeTextField.text = _loginCode;
    _dateWithTimer = [userLogin objectForKey:@"dateWithTimer"];
    _timerIncorrectCode = [userLogin objectForKey:@"timerIncorrectCode"];
    _repeatedIncorrectCode = 0;
    
    if ([_dateWithTimer isEarlierThan:[NSDate date]]) {
        [userLogin setObject:nil forKey:@"dateWithTimer"];
        _loginWithCodeTextField.text = @"";
        [userLogin setObject:nil forKey:@"loginCode"];
    }
    
    if ([_timerIncorrectCode isLaterThan:[NSDate date]]) {
        loginBtn.enabled = false;
        loginBtn.alpha = 0.5;
        _codeTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(stopTimerForIncorrecCode) userInfo:nil repeats:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (rememberCheckbox == NO) {
        [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = YES;
    }
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString* enableQuickGlance = [userLogin objectForKey:@"quickGlanceEnable"];
    if ([enableQuickGlance isEqual: @"YES"] && !self.quickGlanceOpened) {
        self.quickGlanceOpened = YES;
        [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
        QuickGlanceViewController *qvc = [[QuickGlanceViewController alloc] initWithNibName:@"QuickGlanceViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:qvc animated:NO];
    }
    btnQuickGlance.hidden = ([enableQuickGlance isEqualToString:@"YES"]) ? NO : YES;
    btnQuickGlanceTop.constant = ([enableQuickGlance isEqualToString:@"YES"]) ? 15.0f : 0.0f;
    btnQuickGlanceHeight.constant = ([enableQuickGlance isEqualToString:@"YES"]) ? 22.0f : 0.0f;
    
    [self.view layoutIfNeeded];
    
    _loginWithCodeTextFieldView.layer.cornerRadius = 10;
    _verifyCodeButton.layer.cornerRadius = 10;
    _tryAgainButton.layer.cornerRadius = 10;
}

-(BOOL) needsUpdate{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSURL* url = [NSURL URLWithString:@"https://yomojo.com.au/api/getVersionControl?os=ios"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* newVerionNum = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
    if ([newVerionNum floatValue] > [currentVersion floatValue]) {
        NSString *message = [NSString stringWithFormat:@"A new version of Yomojo app is available. Please update to version %@",newVerionNum];
        alertInt = 1;
        [self alertStatusWithButton:message :@"Update available" :@"Update"];
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (self.txtPassword.text.length > 0 && self.txtEmailAdd.text.length > 0) {
        [self doLogin:nil];
    } else {
        if (textField == self.txtEmailAdd && textField.text.length > 0 && self.txtPassword.text.length == 0){
            [self.txtPassword becomeFirstResponder];
        }
    }
    return YES;
}

- (IBAction)textFieldLoginWIthCodeView:(id)sender {
    _invalidCodeIcon.hidden = YES;
    _invalidCodeView.hidden = YES;
    
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location == 0 && range.length == 1 && textField.text.length == 1) {
        if (textField == self.txtEmailAdd) {
            self.btnX_email_trailing.constant = 0.0f;
            self.btnX_email_width.constant = 0.0f;
            self.btnX_email.hidden = YES;
        } else {
            self.changedPassword = textField.text;
            self.btnX_pass_trailing.constant = 0.0f;
            self.btnX_pass_width.constant = 0.0f;
            self.btnX_pass.hidden = YES;
        }
    } else if (textField.text.length + string.length > 0) {
        if (textField == self.txtEmailAdd) {
            self.btnX_email_width.constant = 20.0f;
            self.btnX_email_trailing.constant = 10.0f;
            self.btnX_email.hidden = NO;
        } else {
            self.changedPassword = textField.text;
            self.btnX_pass_width.constant = 20.0f;
            self.btnX_pass_trailing.constant = 10.0f;
            self.btnX_pass.hidden = NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.btnX_email_trailing.constant = 0.0f;
    self.btnX_email_width.constant = 0.0f;
    self.btnX_email.hidden = YES;
    self.btnX_pass_trailing.constant = 0.0f;
    self.btnX_pass_width.constant = 0.0f;
    self.btnX_pass.hidden = YES;
}

-(void)userLoginStatusChanged {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"id,name,email" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                      id result, NSError *error) {
            
            if (!error) {
                NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                NSString *fbUserId = [FBSDKAccessToken currentAccessToken].userID;
                NSString *fbEmail = [result objectForKey:@"email"];

                if ([[result objectForKey:@"email"] isKindOfClass:[NSNull class]] || ![result objectForKey:@"email"] || fbEmail.length == 0) {
                    [self alertStatus:@"You must provide a valid email address":@"Error"];
                } else {
                    NSString * strPortalURL = [NSString stringWithFormat:@"%@/signup_fb/%@/%@/%@/ios", PORTAL_URL, fbEmail,fbAccessToken, fbUserId];
                    
                    self.fbLoginURL = strPortalURL;
                    
                    [self->HUB showWhileExecuting:@selector(userLoginFB) onTarget:self withObject:nil animated:YES];
                }
            }
        }];
    }
}

-(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currrentStatus = [reachability currentReachabilityStatus];
    return currrentStatus;
}

- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            txtEmailAdd.frame = CGRectMake(txtEmailAdd.frame.origin.x, txtEmailAdd.frame.origin.y -30, txtEmailAdd.frame.size.width, txtEmailAdd.frame.size.height);
            txtPassword.frame = CGRectMake(txtPassword.frame.origin.x, txtPassword.frame.origin.y -30, txtPassword.frame.size.width, txtPassword.frame.size.height);
            _emailImageView.frame = CGRectMake(_emailImageView.frame.origin.x, _emailImageView.frame.origin.y -30, _emailImageView.frame.size.width, _emailImageView.frame.size.height);
            _passwordImageView.frame = CGRectMake(_passwordImageView.frame.origin.x, _passwordImageView.frame.origin.y -30, _passwordImageView.frame.size.width, _passwordImageView.frame.size.height);
            //Load 3.5 inch xib
        }
    }
}

-(void)setTimerForCode {
    NSCalendar *calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components=[NSDateComponents new];
    components.minute=30;
    NSDate *newDate=[calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:newDate forKey:@"dateWithTimer"];
}

-(void)setTimerForIncorrectCode {
    NSCalendar *calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components=[NSDateComponents new];
    components.minute=5;
    NSDate *newDate=[calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:newDate forKey:@"timerIncorrectCode"];
}

-(void)stopTimerForIncorrecCode {
    if ([self->_timerIncorrectCode isEarlierThan:[NSDate date]]) {
        self->loginBtn.enabled = true;
        self->loginBtn.alpha = 1.0;
        self.loginWithCodeTextField.text = @"";
        self.invalidCodeIcon.hidden = YES;
        [_codeTimer invalidate];
    }
}

-(void)dismissKeyboard {
    [txtEmailAdd resignFirstResponder];
    [txtPassword resignFirstResponder];
    [_loginWithCodeTextField resignFirstResponder];
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)loginWithCodeBackButtonAction:(id)sender {
    _loginWithCodeView.hidden = YES;
    _loginWithCodeView.alpha = 1.0;
    _loginWithCodeTextField.text = @"";
    _invalidCodeIcon.hidden = YES;
    _invalidCodeView.hidden = YES;
}

- (IBAction)verifyCodeButtonAction:(id)sender {
    if (_loginWithCodeTextField.text.length == 6){
        _invalidCodeIcon.hidden = YES;
        _invalidCodeView.hidden = YES;
        [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
    } else {
        _invalidCodeIcon.hidden = NO;
        _invalidCodeView.hidden = NO;
    }
}


- (IBAction)tryAgainButtonAction:(id)sender {
    _tryAgainButtonSelected = YES ;
    [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
    
}



- (IBAction)doLogin:(id)sender {
    [self dismissKeyboard];
    _tryAgainButtonSelected = NO;
    
    BOOL validEmailAdd = [self NSStringIsValidEmail:txtEmailAdd.text];
    
    if ([txtEmailAdd.text isEqualToString:@""]) {
        [self alertStatus:@"Please enter your username." :@"Error"];
    } else if (validEmailAdd == NO){
        [self alertStatus:@"Invalid email address":@"Error"];
    } else if ([txtPassword.text isEqualToString:@""]){
        [self alertStatus:@"Please enter your password." :@"Error"];
    } else {
        if ([self connected] == NotReachable){
            [self alertStatus:@"No Network connection." :@"Error"];
        } else {
            if (([[NSUserDefaults standardUserDefaults] boolForKey:@"biometricLogin"] == true || [[NSUserDefaults standardUserDefaults] objectForKey:@"biometricLogin"] == nil) && rememberCheckbox) {
                [self handleBiometricLoginWithLoginAction:YES];
            } else {
                if([_dateWithTimer isLaterThanOrEqualTo:[NSDate date]] && _loginCode != nil) // [NSDate date] is now
                {
                    [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
                }else {
                    [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
                }
            }
        }
    }
}

- (void)handleBiometricLoginWithLoginAction:(BOOL)loginAction {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        context.localizedFallbackTitle = @"";
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Touch ID to Log In to Yomojo"
                          reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success || (!success && error.code == -6)) {
                    if (success) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"biometricLogin"];
                    }
                    if (loginAction) {
                        if([self->_dateWithTimer isLaterThanOrEqualTo:[NSDate date]] && self->_loginCode != nil) // [NSDate date] is now
                        {
                            [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
                        }else {
                            [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
                        }
                    }
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Authentication Failed." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    } else {
        if (_loginWithCodeTextFieldView.hidden == NO) {
            
            if([_dateWithTimer isLaterThanOrEqualTo:[NSDate date]] && _loginCode != nil) // [NSDate date] is now
            {
                [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
            }else {
                [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
            }
        } else {
            if([_dateWithTimer isLaterThanOrEqualTo:[NSDate date]] && _loginCode != nil) // [NSDate date] is now
            {
                [self->HUB showWhileExecuting:@selector(userLogin) onTarget:self withObject:nil animated:YES];
            }else {
                [self->HUB showWhileExecuting:@selector(getLoginCode) onTarget:self withObject:nil animated:YES];
            }
        }
    }
}

-(NSMutableArray*) getPhones:(NSString *)clientID andSessionId:(NSString *)sessionId {
    NSMutableArray *tempPhonesArray = [[NSMutableArray alloc]init];
    NSMutableArray *phonesArray = [[NSMutableArray alloc]init];
    
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
        showChildMenuOnly = @"NO";

        for (int i = 0; i < [tempPhonesArray count]; i++) {
            NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
            NSString *phoneStatus = [dictPhones objectForKey:@"phone_status"];
            
            NSString *network = [dictPhones objectForKey:@"network"];
            if ([network isEqualToString:@"HWBB"]) {
                [dictPhones addEntriesFromDictionary:[self getUsageTotals:dictPhones withClientId:clientID andSessionId:sessionId]];
            }

            if ([phoneStatus isEqual: @"Active"]) {
                if ([network  isEqual: @"Subscription"]) {
                    NSLog(@"Child account");
                    withFamily = @"YES";
                } else {
                    [phonesArray addObject:dictPhones];
                    showChildMenuOnly = @"NO";
                }
            } else if ([phoneStatus isEqual: @"Waiting For Activation"]) {
                if ([network  isEqual: @"Subscription"]) {
                    withFamily = @"YES";
                    showChildMenuOnly = @"YES";
                } else {
                    [phonesArray addObject:dictPhones];
                }
            } else if ([phoneStatus isEqual: @"Activate Processing"]) {
                if ([network  isEqual: @"Subscription"]) {
                    withFamily = @"YES";
                    showChildMenuOnly = @"YES";
                } else {
                    [phonesArray addObject:dictPhones];
                }
            } else if ([phoneStatus isEqual: @"Port In Processing"]) {
                    [phonesArray addObject:dictPhones];
            }
        }
        
        if ([phonesArray count] <= 0){
            for (int i = 0; i < [tempPhonesArray count]; i++) {
                NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
                NSString *phoneStatus = [dictPhones objectForKey:@"phone_status"];
                NSString *network = [dictPhones objectForKey:@"network"];
                
                if ([network  isEqual: @"Subscription"]) {
                    if ([phoneStatus isEqual: @"Active"]) {
                        NSLog(@"Child account");
                        withFamily = @"YES";
                        showChildMenuOnly = @"YES";
                    }
                } else if ([network isEqualToString:@"HWBB"]) {
                    [dictPhones addEntriesFromDictionary:[self getUsageTotals:dictPhones withClientId:clientID andSessionId:sessionId]];
                }
            }
        }
    } else {
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError:@"Error"];
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


-(NSMutableArray*) getPhonesNew:(NSString *) strPhoneDetails{
    NSMutableArray *phonesArray = [[NSMutableArray alloc]init];
    strPhoneDetails = [strPhoneDetails stringByReplacingOccurrencesOfString: @"ALL\n" withString:@""];
    strPhoneDetails = [strPhoneDetails stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    strPhoneDetails = [strPhoneDetails stringByReplacingOccurrencesOfString: @"\t" withString:@""];
    strPhoneDetails = [strPhoneDetails stringByReplacingOccurrencesOfString: @"\f" withString:@""];
    
    NSDictionary *xmlDictionary = [NSDictionary dictionaryWithXMLString:strPhoneDetails];
    NSMutableArray *tempPhonesArray = [[NSMutableArray alloc]init];
    tempPhonesArray = [xmlDictionary objectForKey:@"phone"];
    
    for (int i = 0; i < [tempPhonesArray count]; i++) {
        NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
        NSMutableDictionary *phoneStatus = [dictPhones objectForKey:@"phone_status"];
        if ([phoneStatus isEqual: @"Active"]) {
            [phonesArray addObject:dictPhones];
        } else if ([phoneStatus isEqual: @"Waiting For Activation"]) {
            [phonesArray addObject:dictPhones];
        } else if ([phoneStatus isEqual: @"Activate Processing"]) {
            [phonesArray addObject:dictPhones];
        } else if ([phoneStatus isEqual: @"Port In Processing"]) {
            [phonesArray addObject:dictPhones];
        }
    }
    return phonesArray;
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

-(void) getLoginCode {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/mfa_login?username=%@&password=%@&os=ios",PORTAL_URL, [self urlencode:self.txtEmailAdd.text], [self urlencode:self.txtPassword.text]];
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = dictData;
            NSString *resultText = [resultData valueForKey:@"result" ];
            
            if ([resultText containsString:@"We've sent a link to your registered email. Please check your email now to complete login."]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                self->_loginWithCodeView.hidden = NO;
                self->_loginWithCodeView.alpha = 1.0;
                });
                
                [self->HUB showWhileExecuting:@selector(setTimerForCode) onTarget:self withObject:nil animated:YES];
                
                if (!self->rememberCheckbox) {
                    
                    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->btnRemember setImage:nil forState:UIControlStateNormal];
                    });
                    self->rememberCheckbox = NO;
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"" forKey:@"Username"];
                    [userLogin setObject:@"" forKey:@"Password"];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"quickGlanceUsername"];
                    [userLogin setObject:self.txtPassword.text forKey:@"quickGlancePassword"];
                } else {
                    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->btnRemember setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
                    });
                    self->rememberCheckbox = YES;
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"Username"];
                    [userLogin setObject:self.txtPassword.text forKey:@"Password"];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"quickGlanceUsername"];
                    [userLogin setObject:self.txtPassword.text forKey:@"quickGlancePassword"];
                }
            } else {
                if (self->_tryAgainButtonSelected) {
                    [self alertStatus:@"New code sent. Please check your email to proceed.":@"Info"];
                } else {
                    [self alertStatus:resultText:@"Error"];
                }
            }
        });
    } else {
        
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
        [self alertStatus:@"error":@"Error"];
    }
}


-(void) userLogin {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/login3?username=%@&password=%@&os=ios&code=%@",PORTAL_URL, [self urlencode:self.txtEmailAdd.text], [self urlencode:self.txtPassword.text], _loginWithCodeTextField.text];
    
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = dictData ;
            NSString *resultText = [NSString stringWithFormat:@"%@",resultData ];
            if ([resultText containsString:@"Success"]) {
                
                NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                [userLogin setObject:@"NO" forKey:@"loginWithCodeBool"];
                [userLogin setObject:self->_loginWithCodeTextField.text forKey:@"loginCode"];
                self->_repeatedIncorrectCode = 0;
                [userLogin setObject:nil forKey:@"timerIncorrectCode"];
                
                if (!self->rememberCheckbox) {
                    
                    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->btnRemember setImage:nil forState:UIControlStateNormal];
                    });
                    self->rememberCheckbox = NO;
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"" forKey:@"Username"];
                    [userLogin setObject:@"" forKey:@"Password"];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"quickGlanceUsername"];
                    [userLogin setObject:self.txtPassword.text forKey:@"quickGlancePassword"];
                } else {
                    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->btnRemember setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
                    });
                    self->rememberCheckbox = YES;
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"Username"];
                    [userLogin setObject:self.txtPassword.text forKey:@"Password"];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"quickGlanceUsername"];
                    [userLogin setObject:self.txtPassword.text forKey:@"quickGlancePassword"];
                }
                
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
                NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
                NSString * clientID = [responseDict objectForKey:@"CLIENTID"];
                NSString *sessionID = [responseDict objectForKey:@"SESSION_VAR"];
                
                
                [userLogin setObject:clientID forKey:@"clientID"];
       
                NSMutableArray *phonesArray = [self getPhones:clientID andSessionId:sessionID];
                
                if ([phonesArray count] > 0){
                    int selectedPhonesArrayIndexQG = [[userLogin objectForKey:@"quickGlanceIndex"] intValue];
                    NSMutableArray *phonesArrayQG = [userLogin objectForKey:@"quickGlancePhoneArray"];
                    NSString *quickGlanceEnable = [userLogin objectForKey:@"quickGlanceEnable"];
                    NSMutableDictionary *dictPhonesArrayTemp = [NSMutableDictionary new];
                    if (phonesArray.count > selectedPhonesArrayIndexQG + 1) {
                        dictPhonesArrayTemp = [phonesArray objectAtIndex:selectedPhonesArrayIndexQG];
                    }
                    
                    if ([quickGlanceEnable isEqual: @"YES"]) {
                        
                        BOOL isTheSameUser = YES;
                        if (phonesArrayQG.count == phonesArray.count) {
                            for (NSDictionary* dict in phonesArrayQG) {
                                if (![phonesArray containsObject:dict]) {
                                    isTheSameUser = NO;
                                }
                            }
                        } else {
                            isTheSameUser = NO;
                        }
                        
                        if (!isTheSameUser) {
                            [userLogin setObject:@"NO" forKey:@"quickGlanceEnable"];
                        }
                    }
                } else {
                    [userLogin setObject:@"NO" forKey:@"quickGlanceEnable"];
                }
                [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
                if ([phonesArray count] > 0) {
                    NSDictionary *firstObject = phonesArray[0];
                    if ([self->showChildMenuOnly isEqualToString:@"NO"] || ([firstObject valueForKey:@"phone_status"] && [[firstObject valueForKey:@"phone_status"] isEqualToString:@"Active"])) {
                        
                        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                        [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
                        [userLogin setObject:self.txtEmailAdd.text forKey:@"strUserName"];
                        [userLogin setObject:self.txtPassword.text forKey:@"strPassword"];
                        
                        [userLogin setObject:urlData forKey:@"urlData"];
                        [userLogin setObject:phonesArray forKey:@"phonesArray"];
                        [userLogin setObject:self.withFamily forKey:@"withFamily"];
                        [userLogin setObject:self.showChildMenuOnly forKey:@"showChildMenuOnly"];
                        
                        [FIRAnalytics logEventWithName:@"success_login"
                                            parameters:@{@"user": self.txtEmailAdd.text,@"full_text": @""}];
                        
                        MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
                        mvc.urlData = urlData;
                        mvc.phonesArray = phonesArray;
                        mvc.withFamily = self->withFamily;
                        mvc.fromFB = NO;
                        mvc.fromLogin = YES;
                        
                        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
                        smvc.urlData = urlData;
                        smvc.phonesArray = phonesArray;
                        smvc.fromFB = NO;
                        smvc.withFamily = self->withFamily;
                        smvc.showChildMenuOnly = self->showChildMenuOnly;
                        
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
                    } else {
                        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                        [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
                        [userLogin setObject:self.txtEmailAdd.text forKey:@"strUserName"];
                        [userLogin setObject:self.txtPassword.text forKey:@"strPassword"];
                        
                        [userLogin setObject:urlData forKey:@"urlData"];
                        [userLogin setObject:phonesArray forKey:@"phonesArray"];
                        [userLogin setObject:self.withFamily forKey:@"withFamily"];
                        [userLogin setObject:self.showChildMenuOnly forKey:@"showChildMenuOnly"];
                        
                        NoServiceViewController *mvc = [[NoServiceViewController alloc] initWithNibName:@"NoServiceViewController" bundle:[NSBundle mainBundle]];
                        mvc.urlData = urlData;
                        mvc.phonesArray = phonesArray;
                        mvc.withFamily = self.withFamily;
                        mvc.fromFB = NO;
                        mvc.fromLogin = YES;
                        
                        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
                        smvc.urlData = urlData;
                        smvc.phonesArray = phonesArray;
                        smvc.fromFB = NO;
                        smvc.withFamily = self->withFamily;
                        smvc.showChildMenuOnly = self->showChildMenuOnly;
                        
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
                    }
                } else {
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
                    [userLogin setObject:self.txtEmailAdd.text forKey:@"strUserName"];
                    [userLogin setObject:self.txtPassword.text forKey:@"strPassword"];
                    
                    [userLogin setObject:urlData forKey:@"urlData"];
                    [userLogin setObject:phonesArray forKey:@"phonesArray"];
                    [userLogin setObject:self.withFamily forKey:@"withFamily"];
                    [userLogin setObject:self.showChildMenuOnly forKey:@"showChildMenuOnly"];
                    
                    NoServiceViewController *mvc = [[NoServiceViewController alloc] initWithNibName:@"NoServiceViewController" bundle:[NSBundle mainBundle]];
                    mvc.urlData = urlData;
                    mvc.phonesArray = phonesArray;
                    mvc.withFamily = self.withFamily;
                    mvc.fromFB = NO;
                    mvc.fromLogin = YES;
                    
                    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
                    smvc.urlData = urlData;
                    smvc.phonesArray = phonesArray;
                    smvc.fromFB = NO;
                    smvc.withFamily = self->withFamily;
                    smvc.showChildMenuOnly = self->showChildMenuOnly;
                    
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
                }

            } else {
                resultText = [resultText stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
                resultText = [resultText stringByReplacingOccurrencesOfString:@"ERROR" withString:@""];
                
                if (![resultText  isEqual: @"(null)"]) {
                    if ([resultText  isEqual: @" Person not found"]) {
                        resultText = @"Person not found and/or password is incorrect";
                        
                    }
                    if ([resultText containsString:@"invalid code"]) {
                        self->_repeatedIncorrectCode += 1;
                        self->_invalidCodeIcon.hidden = NO ;
                        if (self.repeatedIncorrectCode == (int8_t*)3) {
                            [self alertStatus:@"Exceeded number of attempts. Please try again in 5 minutes.":@"Error"];
                            self.alertStatus = @"invalid code";
                        } else {
                            [self alertStatus:@"Invalid code":@"Error"];
                        }
                    }else if ([resultText containsString:@"expired"]) {
                    [self alertStatus:@"Expired":@"Error"];
                    }else {
                        [self alertStatus:resultText:@"Error"];
                    }
                } else {
                    [self alertStatus:@"Connection timedout":@"Error"];
                }
            }
        });
    } else {
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
        [self alertStatus:strError:@"Error"];
    }
}

-(void) userLoginFB {
    NSLog(@"strURL: %@",fbLoginURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fbLoginURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    dispatch_async(dispatch_get_main_queue() , ^{
        if (!error) {
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
            NSString *resultText = [NSString stringWithFormat:@"%@",[resultData objectForKey:@"RESULTTEXT"]];
            if (resultData && ![resultText isEqualToString:@"Success"]) {
                if ([FBSDKAccessToken currentAccessToken]){
                    [[FBSDKLoginManager new] logOut];
                }
                //                resultText = [resultText stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
                //                resultText = [resultText stringByReplacingOccurrencesOfString:@"ERROR - " withString:@""];
                //                if (resultText && resultText.length > 0) {
                //                    [self alertStatus:resultText:@"Error"];
                //                } else {
                [self alertStatus:@"You must provide a valid email address":@"Error"];
                //                 }
            } else {
                NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                [userLogin setObject:self.txtEmailAdd.text forKey:@"Username"];
                [userLogin setObject:self.txtPassword.text forKey:@"Password"];
                
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
                NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
                NSString * clientID = [responseDict objectForKey:@"CLIENTID"];
                NSString *sessionID = [responseDict objectForKey:@"SESSION_VAR"];
                
                NSMutableArray *phonesArray = [self getPhones:clientID andSessionId:sessionID];
                
                [userLogin setObject:clientID forKey:@"clientID"];
                
                 [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
                if ([phonesArray count] > 0) {
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
                    [userLogin setObject:urlData forKey:@"urlData"];
                    [userLogin setObject:phonesArray forKey:@"phonesArray"];
                    [userLogin setObject:self.withFamily forKey:@"withFamily"];
                    [userLogin setObject:self.showChildMenuOnly forKey:@"showChildMenuOnly"];
                    
                    MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
                    mvc.urlData = urlData;
                    mvc.phonesArray = phonesArray;
                    mvc.withFamily = self.withFamily;
                    mvc.fromFB = YES;
                    mvc.fromLogin = YES;
                    
                    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
                    smvc.urlData = urlData;
                    smvc.phonesArray = phonesArray;
                    smvc.fromFB = YES;
                    smvc.withFamily = self.withFamily;
                    
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
                } else {
                    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                    [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
                    
                    [userLogin setObject:urlData forKey:@"urlData"];
                    [userLogin setObject:phonesArray forKey:@"phonesArray"];
                    [userLogin setObject:self.withFamily forKey:@"withFamily"];
                    [userLogin setObject:self.showChildMenuOnly forKey:@"showChildMenuOnly"];
                    
                    NoServiceViewController *mvc = [[NoServiceViewController alloc] initWithNibName:@"NoServiceViewController" bundle:[NSBundle mainBundle]];
                    mvc.urlData = urlData;
                    mvc.phonesArray = phonesArray;
                    mvc.withFamily = self->withFamily;
                    mvc.fromFB = YES;
                    mvc.fromLogin = YES;
                    
                    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
                    smvc.urlData = urlData;
                    smvc.phonesArray = phonesArray;
                    smvc.fromFB = YES;
                    smvc.withFamily = self->withFamily;
                    smvc.showChildMenuOnly = self->showChildMenuOnly;
                    
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
                }
            }
        } else {
            if ([FBSDKAccessToken currentAccessToken]){
                [[FBSDKLoginManager new] logOut];
            }
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
            [self alertStatus:strError:@"Error"];
        }
    });
    
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString* enableQuickGlance = [userLogin objectForKey:@"quickGlanceEnable"];
    if ([enableQuickGlance  isEqual: @"YES"]) {
        [self showQuickGlanceView];
    }
}

- (void)showQuickGlanceView {
    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
    QuickGlanceViewController *qvc = [[QuickGlanceViewController alloc] initWithNibName:@"QuickGlanceViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:qvc animated:YES];
}


- (IBAction)btnForgotPass:(id)sender {
    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
    ForgotPasswordViewController *VC = [[ForgotPasswordViewController alloc]initWithNibName:@"ForgotPasswordViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)eyeButtonAction:(id)sender {
    [self.txtPassword endEditing:YES];
    if (self.showingPassword) {
        self.showingPassword = NO;
        self.txtPassword.secureTextEntry = YES;
        [self.btnEye setBackgroundImage:[UIImage imageNamed:@"eyeIconInvisible"] forState:UIControlStateNormal];
    } else {
        self.showingPassword = YES;
        self.txtPassword.secureTextEntry = NO;
        [self.btnEye setBackgroundImage:[UIImage imageNamed:@"eyeIconVisible"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnClearEntry:(id)sender {
    
    if ([sender tag] == 101) {
        if (txtEmailAdd.text.length > 0) {
            txtEmailAdd.text = @"";
            self.btnX_email_trailing.constant = 0.0f;
            self.btnX_email_width.constant = 0.0f;
            self.btnX_email.hidden = YES;
        }
    } else {
        if (txtPassword.text.length > 0) {
            txtPassword.text = @"";
            self.changedPassword = @"";
            self.btnX_pass_trailing.constant = 0.0f;
            self.btnX_pass_width.constant = 0.0f;
            self.btnX_pass.hidden = YES;
        }
    }
}

- (IBAction)btnRemember:(id)sender {
    if (!rememberCheckbox) {
        [btnRemember setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateNormal];
        rememberCheckbox = YES;
        [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
    } else {
        [btnRemember setImage:nil forState:UIControlStateNormal];
        rememberCheckbox = NO;
        [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = YES;
    }
}

- (IBAction)FBLoginBtn:(id)sender{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithPermissions:@[@"public_profile",@"email",@"user_likes",@"user_birthday"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                [self userLoginStatusChanged];
            } else {
                [self alertStatus:@"You must provide a valid email address":@"Error"];
            }
        }
    }];
}

- (IBAction)signUpBtn:(id)sender {
    NSURL *signUpUrl = [NSURL URLWithString:@SIGN_UP_URL_STRING];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:signUpUrl];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor colorWithRed:255/255.0f green:64/255.0f blue:10/255.0f alpha:1.0f];
    [self presentViewController:safariVC animated:YES completion:nil];
}

- (IBAction)btnQuickGlance:(id)sender {
    [AppManager sharedManager].shouldRemoveSavedLoginAndPassword = NO;
    QuickGlanceViewController *qvc = [[QuickGlanceViewController alloc] initWithNibName:@"QuickGlanceViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:qvc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([self.alertStatus isEqualToString:@"invalid code"]) {
            if (self.repeatedIncorrectCode == (int8_t*)3) {
                self->_repeatedIncorrectCode = 0;
                self->loginBtn.enabled = false;
                self->loginBtn.alpha = 0.5;
                self->_loginWithCodeView.hidden = YES;
                self->_loginWithCodeView.alpha = 0.0;
                _codeTimer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(stopTimerForIncorrecCode) userInfo:nil repeats:NO];
                [self->HUB showWhileExecuting:@selector(setTimerForIncorrectCode) onTarget:self withObject:nil animated:YES];
            }
        }
        if (alertInt == 1) {
            NSString *iTunesLink = @"https://itunes.apple.com/us/app/yomojo/id1180818081?mt=8";
            
            //https://itunes.apple.com/ph/app/yomojo/id1180818081?mt=8
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
}

#pragma mark - SFSafariViewControllerDelegate

- (void) safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
