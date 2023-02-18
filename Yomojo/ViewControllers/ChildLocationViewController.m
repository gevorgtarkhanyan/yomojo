//
//  ChildLocationViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

@import Foundation;
#import <CommonCrypto/CommonDigest.h>
#import "ChildLocationViewController.h"
#import "ChildInfoTableViewCell.h"
#import <PKRevealController/PKRevealController.h>
#import "MapLocationViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import "Constants.h"
#import "HyTransitions.h"
#import "HyLoginButton.h"

@class SocketIOClient;

@interface ChildLocationViewController ()<UIViewControllerTransitioningDelegate>
@property (readwrite, nonatomic) SocketIOClient* socket;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@end

@implementation ChildLocationViewController
@synthesize tableChild,myCheckBox,childArray,selectedCell,urlData,clientID,sessionID,authToken,photoInfo,onlineInfo,selectedChild,LCURLLocation, showLocationBtn, childPhotoURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    childArray = [[NSMutableArray alloc]init];
    selectedChild = [[NSMutableArray alloc] init];
    
    LCURLLocation = FAMILY_URL;
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    
    photoInfo = [[NSMutableDictionary alloc] init];
    photoInfo = [[userLogin objectForKey:@"photoInfo"] mutableCopy];
    if (!photoInfo) {
        photoInfo = [[NSMutableDictionary alloc] init];
    }
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getAutToken) onTarget:self withObject:nil animated:YES];
}

- (void)createPresentControllerButton{
    HyLoginButton *loginButton = [[HyLoginButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [loginButton setBackgroundColor:[UIColor colorWithRed:1 green:0.f/255.0f blue:128.0f/255.0f alpha:1]];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(PresentViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)PresentViewController:(HyLoginButton *)button {
    typeof(self) __weak weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_switchButton.on) {
            [button succeedAnimationWithCompletion:^{
                if (weak.switchButton.on) {
                    [weak didPresentControllerButtonTouch];
                }
            }];
        } else {
            [button failedAnimationWithCompletion:^{
                if (weak.switchButton.on) {
                    [weak didPresentControllerButtonTouch];
                }
            }];
        }
    });
}

- (void)didPresentControllerButtonTouch {    
    UIViewController *controller = [MapLocationViewController new];
    controller.transitioningDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transitioningDelegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
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


-(void) applicationBecomeActive{
//    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
//    NSString *fromNotification = [userLogin objectForKey:@"fromNotification"];
//    if ([fromNotification  isEqual: @"1"]) {
//        MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
//        mvc.urlData = urlData;
//        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
//        smvc.urlData = urlData;
//        UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
//        UIViewController *leftViewController = smvc;
//        PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
//        [self.navigationController setNavigationBarHidden:YES];
//        [self.navigationController pushViewController:revealController animated:YES];
//    }
}

- (void)getAutToken{
    LCURLLocation = FAMILY_URL;

    NSString* strHash = [NSString stringWithFormat:@"%@-%@-6uJOCglydQexaZBeJfeEZrpNsxOv6060MmtTm5wVWrMnZ5zA26CXlB7BlInE8fzpOrgvEwHu04YU90KtnAMaS4FITQBY7Xj0B1DAI9n2hNCnh2yQ4djFcrvO",clientID,sessionID];
    
    NSString *hashOutput = [self sha1:strHash];
    NSLog(@"hashOutput: %@",hashOutput);
    
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/get-auth-token",LCURLLocation];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];

    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:clientID forKey:@"client_id"];
    [request setPostValue:sessionID forKey:@"session_var"];
    [request setPostValue:hashOutput forKey:@"hash"];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        authToken = [dictData objectForKey:@"auth_token"];
        [self getChildList];
    }
    else{
        
    }
}

-(void) getChildList {
    LCURLLocation = FAMILY_URL;
    
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/children",LCURLLocation];
    NSLog(@"URL: %@",strPortalURL);
    NSLog(@"Auth-Token: %@",authToken);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:authToken forHTTPHeaderField:@"Auth-Token"];
    //NSURLResponse * response = nil;
    //NSError * error = nil;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response,
                                               NSData * purlData,
                                               NSError * error) {
                               if (!error){
                                   NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
                                   NSLog(@"responseData: %@",responseData);
                                   childArray = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];

                                   for (int i=0; i < [childArray count]; i++){
                                       [selectedChild insertObject:@"NO" atIndex:i];
                                   }

                                   [tableChild reloadData];
                               }
                               else{
                                   NSLog(@"Error: %@",error);
                               }
                           }];
}

-(NSString*) sha1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (void)checkOnlineStatusSelected {
    LCURLLocation = FAMILY_URL;
    onlineInfo = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *selectedChildArray = [[NSMutableArray alloc]init];
    for (int i=0; i < [selectedChild count]; i++)  {
        BOOL boolSelected = [[selectedChild objectAtIndex:i] boolValue];
        if (boolSelected == YES) {
            NSMutableDictionary* childDict = [childArray objectAtIndex:i];
            [selectedChildArray addObject:childDict];
        }
    }
    
    for (int i=0; i < [selectedChildArray count]; i++)  {
        NSMutableDictionary* childDict = [selectedChildArray objectAtIndex:i];
        NSString* childID = [childDict objectForKey:@"id"];
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/request_current_location/%@",LCURLLocation,childID];
        NSLog(@"strPortalURL: %@",strPortalURL);
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request addRequestHeader:@"Auth-Token" value:authToken];
        [request startSynchronous];
        NSData *purlData = [request responseData];
        NSError *error = [request error];
        if (!error) {
            NSString* strMessage = @"0";
            
            NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseData Online: %@",responseData);
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            strMessage = [dictData objectForKey:@"success"];
            NSString *messageString = [dictData objectForKey:@"message"];
            NSString *messageKey = [NSString stringWithFormat:@"%@_message",childID];
            if ([strMessage intValue] == 1) {
                [onlineInfo setObject:@"0" forKey:childID];
            }
            else{
                [onlineInfo setObject:@"1" forKey:childID];
                [onlineInfo setObject:messageString forKey:messageKey];
            }
        }
        else{
            NSLog(@"Error: %@",error);
            [onlineInfo setObject:@"1" forKey:childID];
        }
    }
}

- (void)checkOnlineStatus {
    LCURLLocation = FAMILY_URL;
    onlineInfo = [[NSMutableDictionary alloc] init];
    for (int i=0; i < [childArray count]; i++)  {
        NSMutableDictionary* childDict = [childArray objectAtIndex:i];
        NSString* childID = [childDict objectForKey:@"id"];
        
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/request_current_location/%@",LCURLLocation,childID];
        NSLog(@"strPortalURL: %@",strPortalURL);
        NSLog(@"authToken: %@",authToken);
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request addRequestHeader:@"Auth-Token" value:authToken];
        [request startSynchronous];
        NSData *purlData = [request responseData];
        NSError *error = [request error];
        if (!error) {
            NSString* strMessage = @"0";
            
            NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseData Online: %@",responseData);
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            strMessage = [dictData objectForKey:@"success"];
            NSString *messageString = [dictData objectForKey:@"message"];
            NSString *messageKey = [NSString stringWithFormat:@"%@_message",childID];
            if ([strMessage intValue] == 1) {
                [onlineInfo setObject:@"0" forKey:childID];
            }
            else{
                [onlineInfo setObject:@"1" forKey:childID];
                [onlineInfo setObject:messageString forKey:messageKey];
            }
        }
        else{
            NSLog(@"Error: %@",error);
            [onlineInfo setObject:@"1" forKey:childID];
        }
    }
    [tableChild reloadData];
}

- (void)getChildLocationList{
    LCURLLocation = FAMILY_URL;
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/children/locations",LCURLLocation];
    NSLog(@"strPortalURL: %@",strPortalURL);
    NSLog(@"authToken: %@",authToken);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:authToken];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableArray *selectedChildArray = [[NSMutableArray alloc]init];
        for (int i=0; i < [selectedChild count]; i++)  {
            BOOL boolSelected = [[selectedChild objectAtIndex:i] boolValue];
            if (boolSelected == YES) {
                NSMutableDictionary* childDict = [childArray objectAtIndex:i];
                [selectedChildArray addObject:childDict];
            }
        }
        NSMutableArray *arrayData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        
        MapLocationViewController *mvc = [[MapLocationViewController alloc] initWithNibName:@"MapLocationViewController" bundle:[NSBundle mainBundle]];
        mvc.childArrayList = childArray;
        mvc.childArray = selectedChildArray;
        mvc.selectedChild = selectedChild;
        mvc.arrayData = arrayData;
        mvc.onlineInfo = onlineInfo;
        mvc.authToken = authToken;
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else{
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError :@"Network error"];
    }
}

-(void) getChildsPhoto{
    for (int i=0; i < [childArray count]; i++)  {
        NSMutableDictionary* childDict = [childArray objectAtIndex:i];
        NSString *childID = [childDict objectForKey:@"id"];
        NSString *strPortalURL = [childDict objectForKey:@"photo_source"];
        
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
            [photoInfo setObject:purlData forKey:childID];
        }
    }
}

- (IBAction)btnRetrieveLocation:(id)sender {
    [self getChildLocationList];
}


- (void) callRequestCurrentLocation: (NSMutableDictionary*) childDict{
    LCURLLocation = FAMILY_URL;
    int childID = [[childDict objectForKey:@"id"] intValue];
    //NSString *childName = [childDict objectForKey:@"name"];
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/request_current_location/%d",LCURLLocation,childID];

    NSLog(@"strPortalURL: %@",strPortalURL);
    NSLog(@"authToken: %@",authToken);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:authToken];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSString* strMessage = [dictData objectForKey:@"success"];
        //NSString* message = [dictData objectForKey:@"message"];
        
        if ([strMessage intValue] == 1) {
            //[self connectWebSocket:childID];
        }
        else{
            //NSString *strTitle = [NSString stringWithFormat:@"Showing last location: %@",childName];
            //[self alertStatus:message :strTitle];
            //[self getChildLocationList];
        }
    }
}


- (IBAction)btnBack:(id)sender {
    [self showRightView:sender];
}

- (void)showRightView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox {

    NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:checkBox.tag];
    ChildInfoTableViewCell *cell = (ChildInfoTableViewCell *)[tableChild cellForRowAtIndexPath:a];

    myCheckBox = [[BEMCheckBox alloc] init];
    myCheckBox.frame = CGRectMake(0, 0, 25, 25);
    myCheckBox.tintColor = [UIColor darkGrayColor];
    myCheckBox.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onAnimationType = BEMAnimationTypeBounce;
    myCheckBox.animationDuration = 0.2;
    myCheckBox.onCheckColor = [UIColor whiteColor];
    myCheckBox.tag = checkBox.tag;
    myCheckBox.delegate = self;

    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [myCheckBox setOn:YES animated:YES];
        [selectedChild replaceObjectAtIndex:checkBox.tag withObject:@"YES"];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [myCheckBox setOn:NO animated:YES];
        [selectedChild replaceObjectAtIndex:checkBox.tag withObject:@"NO"];
    }
    cell.accessoryView = myCheckBox;
    
    for (int i=0; [childArray count] >= i; i++) {
        NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:i];
        ChildInfoTableViewCell *cell = (ChildInfoTableViewCell *)[tableChild cellForRowAtIndexPath:a];;
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            showLocationBtn.enabled = YES;
            break;
        } else {
            showLocationBtn.enabled = NO;
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [childArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"user selected %@",[childArray objectAtIndex:indexPath.section]);
    selectedCell = indexPath.section;
    
    myCheckBox = [[BEMCheckBox alloc] init];
    myCheckBox.frame = CGRectMake(0, 0, 25, 25);
    myCheckBox.tintColor = [UIColor darkGrayColor];
    myCheckBox.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onAnimationType = BEMAnimationTypeBounce;
    myCheckBox.animationDuration = 0.2;
    myCheckBox.onCheckColor = [UIColor whiteColor];
    myCheckBox.tag = indexPath.section;
    myCheckBox.delegate = self;
    
    ChildInfoTableViewCell *cell = (ChildInfoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [myCheckBox setOn:YES animated:YES];
        [selectedChild replaceObjectAtIndex:indexPath.section withObject:@"YES"];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [myCheckBox setOn:NO animated:YES];
        [selectedChild replaceObjectAtIndex:indexPath.section withObject:@"NO"];
    }
    cell.accessoryView = myCheckBox;
    
    for (int i=0; [childArray count] >= i; i++) {
        NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:i];
        ChildInfoTableViewCell *cell = (ChildInfoTableViewCell*)[tableView cellForRowAtIndexPath:a];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
            showLocationBtn.enabled = YES;
            break;
        }
        else{
            showLocationBtn.enabled = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"user de-selected %@",[childArray objectAtIndex:indexPath.section]);
    
    myCheckBox = [[BEMCheckBox alloc] init];
    myCheckBox.frame = CGRectMake(0, 0, 25, 25);
    myCheckBox.tintColor = [UIColor darkGrayColor];
    myCheckBox.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onAnimationType = BEMAnimationTypeBounce;
    myCheckBox.animationDuration = 0.2;
    myCheckBox.onCheckColor = [UIColor whiteColor];
    myCheckBox.tag = indexPath.section;
    myCheckBox.delegate = self;
    
    ChildInfoTableViewCell *cell = (ChildInfoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [myCheckBox setOn:YES animated:YES];
        [selectedChild replaceObjectAtIndex:indexPath.section withObject:@"YES"];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [myCheckBox setOn:NO animated:YES];
        [selectedChild replaceObjectAtIndex:indexPath.section withObject:@"NO"];
    }
    cell.accessoryView = myCheckBox;
    
    for (int i=0; [childArray count] >= i; i++) {
        NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:i];
        ChildInfoTableViewCell *cell = (ChildInfoTableViewCell*)[tableView cellForRowAtIndexPath:a];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
            showLocationBtn.enabled = YES;
            break;
        }
        else{
            showLocationBtn.enabled = NO;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary* childDict = [childArray objectAtIndex:indexPath.section];
    
    static NSString *simpleTableIdentifier = @"Cell";
    ChildInfoTableViewCell *cell = (ChildInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChildInfoTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    myCheckBox = [[BEMCheckBox alloc] init];
    myCheckBox.frame = CGRectMake(0, 0, 25, 25);
    myCheckBox.tintColor = [UIColor darkGrayColor];
    myCheckBox.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBox.onAnimationType = BEMAnimationTypeBounce;
    myCheckBox.animationDuration = 0.2;
    myCheckBox.onCheckColor = [UIColor whiteColor];
    myCheckBox.tag = indexPath.section;
    myCheckBox.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *childID = [[childDict objectForKey:@"id"] stringValue];
    NSString *photoURL = [childDict objectForKey:@"photo_source"];
    NSData *photoData = [photoInfo objectForKey:childID];
    cell.lblChileName.text = [childDict objectForKey:@"name"];
    cell.imgChild.image = nil;
    
    if (photoData) {
        NSString *childPhotoURLID = [NSString stringWithFormat:@"%@_URL",childID];
        NSString *childIDPhotoURL = [photoInfo objectForKey:childPhotoURLID];
        
        if ([childIDPhotoURL isEqualToString: photoURL]) {
            cell.imgChild.layer.cornerRadius = cell.imgChild.frame.size.height /2;
            cell.imgChild.layer.masksToBounds = YES;
            cell.imgChild.layer.borderWidth = 0;
            cell.imgChild.image = [UIImage imageWithData:photoData];
        }
        else{
            NSURL* url = [NSURL URLWithString:photoURL];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"GET";
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse * response,
                                                       NSData * data,
                                                       NSError * error) {
                                       if (!error){
                                           cell.imgChild.layer.cornerRadius = cell.imgChild.frame.size.height /2;
                                           cell.imgChild.layer.masksToBounds = YES;
                                           cell.imgChild.layer.borderWidth = 0;
                                           cell.imgChild.image = [UIImage imageWithData:data];
                                           
                                           [photoInfo setObject:data forKey:childID];
                                           [photoInfo setObject:photoURL forKey:childPhotoURLID];
                                           NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                                           [userLogin setObject:photoInfo forKey:@"photoInfo"];
                                       }
                                   }];
        }
    }
    else{
        NSURL* url = [NSURL URLWithString:photoURL];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response,
                                                   NSData * data,
                                                   NSError * error) {
                                   if (!error){
                                       cell.imgChild.layer.cornerRadius = cell.imgChild.frame.size.height /2;
                                       cell.imgChild.layer.masksToBounds = YES;
                                       cell.imgChild.layer.borderWidth = 0;
                                       cell.imgChild.image = [UIImage imageWithData:data];
                                       
                                       NSString *childPhotoURLID = [NSString stringWithFormat:@"%@_URL",childID];
                                       [photoInfo setObject:data forKey:childID];
                                       [photoInfo setObject:photoURL forKey:childPhotoURLID];
                                       NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                                       [userLogin setObject:photoInfo forKey:@"photoInfo"];
                                   }
                               }];
    }
    
    for (int i=0; i < [selectedChild count]; i++)  {
        if (i == indexPath.section) {
            BOOL boolSelected = [[selectedChild objectAtIndex:i] boolValue];
            if (boolSelected == YES) {
                [myCheckBox setOn:YES animated:YES];
            }
        }
    }
    cell.accessoryView = myCheckBox;
    
    return cell;
}

@end
