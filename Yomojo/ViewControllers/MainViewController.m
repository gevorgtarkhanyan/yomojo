//
//  MainViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 01/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewItemCell.h"
#import "TopUpViewController.h"
#import "UsageHistoryViewController.h"
#import "LDProgressView.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import "XmlReader.h"
#import "BoltOnHistoryTableViewCell.h"
#import "ChangePlanNextMonthViewController.h"
#import "ChangePlanThisMonthViewController.h"
#import <CustomIOSAlertView/CustomIOSAlertView.h>
#import "ALActionBlocks.h"
#import "BEMCheckBox.h"
#import "ASIFormDataRequest.h"
#import <PKRevealController/PKRevealController.h>
#import <CommonCrypto/CommonDigest.h>
#import "NotificationsViewController.h"
#import "SideMenuViewController.h"
#import <SAMKeychain/SAMKeychain.h>
#import <SAMKeychain/SAMKeychainQuery.h>
#import "ChangePlanViewController.h"
#import "Constants.h"
#import "SimActivatorViewController.h"
#import "BoltOnHistoryCell.h"
#import "UIColor+Yomojo.h"

static NSString * const kCellIdentify = @"cell";

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UITextView *bannerTextView;
@property (nonatomic, weak) IBOutlet UITableView *boltOnHistoryTableView;
@property (strong, nonatomic) NSString *boltOnHistory_1;
@property (strong, nonatomic) NSString *boltOnHistory_2;
@property (strong, nonatomic) NSString *boltOnHistory_3;
@property (assign, nonatomic) BOOL isHWBB;
@property (assign, nonatomic) NSString* bannerState;
@property (assign,nonatomic) NSMutableAttributedString* attributedString;
@end

@implementation MainViewController
@synthesize urlData,lblName,lblPortingMessage,lblPortingMessageContainer,lblPortingMessageTop, lblPortingMessageBottom,MIMtableView,lblNumber,lblBalance,lblDueDate,lblAvailableCredit,btnAccountList, planID, ExcessCreditBalance, lblExcessCreditExpiry;
@synthesize productPlan,productPlanArray,phonesArray,phoneID,phonesArrayIndex,topupButton,payg,resource,strPassword,strUserName,billday,viewBoltOnPopup,btnBoltOnChoices,txtBoltOnAmount,strBoltOnId,viewBoltOnHistory,bolton,boltonHistoryArray,viewBoltOnHistoryList,testLabel,btnAddBoltOn,lblDateRange,lblTotalValue,selectedBoltOnIndex,btnCancelBoltOn,boltOnListTable,myCheckBox,selectedCell,imgNavBar,tabBarController,validbolton, viewBoltOn,viewBoltOnBG, btnBoltOnHistoryNew, withFamily,imgUnreadNotif,accountBalance,fromFB, resultDataForUsage, current_fkbundleid, billDuration, topUpBtnBottomConstraint, noPlanLabel, lblActivateDate, waitingTextInCells,boltOnHistoryView,bannerView,closeButtonBanner,bannerMoreButton,bannerViewHeightConstraint,closeButtonHeight;
@synthesize viewAds, lblSummary, lblTitle, imgAdsImage, viewAdsHolder,adsURL_link, adsID, fromLogin, containsIntlVoice, btnChangePlanProp, tableViewInactive, autoActivatedate, btnActivateSimProp, noActiveService;

-(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currrentStatus = [reachability currentReachabilityStatus];
    return currrentStatus;
}

- (void) alertStatus:(NSString *)msg :(NSString *)title {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    accountUnli = 0;
    boltOnButtonCreated = NO;
    billDuration = @"30";
    
    UIView *adsSubView = [[[NSBundle mainBundle] loadNibNamed:@"MainViewController" owner:self options:nil] objectAtIndex:2];
    adsSubView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGFloat borderWidth = 3.0f;
    viewAds.frame = CGRectInset(viewAds.frame, -borderWidth, -borderWidth);
    viewAds.layer.borderWidth = borderWidth;
    viewAds.layer.cornerRadius = 20;
    viewAds.layer.masksToBounds = true;
    viewAds.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.view addSubview:adsSubView];
    viewAdsHolder.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    selectedBoltOnIndex = 0;
    
    NSString *txtPhoneArrayIndex = [NSString stringWithFormat:@"%d",phonesArrayIndex];
    [userLogin setObject:txtPhoneArrayIndex forKey:@"phonesArrayIndex"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    NSString *clientDetailsXML = [responseDict objectForKey:@"CLIENTDETAILS"];
    NSDictionary *XMLdict = [XMLReader dictionaryForXMLString:clientDetailsXML error:nil];
    NSDictionary *clientDict = [XMLdict objectForKey:@"client"];
    
    billday = [[clientDict objectForKey:@"billday"]objectForKey:@"text"];
    billday = [billday stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    
    accountBalance = [[clientDict objectForKey:@"account_balance"]objectForKey:@"text"];
    accountBalance = [accountBalance stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    lblDueDate.text = @"Your credit will expire on ";
    strBoltOnId = @"2001";
    
    if ([withFamily  isEqual: @"YES"]) {
        NSString* deviceToken = [userLogin objectForKey:@"DeviceToken"];
        if (deviceToken) {
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(registerDevice) onTarget:self withObject:nil animated:YES];
        }
    }
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    
    
    self.bannerState = [userLogin objectForKey:@"bannerState"];
    bannerViewHeightConstraint.active = YES;
    bannerViewHeightConstraint.constant = 5;
    closeButtonHeight.constant = 0;
    if (![_bannerState  isEqual: @"closed"]) {
        [self getBannerText];
    }
    
    
    [HUB showWhileExecuting:@selector(getBoltOnDetails) onTarget:self withObject:nil animated:YES];
    
    if (!phonesArrayIndex) {
        NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:0];
        phoneID = [phoneDetails objectForKey:@"id"];
        planID = [phoneDetails objectForKey:@"planid"];
        lblName.text = [phoneDetails objectForKey:@"label"];
        lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
        
        NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
        
        if ([arrayPhoneNum count] < 2) {
            lblNumber.text = [phoneDetails objectForKey:@"number"];
        } else {
            lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.groupingSize = 3;
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        
        if ([accountBalance integerValue] < 0) {
            lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
        } else {
            lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
        }
        
        if (![[phoneDetails objectForKey:@"credit_expirydate"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"credit_expirydate"] && ![[phoneDetails objectForKey:@"phone_status"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"phone_status"] && [[phoneDetails valueForKey:@"phone_status"] isEqualToString:@"Active"] && ![[resultData valueForKey:@"network"] isEqualToString:@"HWBB"]) {
            self.lblDueDate.hidden = NO;
        } else {
            self.lblDueDate.hidden = YES;
        }
        
        NSString *expiry = [NSString stringWithFormat:@"%@",[phoneDetails objectForKey:@"credit_expirydate"]];
        if (expiry.length > 10) {
            expiry = [expiry substringToIndex:10];
        }
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *yourDate = [dateFormatter dateFromString:expiry];
        dateFormatter.dateFormat = @"dd MMM yyyy";
        
        if (yourDate) {
            lblDueDate.text = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
        } else {
            lblDueDate.text = @"";
        }
        
        lblExcessCreditExpiry = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
        
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
    } else {
        NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
        phoneID = [phoneDetails objectForKey:@"id"];
        planID = [phoneDetails objectForKey:@"planid"];
        lblName.text = [phoneDetails objectForKey:@"label"];
        lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
        
        NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
        
        if ([arrayPhoneNum count] <= 1) {
            lblNumber.text = [phoneDetails objectForKey:@"number"];
        } else {
            lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.groupingSize = 3;
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        
        if ([accountBalance integerValue] < 0) {
            lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
        } else {
            lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
        }
        
        if (![[phoneDetails objectForKey:@"credit_expirydate"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"credit_expirydate"] && ![[phoneDetails objectForKey:@"phone_status"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"phone_status"] && [[phoneDetails valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
            self.lblDueDate.hidden = NO;
        } else {
            self.lblDueDate.hidden = YES;
        }
        
        NSString *expiry = [NSString stringWithFormat:@"%@",[phoneDetails objectForKey:@"credit_expirydate"]];
        if (expiry.length > 10) {
            expiry = [expiry substringToIndex:10];
        }
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *yourDate = [dateFormatter dateFromString:expiry];
        dateFormatter.dateFormat = @"dd MMM yyyy";
        lblDueDate.text = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
        
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
    }
    
    if (fromLogin == YES) {
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(showAdds) onTarget:self withObject:nil animated:YES];
    }
}

//MARK: - showAdds
- (void) showAdds {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/advertisement_details?status=On-going&mode=dev&cid=%@&media_type=ios", PORTAL_URL, clientID];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *arrayAds = [dictData objectForKey:@"result"];
        
        if (([arrayAds count]) != 0) {
            NSString *popupTitle = [[arrayAds objectAtIndex:0] objectForKey:@"popup_title"];
            NSString *textSummary = [[arrayAds objectAtIndex:0] objectForKey:@"summary"];
            NSString *txtImgName = [[arrayAds objectAtIndex:0] objectForKey:@"mobile_image_url"];
            NSString *txtImgURL = [NSString stringWithFormat:@"https://yomojo.com.au/yomojo_admin/assets/img/advertisement/mobile/%@",txtImgName];
            adsID = [[arrayAds objectAtIndex:0] objectForKey:@"id"];
            
            adsURL_link = [[arrayAds objectAtIndex:0] objectForKey:@"link_url"];
            
            lblSummary.text = textSummary;
            lblTitle.text = popupTitle;
            
            NSURL* url = [NSURL URLWithString:txtImgURL];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"GET";
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse * response,
                                                       NSData * data,
                                                       NSError * error) {
                if (!error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->imgAdsImage.image = [UIImage imageWithData:data];
                    });
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->viewAdsHolder.hidden = NO;
            });
            [self sendReadAds:adsID];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->viewAdsHolder.hidden = YES;
            });
        }
    }
}

-(void) sendReadAds: (NSString*) adsID{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/add_fta?cid=%@&ads_id=%@&mode=dev&media_type=ios", PORTAL_URL, clientID, adsID];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

//MARK: - getBundlePlans
-(void) getBundlePlans{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbundles2/%@", PORTAL_URL, current_fkbundleid];
    
    NSLog(@"urlCall: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *arrayBundles = [dictData objectForKey:@"bundles"];
        for (int i=0; [arrayBundles count] > i; i++) {
            NSString *strID = [[arrayBundles objectAtIndex:i] objectForKey:@"id"];
            if (strID == current_fkbundleid) {
                billDuration =  [[arrayBundles objectAtIndex:i] objectForKey:@"duration"];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString *fromNotification = [userLogin objectForKey:@"fromNotification"];
    if (fromFB == YES) {
        [userLogin setObject:@"YES" forKey:@"fromFB"];
    } else {
        [userLogin setObject:@"NO" forKey:@"fromFB"];
    }
    if (([fromNotification  isEqual: @"1"]) && ([withFamily isEqual: @"YES"])){
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(loadNotificationView) onTarget:self withObject:nil animated:YES];
    }
}

- (void)viewWillAppear: (BOOL)animated{
    self.waitingTextInCells = nil;
    self.boltOnHistoryView.layer.borderWidth = 1.0f;
    self.boltOnHistoryView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void) loadNotificationView{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        NSString *showChildMenuOnly = [userLogin objectForKey:@"showChildMenuOnly"];
        
        NotificationsViewController *mvc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:[NSBundle mainBundle]];
        mvc.urlData = self.urlData;
        mvc.withFamily = @"YES";
        
        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
        smvc.urlData = self.urlData;
        smvc.phonesArray = self.phonesArray;
        smvc.fromFB = self.fromFB;
        smvc.showChildMenuOnly = showChildMenuOnly;
        smvc.withFamily = @"YES";
        
        UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
        UIViewController *leftViewController = smvc;
        PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
        revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:revealController animated:YES];
    });
}


-(void) applicationBecomeActive{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString *fromNotification = [userLogin objectForKey:@"fromNotification"];
    if ([fromNotification  isEqual: @"1"]) {
        NotificationsViewController *mvc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:[NSBundle mainBundle]];
        mvc.urlData = urlData;
        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
        smvc.urlData = urlData;
        smvc.phonesArray = phonesArray;
        smvc.fromFB = fromFB;
        smvc.withFamily = @"YES";
        UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
        UIViewController *leftViewController = smvc;
        PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
        revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:revealController animated:YES];
    }
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

-(void) registerDevice{
    NSString* strHash = [NSString stringWithFormat:@"%@-%@-6uJOCglydQexaZBeJfeEZrpNsxOv6060MmtTm5wVWrMnZ5zA26CXlB7BlInE8fzpOrgvEwHu04YU90KtnAMaS4FITQBY7Xj0B1DAI9n2hNCnh2yQ4djFcrvO",clientID,sessionID];
    NSString *hashOutput = [self sha1:strHash];
    NSString *srtCallURL = [NSString stringWithFormat:@"%@/api-ca/v1/get-auth-token",FAMILY_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:srtCallURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:clientID forKey:@"client_id"];
    [request setPostValue:sessionID forKey:@"session_var"];
    [request setPostValue:hashOutput forKey:@"hash"];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSString *strError = [dictData objectForKey:@"error"];
            
            if (!strError) {
                NSString *authToken = [dictData objectForKey:@"auth_token"];
                NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                [userLogin setObject:authToken forKey:@"authToken"];
                [userLogin setObject:self->clientID forKey:@"client_id"];
                [userLogin setObject:self->sessionID forKey:@"session_var"];
                [self callRegisterDevice:authToken];
            }
        });
    }
}

-(NSString *)getDeviceIdAsString {
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *appDeviceUUID = [SAMKeychain passwordForService:appName account:@"incoding"]; // get UUID from keychain
    if (appDeviceUUID == nil) {
        appDeviceUUID = [[NSUUID UUID] UUIDString]; // generate UUID
        [SAMKeychain setPassword:appDeviceUUID forService:appName account:@"incoding"]; // persist in keychain
    }
    return appDeviceUUID;
}

-(void) callRegisterDevice: (NSString *)authToken {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString* deviceToken = [userLogin objectForKey:@"DeviceToken"];
    
    NSString* Identifier = [self getDeviceIdAsString];
    NSLog(@"UUID SAMKey: %@",Identifier);
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    
    NSString *srtCallURL = [NSString stringWithFormat:@"%@/api-ca/v1/user/device/register",FAMILY_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:srtCallURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:authToken];
    [request setPostValue:Identifier forKey:@"device_id"];
    [request setPostValue:deviceToken forKey:@"push_token"];
    [request setPostValue:tzName forKey:@"settings[timezone]"];
    [request setPostValue:@"ios" forKey:@"os_type"];
    [request setPostValue:ver forKey:@"os_version"];
    
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSString* successRet = [dictData objectForKey:@"success"];
    }
    
    //added to update timezone
    NSString *localTimezone = [NSString stringWithFormat:@"%@",[[NSTimeZone localTimeZone] name]];
    NSString *srtCallURLTZ = [NSString stringWithFormat:@"%@/api-ca/v1/user/device/timezone",FAMILY_URL];
    ASIFormDataRequest *request2 = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:srtCallURLTZ]];
    [request2 setRequestMethod:@"POST"];
    [request2 addRequestHeader:@"Accept" value:@"application/json"];
    [request2 addRequestHeader:@"Auth-Token" value:authToken];
    [request2 setPostValue:localTimezone forKey:@"settings[timezone]"];
    [request2 setPostValue:Identifier forKey:@"device_id"];
    [request2 startSynchronous];
    NSData *purlData2 = [request2 responseData];
    NSError *error2 = [request2 error];
    if (!error2) {
        NSMutableDictionary *dictData2 = [NSJSONSerialization JSONObjectWithData:purlData2 options:NSJSONReadingMutableContainers error:nil];
        NSString *strError = [dictData2 objectForKey:@"success"];
    }
}

-(void) getDateRanges:(NSDate*)dataPackDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd MMM yyyy"];
    
    int daysCount = 30;
    
    if (![billDuration isKindOfClass:[NSNull class]]) {
        daysCount = [billDuration intValue];
    }
    
    NSDate *oneMonthAgo = [dataPackDate dateByAddingTimeInterval:-daysCount*24*60*60];
    self.boltOnHistory_2 = [df stringFromDate:oneMonthAgo]; // from date
    self.boltOnHistory_3 = [df stringFromDate:dataPackDate]; // to date
}

//MARK: - getBannerText
-(void) getBannerText{
    
    NSString * mode = @"";
    
    if ([PORTAL_URL  isEqual: @"https://yomojo.com.au/dev/api"]) {
            mode =  @"Dev";
        } else {
            mode = @"Prod";
        };
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/mobile_outage?type=banner&app=Yomojo&device=IOS&mode=%@", PORTAL_URL,mode];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary* resultSet = [dictData objectForKey:@"result"];
            NSMutableArray* result = [resultSet valueForKey: @"summary"];
            if ([result count] >= 1) {
                for (NSString *resultText in result) {
                    self->closeButtonBanner.hidden = NO;
                    self.attributedString = [[NSMutableAttributedString alloc] initWithData:[resultText dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                           NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                      documentAttributes:nil error:nil];
                    NSMutableAttributedString *encodedString = [[NSMutableAttributedString alloc] initWithData:[self.attributedString.string dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                          documentAttributes:nil error:nil];
                    
                    self->_bannerTextView.attributedText  =  encodedString;
                    self->bannerView.hidden = NO;
                    self.bannerTextView.textAlignment = NSTextAlignmentCenter;
//                    [self->_bannerTextView setFont:[UIFont fontWithName:@"Arial" size:14.0f]];
                    self.bannerViewHeightConstraint.active = NO;
                    self.closeButtonHeight.constant = 15;
                    
                }
            } else {
                self.bannerViewHeightConstraint.active = YES;
                self.bannerViewHeightConstraint.constant = 5;
                self.closeButtonHeight.constant = 0;
                self->bannerView.hidden = YES;
            }
            
        }
        
    });
}
- (IBAction)bannerCloseButtonAction:(id)sender {
    bannerView.hidden = YES;
    closeButtonBanner.hidden = YES;
    bannerMoreButton.hidden = YES;
    bannerViewHeightConstraint.active = YES;
    bannerViewHeightConstraint.constant = 5;
    closeButtonHeight.constant = 0;
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"closed" forKey:@"bannerState"];
}

- (IBAction)bannerMoreButtonAction:(id)sender {
    if (bannerMoreButton.tag == 1) {
        bannerViewHeightConstraint.active = NO;
        [(UIButton *)sender setTitle:@"close" forState:UIControlStateNormal];
        bannerMoreButton.tag = 2;
        self->_arrowImageView.image = [UIImage systemImageNamed:@"arrow.up"];
    } else {
        bannerViewHeightConstraint.active = YES;
        bannerMoreButton.tag = 1;
        [(UIButton *)sender setTitle:@"see more" forState:UIControlStateNormal];
        self->_arrowImageView.image = [UIImage systemImageNamed:@"arrow.down"];
    }
}
//MARK: - getBoltOnDetails
-(void) getBoltOnDetails{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getboltons", PORTAL_URL];
    
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
            NSMutableDictionary* resultSet = [dictData objectForKey:@"result"];
            self->arrayBoltOnLookUp = [[NSMutableArray alloc]init];
            self->arrayBoltOnLookUp = [resultSet objectForKey:@"RP1"];
        }
        [self->boltOnListTable reloadData];
    });
}

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}

//MARK: - UI Actions
- (void) hidePortingMessageLabel {
    self.lblPortingMessage.hidden = YES;
    self.lblPortingMessageContainer.hidden = YES;
    self.lblPortingMessage.text = nil;
    self.lblPortingMessageTop.constant = 0.0f;
    self.lblPortingMessageBottom.constant = 0.0f;
}

- (NSString*) checkDateIsShow: (NSString*) name_text {
//    label = "no plan";
    NSString* lblName = [resultDataForUsage objectForKey:@"label"];
    
    return NULL;
}

//MARK: - getPhoneDetails
- (void) getPhoneDetails {
    if ([self connected] == NotReachable){
        [self alertStatus:@"No Network connection." :@"Error"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->lblBalance.text = @"$--";
        });
        
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/get_phone_details_v2/%@/%@/%@", PORTAL_URL, phoneID, clientID,sessionID];
        
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
            
            NSMutableDictionary *resultData = [[NSMutableDictionary alloc]init];
            if (!error) {
                
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
                
                self->resultDataForUsage =  [dictData objectForKey:@"result"];
                resultData = [dictData objectForKey:@"result"];
                
                NSString *activationMessage = resultData[@"activation_message"];
                
                BOOL portCodeVerified = [[resultData objectForKey:@"port_code_verified"] boolValue];
                BOOL statusIsActive = ([[resultData valueForKey:@"phone_status"] isEqualToString:@"Active"]);
                BOOL activationMessageIsInvaled = ([activationMessage isKindOfClass:[NSNull class]] || activationMessage.length == 0 || ![activationMessage containsString:@"Click here"]);
                
                if ((!portCodeVerified && statusIsActive) || activationMessageIsInvaled) {
                    [self hidePortingMessageLabel];
                } else {
                    self.lblPortingMessage.hidden = NO;
                    self.lblPortingMessageContainer.hidden = NO;
                    self.lblPortingMessage.text = activationMessage;
                    self.lblPortingMessageTop.constant = 5.0f;
                    self.lblPortingMessageBottom.constant = 5.0f;
                    
                    if ([activationMessage containsString:@"Click here"]) {
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:activationMessage];
                        NSString *boldString = @"here";
                        NSRange boldRange = [activationMessage rangeOfString:boldString];
                        [attributedString addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange];
                        [attributedString addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:64/255.0 blue:10/255.0 alpha:1] range:boldRange];
                        [attributedString addAttribute: @"myCustomTag" value:@YES range:boldRange];
                        [self.lblPortingMessage setAttributedText: attributedString];
                        self.lblPortingMessage.userInteractionEnabled = YES;
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnLblPortingMessage:)];
                        [self.lblPortingMessage addGestureRecognizer:tapGesture];
                    }
                }
                
                // checking if phone is active
                if ([[resultData valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
                    [self->btnActivateSimProp setHidden:YES];
                    [self->btnChangePlanProp setHidden:NO];
                    [self->tableViewInactive setHidden:YES];
                    self->lblActivateDate.hidden = YES;
                } else if ([[resultData valueForKey:@"phone_status"] isEqualToString:@"Activate Processing"]) {
                    
                    [self->btnActivateSimProp setTitle:@"Activation in progress" forState:UIControlStateNormal];
                    [self->btnActivateSimProp setHidden:NO];
                    [self->btnChangePlanProp setHidden:YES];
                    [self->tableViewInactive setHidden:NO];
                    [self->btnActivateSimProp setAlpha:0.6f];
                    [self->btnActivateSimProp setUserInteractionEnabled:NO];
                    self->lblActivateDate.hidden = YES;
                    
                } else if ([[[resultData valueForKey:@"phone_status"] lowercaseString] isEqualToString:@"Port In Processing".lowercaseString]) {
                    
                    [self->btnActivateSimProp setTitle:@"Porting in progress" forState:UIControlStateNormal];
                    [self->btnActivateSimProp setHidden:NO];
                    [self->btnChangePlanProp setHidden:YES];
                    [self->tableViewInactive setHidden:NO];
                    [self->btnActivateSimProp setAlpha:0.6f];
                    [self->btnActivateSimProp setUserInteractionEnabled:NO];
                    self->lblActivateDate.hidden = YES;
                    
                } else {
                    
                    [self.btnActivateSimProp setTitle:@"Activate SIM" forState:UIControlStateNormal];
                    
                    [self->btnActivateSimProp setHidden:NO];
                    [self->btnChangePlanProp setHidden:YES];
                    [self->tableViewInactive setHidden:NO];
                    
                    BOOL containsIntlVoice = NO;
                    
                    if ([resultData valueForKey:@"productplan"]) {
                        NSArray *productplan = [resultData valueForKey:@"productplan"];
                        
                        for (NSDictionary *product in productplan) {
                            if ([product valueForKey:@"name_text"]) {
                                if ([[product valueForKey:@"name_text"] containsString:@"Intl Voice"]) {
                                    containsIntlVoice = YES;
                                }
                            }
                        }
                    }
                    
                    self.containsIntlVoice = containsIntlVoice;
                    [self.tableViewInactive reloadData];
                    
                    if ([self->phonesArray count] == 0){
                        self->noActiveService = YES;
                    } else {
                        NSDictionary *phone = self->phonesArray[self->phonesArrayIndex];
                        if (!([[phone valueForKey:@"phone_status"] isEqualToString:@"Active"] || [[phone valueForKey:@"phone_status"] isEqualToString:@"Waiting For Activation"])) {
                            self->noActiveService = YES;
                        }
                    }
                    
                    // checking if sim not sent
                    if (![resultData valueForKey:@"sim"] || [[resultData valueForKey:@"sim"] isEqualToString:[resultData valueForKey:@"id"]] || [[resultData valueForKey:@"sim"] isEqualToString:@""] || (self.lblPortingMessage.attributedText.length > 0 && [self.lblPortingMessage.attributedText.string containsString:@"Click here"])) {
                        [self->btnActivateSimProp setAlpha:0.6f];
                        [self->btnActivateSimProp setUserInteractionEnabled:NO];
                        
                        if (containsIntlVoice && self.noActiveService == YES) {
                            
                            if (![resultData valueForKey:@"sim"] || [[resultData valueForKey:@"sim"] isEqualToString:@""]) {
                                self->waitingTextInCells = @"Waiting to Activate";
                            } else {
                                self->waitingTextInCells = @"Waiting to Activate - Sim Not Sent";
                            }
                        }
                        
                    } else {
                        [self->btnActivateSimProp setAlpha:1.0f];
                        [self->btnActivateSimProp setUserInteractionEnabled:YES];
                    }
                    
                    if ([resultData valueForKey:@"sim"] && ![[resultData valueForKey:@"sim"] isEqualToString:[resultData valueForKey:@"id"]] && ![[resultData valueForKey:@"sim"] isEqualToString:@""]) {
                        
                        if ([resultData valueForKey:@"auto_activatedate"] && [[resultData valueForKey:@"auto_activatedate"] length] > 0) {
                            
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                            
                            NSDate *tempDate = [dateFormatter dateFromString:[resultData valueForKey:@"auto_activatedate"]];
                            
                            NSTimeInterval interval = [tempDate timeIntervalSinceDate:[NSDate date]];
                            
                            int numberOfDays = interval / 86400;
                            
                            if (numberOfDays >= 0) {
                                
                                self->lblActivateDate.hidden = NO;
                                self->lblActivateDate.text = [NSString stringWithFormat:@"Activation Date: %@", [resultData objectForKey:@"auto_activatedate"]];
                            }
                        }
                    }
                }
                
                self->autoActivatedate =  [resultData objectForKey:@"auto_activatedate"];
                if ([[resultData valueForKey:@"phone_status"] isEqualToString:@"Waiting For Activation"]) {
                    
                    if ([resultData valueForKey:@"auto_activatedate"] && [[resultData valueForKey:@"auto_activatedate"] length] > 0) {
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                        
                        NSDate *tempDate = [dateFormatter dateFromString:[resultData valueForKey:@"auto_activatedate"]];
                        
                        NSTimeInterval interval = [tempDate timeIntervalSinceDate:[NSDate date]];
                        
                        int numberOfDays = interval / 86400;
                        
                        if (numberOfDays >= 0) {
                            
                            if ([resultData valueForKey:@"sim"] && ![[resultData valueForKey:@"sim"] isEqualToString:[resultData valueForKey:@"id"]] && ![[resultData valueForKey:@"sim"] isEqualToString:@""]) {
                                [self autoUpdatePrompt];
                            }
                        }
                    }
                }
                
                self->current_fkbundleid = [resultData objectForKey:@"fkbundleid"];
                
                self->validbolton = [resultData objectForKey:@"validbolton"];
                self->payg = [resultData objectForKey:@"payg"];
                self->billingType = [[resultData objectForKey:@"billing_type"]intValue];
                
                NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
                [userLogin setObject:[resultData objectForKey:@"billing_type"] forKey:@"billingType"];
                
                if (!dictData[@"result"][@"activation_message"] || [dictData[@"result"][@"activation_message"] isKindOfClass:[NSNull class]]) {
                    dictData[@"result"][@"activation_message"] = nil;
                }
                
                [userLogin setObject:dictData forKey:@"getPhoneDetails"];
                
                self->resource = [resultData objectForKey:@"resource"];
                
                [self getBundlePlans];
                
                self->topupButton.hidden = YES;
                self->lblAvailableCredit.text = @"Account Balance";
//                self->lblDueDate.hidden = NO;
                NSString *account_balance = @"";
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                formatter.groupingSize = 3;
                formatter.maximumFractionDigits = 2;
                formatter.minimumFractionDigits = 2;
                
                if ([self->accountBalance integerValue] == 0) {
                    account_balance = @"0.00";
                } else if ([self->accountBalance integerValue] < 0) {
                    NSString *stringNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:[self->accountBalance floatValue] * -1]];
                    account_balance = [NSString stringWithFormat:@"%@ DR",stringNumber];
                } else {
                    NSString *stringNumber = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[self->accountBalance floatValue]]]];
                    account_balance= [NSString stringWithFormat:@"%@ CR",stringNumber];
                }
                
                self->lblBalance.text = [NSString stringWithFormat:@"Account Balance: $%@",account_balance];
                self->ExcessCreditBalance = [resultData objectForKey:@"balance"];
                
                if (self->billingType == 1 || ![[resultData valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
                    self->topupButton.hidden = YES;
                } else {
                    self->topupButton.hidden = NO;
                }
                
//                if (![[resultData objectForKey:@"credit_expirydate"] isKindOfClass:[NSNull class]] && [resultData objectForKey:@"credit_expirydate"] && ![[resultData objectForKey:@"phone_status"] isKindOfClass:[NSNull class]] && [resultData objectForKey:@"phone_status"] && [[resultData valueForKey:@"phone_status"] isEqualToString:@"Active"] && ![[resultData valueForKey:@"network"] isEqualToString:@"HWBB"]) {
//                    self.lblDueDate.hidden = NO;
//                } else {
                    self.lblDueDate.hidden = YES;
//                }
                NSString *expiry = [NSString stringWithFormat:@"%@",[resultData objectForKey:@"credit_expirydate"]];
                if (expiry.length > 10) {
                    expiry = [expiry substringToIndex:10];
                }
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd";
                NSDate *yourDate = [dateFormatter dateFromString:expiry];
                dateFormatter.dateFormat = @"dd MMM yyyy";
                
                if (yourDate) {
                    self->lblDueDate.text = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
                } else {
                    self->lblDueDate.text = @"";
                }
                self->lblExcessCreditExpiry = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
                
                if ([resultData objectForKey:@"productplan"]) {
                    self->productPlan = [resultData objectForKey:@"productplan"];
                }
                if ([self->productPlan count] == 0) {
                    [self->MIMtableView setHidden:YES];
                    [self->btnChangePlanProp setTitle:@"Add Plan" forState:UIControlStateNormal];
                } else {
                    [self->MIMtableView setHidden:NO];
                    [self->btnChangePlanProp setTitle:@"Change your plan" forState:UIControlStateNormal];
                }
                
                self->productPlanArray = [[NSMutableArray alloc]init];
                for (int i=0; i < [self->productPlan count]; i++) {
                    NSMutableDictionary *productplanDict = [self->productPlan objectAtIndex:i];
                    NSString *name_text = [productplanDict objectForKey:@"name_text"];
                    if ([name_text  isEqual: @"Yomojo Voice"]) {
                        NSLog(@"name_text: %@",name_text);
                    } else {
                        [self addToArray:productplanDict];
                    }
                }
                NSMutableDictionary *phoneDetails = [self->phonesArray objectAtIndex:self->phonesArrayIndex];
                
                if ([phoneDetails[@"network"] isEqualToString:@"HWBB"]) {
                    self.isHWBB = YES;
                    NSMutableDictionary *temDict = [[NSMutableDictionary alloc] init];
                    [temDict setObject:@"Data pack" forKey:@"name"];
                    [temDict setObject:@"Data" forKey:@"name_text"];
                    [temDict setObject:@"GB" forKey:@"denomination_text"];
                    
                    NSDictionary *usageTotal = [self getUsageTotals:phoneDetails withClientId: self->clientID andSessionId: self->sessionID];
                    [temDict setObject:usageTotal[@"datausagelimitMB"] forKey:@"partition_incl_text"];
                    [temDict setObject:usageTotal[@"datausageMB"] forKey:@"usage"];
                    ///must be removed
                    if (phoneDetails[@"datausagelimitMB"]) {
                        [temDict setObject:phoneDetails[@"datausagelimitMB"] forKey:@"partition_incl_text"];
                    }
                    if (phoneDetails[@"datausageMB"]) {
                        [temDict setObject:phoneDetails[@"datausageMB"] forKey:@"usage"];
                    }
                    ///must be removed
                    
                    [self->productPlanArray addObject:temDict];
                    [self->btnChangePlanProp setHidden:YES];
                    [self->MIMtableView setHidden:NO];
                    [self->MIMtableView reloadData];
                    self->noPlanLabel.hidden = YES;
                } else {
                    self.isHWBB = NO;
                }
                
                NSString* enableQuickGlance = [userLogin objectForKey:@"quickGlanceEnable"];
                if (self->billingType != 1 && ([enableQuickGlance isEqualToString:@"NO"] || !enableQuickGlance) && ([[phoneDetails valueForKey:@"phone_status"] isEqualToString:@"Active"])) {
                    NSMutableDictionary *temDict = [[NSMutableDictionary alloc] init];
                    [temDict setObject:@"Excess Credit" forKey:@"name"];
                    [temDict setObject:@"Excess Credit" forKey:@"name_text"];
                    [temDict setObject:@"$" forKey:@"denomination_text"];
                    [temDict setObject:self->ExcessCreditBalance forKey:@"partition_incl_text"];
                    [temDict setObject:self->ExcessCreditBalance forKey:@"usage"];
                    [self->productPlanArray addObject:temDict];
                    [self->MIMtableView setHidden:NO];
                    [self->MIMtableView reloadData];
                    self->noPlanLabel.hidden = YES;
                } else {
                    NSMutableDictionary *phoneDetails = [self->phonesArray objectAtIndex:self->phonesArrayIndex];
                    if ([phoneDetails[@"network"] isEqualToString:@"HWBB"]) {
                        self.isHWBB = YES;
                        [self->btnChangePlanProp setHidden:YES];
                    }
                    if ([self->productPlan count] == 0 && self.productPlanArray.count == 0) {
                        self->noPlanLabel.hidden = NO;
                        self.boltOnHistoryTableView.hidden = YES;
                        self.tableViewInactive.hidden = YES;
                    } else {
                        self->noPlanLabel.hidden = YES;
                        self.boltOnHistoryTableView.hidden = NO;
                    }
                }
                
                self->bolton = [resultData objectForKey:@"bolton"];
                self->boltonHistoryArray = [[NSMutableArray alloc] init];
                
                self->viewBoltOnHistoryList = [[UITextView alloc]init];
                self->intBoltTotal = 0;
                for (int i=0; i < [self->bolton count]; i++) {
                    NSMutableDictionary *boltOnData = [self->bolton objectAtIndex:i];
                    NSString *dateTimeInserted =[boltOnData objectForKey:@"DateTimeInserted"];
                    dateFormatter.dateFormat = @"yyyy-MM-dd";
                    NSDate *yourDate = [dateFormatter dateFromString:dateTimeInserted];
                    dateFormatter.dateFormat = @"dd MMM yyyy";
                    NSString *formattedDate =[dateFormatter stringFromDate:yourDate];
                    
                    NSString *boltOnName =[boltOnData objectForKey:@"name"];
                    NSString *oneLineData = [NSString stringWithFormat:@"\n%@  %@",formattedDate, boltOnName];
                    NSString *RPCode =[boltOnData objectForKey:@"code"];
                    
                    if ([RPCode  isEqual: @"RP1"]) {
                        self->testLabel.text = [NSString stringWithFormat:@"%@ %@",self->testLabel.text,oneLineData];
                        int partition_incl_text = [[boltOnData objectForKey:@"partition_incl_text"] intValue];
                        self->intBoltTotal = self->intBoltTotal + partition_incl_text;
                        [self->boltonHistoryArray addObject:oneLineData];
                    }
                }
                self->lblTotalValue.text = [NSString stringWithFormat:@"Total Bolt-ons: %dGB",(self->intBoltTotal/1024)];
            } else {
                NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
                [self alertStatus:strError:@"Error"];
            }
            NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
            [userLogin setObject:self.lblNumber.text forKey:@"phoneNumber"];
            [userLogin setObject:self.lblName.text forKey:@"FullName"];
            
            [self sortArray];
            [self.MIMtableView reloadData];
            [self.tableViewInactive reloadData];
        });
    }
}
//MARK: getPhoneDetails -

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

- (void) addToArray:(NSMutableDictionary*)productDict{
    int num = 0;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    NSString *productExpiry = [productDict objectForKey:@"expiry"];
    NSString *name_text = [productDict objectForKey:@"name_text"];
    NSDate *productplanexpiry = [dateFormatter dateFromString:productExpiry];
    
    NSDate *currDate = [NSDate date];
    NSString *strCurrDate = [dateFormatter stringFromDate:currDate];
    NSDate *dateCurrDate = [dateFormatter dateFromString:strCurrDate];
    
    for (int i=0; i < [productPlanArray count]; i++) {
        NSMutableDictionary *arrayContent = [productPlanArray objectAtIndex:i];
        NSString *nameText = [arrayContent objectForKey:@"name_text"];
        NSString *strExpiry = [arrayContent objectForKey:@"expiry"];
        
        NSString *name = [arrayContent objectForKey:@"name"];
        if ([name rangeOfString:@"Unlimited"].location != NSNotFound) {
            accountUnli = 1;
        }
        NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
        dateFormatter1.dateFormat = @"dd-MM-yyyy";
        NSDate *expiry = [dateFormatter1 dateFromString:strExpiry];
        if ([name_text isEqualToString: nameText]) {
            if ([productplanexpiry compare:expiry] == NSOrderedDescending) {
                [productPlanArray removeObjectAtIndex: i];
                [productPlanArray insertObject:productDict atIndex:i];
                num = 1;
            }
            if ([productplanexpiry compare:expiry] == NSOrderedAscending) {
                num = 1;
            }
            if ([productplanexpiry compare:expiry] == NSOrderedSame) {
                num = 1;
            }
        }
    }
    if (num == 0){
        if ([productplanexpiry compare:dateCurrDate] == NSOrderedDescending) {
            [productPlanArray addObject:productDict];
        }
        if ([productplanexpiry compare:dateCurrDate] == NSOrderedSame) {
            [productPlanArray addObject:productDict];
        }
    }
}

- (void) sortArray {
    NSMutableArray * tempPlanArray = [[NSMutableArray alloc] init];
    for (int i=0; i < [self.productPlanArray count]; i++) {
        NSMutableDictionary *jsonData = [self.productPlanArray objectAtIndex:i];
        NSString *name_text = [jsonData objectForKey:@"name_text"];
        
        if ([name_text  isEqual: @"Voice"]){
            [jsonData setObject:@"1" forKey:@"sortID"];
        } else if ([name_text  isEqual: @"SMS"]) {
            [jsonData setObject:@"2" forKey:@"sortID"];
        } else if ([name_text  isEqual: @"Data"]) {
            [jsonData setObject:@"3" forKey:@"sortID"];
        } else if ([name_text  isEqual: @"Intl Voice"]) {
            [jsonData setObject:@"4" forKey:@"sortID"];
        } else {
            [jsonData setObject:@"5" forKey:@"sortID"];
        }
        [tempPlanArray addObject:jsonData];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortID" ascending:YES];
    NSArray *sortedArray = [tempPlanArray sortedArrayUsingDescriptors:@[sort]];
    self.productPlanArray = [sortedArray mutableCopy];
    
    if ([self.productPlanArray count] == 0 ) {
        [self.MIMtableView setHidden:YES];
    } else {
        [self.MIMtableView setHidden:NO];
    }
}

- (void) autoUpdatePrompt {
    
    if (self.lblPortingMessage.text.length == 0 && self.lblPortingMessage.attributedText.length == 0) {
        
        NSString *strAutoUpdate = [NSString stringWithFormat:@"Your service was due for activation last %@. Please contact Customer Support at 1300 Yomojo to activate your SIM.",autoActivatedate];
        
        if (self.btnActivateSimProp.hidden == NO && self.btnActivateSimProp.alpha == 1.0f) {
            
            strAutoUpdate = [NSString stringWithFormat:@"Your service will be activated on %@. You may activate now by clicking “Activate SIM” button.", autoActivatedate];
        }
        
        [self alertStatus:strAutoUpdate :@"Notification"];
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)adsExit:(id)sender {
    viewAdsHolder.hidden = YES;
}

- (IBAction)adsTap:(id)sender {
    viewAdsHolder.hidden = YES;
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callAdsURLLink) onTarget:self withObject:nil animated:YES];
    
}

-(void) callAdsURLLink{
    NSString * strURL = [NSString stringWithFormat:@"%@/advertisement_logs?cid=%@&ads_id=%@&mode=dev&media_type=ios", PORTAL_URL, clientID, adsID];
    
    NSURL* url = [NSURL URLWithString:strURL];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response,
                                               NSData * data,
                                               NSError * error) {
        if (!error){
            NSLog(@"sent logs successfully");
        }
    }];
    
    NSURL *urlFromString = [NSURL URLWithString:adsURL_link];
    [[UIApplication sharedApplication] openURL:urlFromString];
}

- (void) getNewVerificationCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:self->HUB];
        [self->HUB show:YES];
        
        NSString *phoneNumber = [lblNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([phoneNumber substringToIndex:1] && [[phoneNumber substringToIndex:1] isEqualToString:@"0"]) {
            phoneNumber = [phoneNumber substringFromIndex:1];
        }
        NSString * strURL = [NSString stringWithFormat:@"%@/get_new_verification?phoneid=%@&client_id=%@&phonenumber=%@&sess_var=%@", PORTAL_URL, phoneID, clientID, phoneNumber, sessionID];
        
        NSURL* url = [NSURL URLWithString:strURL];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response,
                                                   NSData * data,
                                                   NSError * error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error){
                    NSError * error = nil;
                    NSString *object = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:&error];
                    [self->HUB hide:YES];
                    [self alertStatus:@"Porting verification code sent." :@"Success!"];
                    [self getPhoneDetails];
                } else {
                    [self->HUB hide:YES];
                    NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
                    [self alertStatus:strError:@"Error"];
                }
            });
        }];
        
        NSURL *urlFromString = [NSURL URLWithString:adsURL_link];
        [[UIApplication sharedApplication] openURL:urlFromString];
    });
}

- (IBAction)btRefresh:(id)sender {
    if ([self connected] == NotReachable){
        [self alertStatus:@"No Network connection." :@"Please check"];
    } else {
        lblBalance.text = @"$--";
        productPlanArray = nil;
        [MIMtableView reloadData];
        if (!phonesArrayIndex) {
            NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:0];
            phoneID = [phoneDetails objectForKey:@"id"];
            lblName.text = [phoneDetails objectForKey:@"label"];
            lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
            
            NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
            lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.groupingSize = 3;
            formatter.maximumFractionDigits = 2;
            formatter.minimumFractionDigits = 2;
            
            lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[phoneDetails objectForKey:@"balance"] floatValue]]]];
            
            
            if (![[phoneDetails objectForKey:@"credit_expirydate"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"credit_expirydate"] && ![[phoneDetails objectForKey:@"phone_status"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"phone_status"] && [[phoneDetails valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
                self.lblDueDate.hidden = NO;
            } else {
                self.lblDueDate.hidden = YES;
            }
            
            NSString *expiry = [NSString stringWithFormat:@"%@",[phoneDetails objectForKey:@"credit_expirydate"]];
            if (expiry.length > 10) {
                expiry = [expiry substringToIndex:10];
            }
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            NSDate *yourDate = [dateFormatter dateFromString:expiry];
            dateFormatter.dateFormat = @"dd MMM yyyy";
            lblDueDate.text = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
        } else {
            NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
            phoneID = [phoneDetails objectForKey:@"id"];
            lblName.text = [phoneDetails objectForKey:@"label"];
            lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
            
            NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
            
            lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.groupingSize = 3;
            formatter.maximumFractionDigits = 2;
            formatter.minimumFractionDigits = 2;
            
            if ([accountBalance integerValue] < 0) {
                lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
            } else {
                lblBalance.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[accountBalance floatValue]]]];
            }
            
            if (![[phoneDetails objectForKey:@"credit_expirydate"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"credit_expirydate"] && ![[phoneDetails objectForKey:@"phone_status"] isKindOfClass:[NSNull class]] && [phoneDetails objectForKey:@"phone_status"] && [[phoneDetails valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
                
                self.lblDueDate.hidden = NO;
            } else {
                self.lblDueDate.hidden = YES;
            }
            
            NSString *expiry = [NSString stringWithFormat:@"%@",[phoneDetails objectForKey:@"credit_expirydate"]];
            if (expiry.length > 10) {
                expiry = [expiry substringToIndex:10];
            }
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            NSDate *yourDate = [dateFormatter dateFromString:expiry];
            dateFormatter.dateFormat = @"dd MMM yyyy";
            lblDueDate.text = [NSString stringWithFormat:@"Your credit will expire on %@",[dateFormatter stringFromDate:yourDate]];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
        }
    }
}

- (IBAction)btnShowMenu:(id)sender {
    [self showRightView:sender];
}

- (IBAction)btnTopUp:(id)sender {
    TopUpViewController *VC = [[TopUpViewController alloc]initWithNibName:@"TopUpViewController" bundle:[NSBundle mainBundle]];
    VC.urlData = urlData;
    VC.phoneID = phoneID;
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)btnUsageHistory:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UsageHistoryViewController *VC = [[UsageHistoryViewController alloc]initWithNibName:@"UsageHistoryViewController" bundle:[NSBundle mainBundle]];
        VC.sessionID = self->sessionID;
        VC.clientID = self->clientID;
        VC.phoneID = self->phoneID;
        VC.planID = self->planID;
        VC.billday = self->billday;
        VC.resultDataForUsage = self->resultDataForUsage;
        VC.isHWBB = self.isHWBB;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd MMM yyyy"];
        
        VC.defaultFromDate = [df dateFromString:self.boltOnHistory_2];
        VC.defaultToDate = [df dateFromString:self.boltOnHistory_3];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:VC animated:YES];
    });
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)btnChangePlan:(id)sender {
    ChangePlanViewController *nmvc= [[ChangePlanViewController alloc] initWithNibName:@"ChangePlanViewController" bundle:[NSBundle mainBundle]];
    nmvc.urlData = urlData;
    nmvc.phonesArray = phonesArray;
    nmvc.accountUnli = accountUnli;
    nmvc.productPlanFromMainVC = productPlan;
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:nmvc animated:YES];
}


- (IBAction)btnShowHistory:(id)sender {
    [self showBoltOnHinstoryPopup];
}

-(void) showBoltOnHinstoryPopup{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView:[self createBoltOnHistoryView]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK",nil]];
    [alertView setTintColor:[self colorFromHexString:@"#FF8F05"]];
    
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
        [self boltOnClicked];
    }];
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];
}

- (void)boltOnClicked {
    [viewBoltOn.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    viewBoltOn.hidden = NO;
    viewBoltOnBG.hidden = NO;
    btnBoltOnHistoryNew.hidden = NO;
    [viewBoltOn addSubview:[self createAddBoltOnView]];
    
    [btnAddBoltOn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btnAddBoltOn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakControl) {
        
        self->addBoltOnAlert = [[UIAlertView alloc]initWithTitle:@"Do you want to proceed with bolt-on?" message:@"" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        self->addBoltOnAlert.tag = 2;
        [self->addBoltOnAlert show];
    }];
    
    [self->btnCancelBoltOn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self->btnCancelBoltOn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakControl) {
        self->viewBoltOn.hidden = YES;
        self->viewBoltOnBG.hidden = YES;
        self->btnBoltOnHistoryNew.hidden = YES;
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2){
        if(buttonIndex == 0){
            viewBoltOn.hidden = YES;
            viewBoltOnBG.hidden = YES;
            btnBoltOnHistoryNew.hidden = YES;
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(addToBoltON) onTarget:self withObject:nil animated:YES];
        }
    }
}

// bolt on alert bottom Button action
- (IBAction)btnBoltOnHistoryNew:(id)sender {
    if ([btnBoltOnHistoryNew.titleLabel.text  isEqual: @"Bolt-on history"]) {
        [viewBoltOn.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        viewBoltOn.hidden = NO;
        viewBoltOnBG.hidden = NO;
        btnBoltOnHistoryNew.hidden = NO;
        [viewBoltOn addSubview:[self createBoltOnHistoryView]];
        self.viewBoltOnHistory.hidden = NO;
        [btnBoltOnHistoryNew setTitle:@"OK" forState:UIControlStateNormal];
    } else {
        [btnBoltOnHistoryNew setTitle:@"Bolt-on history" forState:UIControlStateNormal];
        [viewBoltOn.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        viewBoltOn.hidden = NO;
        viewBoltOnBG.hidden = NO;
        btnBoltOnHistoryNew.hidden = NO;
        self.viewBoltOnHistory.hidden = YES;
        [viewBoltOn addSubview:[self createAddBoltOnView]];
    }
}

- (IBAction)btnActivateSIM:(id)sender {
    SimActivatorViewController *VC = [[SimActivatorViewController alloc]initWithNibName:@"SimActivatorViewController" bundle:[NSBundle mainBundle]];
    VC.clientId = clientID;
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:VC animated:YES];
}

- (UIView *)createBoltOnHistoryView {
    
    self.boltOnHistoryView.hidden = NO;
    self.boltOnHistory_1 = [NSString stringWithFormat:@"%dGB",(intBoltTotal/1024)];
    
    if (bolton.count > 6) {
        [self.boltOnHistoryView setFrame:CGRectMake(10, 60, viewBoltOn.frame.size.width - 20, (6 + 1) * 38)];
    } else {
        [self.boltOnHistoryView setFrame:CGRectMake(10, 60, viewBoltOn.frame.size.width - 20, (bolton.count + 1) * 38)];
    }
    
    viewBoltOn.frame = CGRectMake(viewBoltOn.frame.origin.x,viewBoltOn.frame.origin.y, viewBoltOn.frame.size.width, self.boltOnHistoryView.frame.size.height + 60 + 40 + 30);
    viewBoltOn.center = self.view.center;
    btnBoltOnHistoryNew.frame = CGRectMake(btnBoltOnHistoryNew.frame.origin.x, viewBoltOn.frame.origin.y + viewBoltOn.frame.size.height - 40, btnBoltOnHistoryNew.frame.size.width, btnBoltOnHistoryNew.frame.size.height);
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewBoltOn.frame.size.width, viewBoltOn.frame.size.height)];
    
    UILabel *boltOnHistoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 290, 25)];
    boltOnHistoryTitle.backgroundColor = [UIColor clearColor];
    boltOnHistoryTitle.textColor = [UIColor blackColor];
    boltOnHistoryTitle.textAlignment = NSTextAlignmentLeft;
    boltOnHistoryTitle.font = [UIFont fontWithName:@"Arial" size:17];
    UIFontDescriptor * fontD = [boltOnHistoryTitle.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    boltOnHistoryTitle.font = [UIFont fontWithDescriptor:fontD size:0];
    boltOnHistoryTitle.text = @"Bolt-on History";
    
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 290, 20)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont fontWithName:@"Arial" size:15];
    dateLabel.text = [NSString stringWithFormat:@"%@ to %@", self.boltOnHistory_2, self.boltOnHistory_3];
    
    
    UILabel *boltOnTotal = [[UILabel alloc] initWithFrame:CGRectMake(10, boltOnHistoryView.frame.origin.y + boltOnHistoryView.frame.size.height, 290, 30)];
    boltOnTotal.backgroundColor = [UIColor clearColor];
    boltOnTotal.textColor = [UIColor blackColor];
    boltOnTotal.textAlignment = NSTextAlignmentLeft;
    boltOnTotal.font = [UIFont fontWithName:@"Arial" size:17];
    UIFontDescriptor *totalfontD = [boltOnTotal.font.fontDescriptor
                                    fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    boltOnTotal.font = [UIFont fontWithDescriptor:totalfontD size:0];
    boltOnTotal.text = [NSString stringWithFormat:@"Total Bolt-ons: %@", self.boltOnHistory_1];
    
    
    [demoView addSubview:boltOnTotal];
    [demoView addSubview:boltOnHistoryTitle];
    [demoView addSubview:dateLabel];
    [demoView addSubview:self.boltOnHistoryView];
    [self.boltOnHistoryView bringSubviewToFront:self.boltOnHistoryTableView];
    return demoView;
}

- (UIView *)createAddBoltOnView {
    viewBoltOn.frame = CGRectMake(viewBoltOn.frame.origin.x,viewBoltOn.frame.origin.y, viewBoltOn.frame.size.width, 155 + [arrayBoltOnLookUp count] * 44.0f);
    viewBoltOnPopup.frame = CGRectMake(0, 0, viewBoltOn.frame.size.width, 155 + [arrayBoltOnLookUp count] * 44.0f);
    UIView *addBoltOnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewBoltOn.frame.size.width, 155 + [arrayBoltOnLookUp count] * 44.0f)];
    viewBoltOn.center = self.view.center;
    btnBoltOnHistoryNew.frame = CGRectMake(btnBoltOnHistoryNew.frame.origin.x,viewBoltOn.frame.origin.y + viewBoltOn.frame.size.height - 35, btnBoltOnHistoryNew.frame.size.width, btnBoltOnHistoryNew.frame.size.height);
    
    [addBoltOnView addSubview:viewBoltOnPopup];
    return addBoltOnView;
}

-(void) addToBoltON{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/addbolton/%@/%@/%@", PORTAL_URL, phoneID,strBoltOnId,sessionID];
    
    NSLog(@"strURL: %@",strPortalURL);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSString * resulttext = [dictData objectForKey:@"resulttext"];
        
        if ([resulttext rangeOfString:@"addBolton Queued with Job ID"].location == NSNotFound) {
            [self alertStatus:resulttext:@"Data Bolt-on"];
        } else {
            [self alertStatus:@"Thanks! We are busy bolting on your bolt-on and it will take a few minutes to complete. We'll let you know when we're done.":@"Data Bolt-on"];
        }
    } else {
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError:@"Error"];
    }
}

- (void)showRightView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox {
    selectedCell = checkBox.tag;
    
    NSString * planname = @"";
    NSString * planamount = @"";
    NSDictionary *jsonData = [[NSDictionary alloc]init];
    jsonData = [arrayBoltOnLookUp objectAtIndex:selectedCell];
    if (![jsonData  isEqual: @""]) {
        planname = [jsonData objectForKey:@"planname"];
        planname = [planname stringByReplacingOccurrencesOfString: @"Data Bolt-on" withString:@""];
        planamount = [jsonData objectForKey:@"planamount"];
        NSString * boltOnID = [jsonData objectForKey:@"id"];
        strBoltOnId = boltOnID;
    }
    [boltOnListTable reloadData];
}

- (void)tappedOnLblPortingMessage:(UITapGestureRecognizer *)gesture {
    [self getNewVerificationCode];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == boltOnListTable) {
        NSLog(@"user selected %@",[arrayBoltOnLookUp objectAtIndex:indexPath.section]);
        selectedCell = indexPath.section;
        
        NSString * planname = @"";
        NSString * planamount = @"";
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [arrayBoltOnLookUp objectAtIndex:selectedCell];
        if (![jsonData  isEqual: @""]) {
            planname = [jsonData objectForKey:@"planname"];
            planname = [planname stringByReplacingOccurrencesOfString: @"Data Bolt-on" withString:@""];
            planamount = [jsonData objectForKey:@"planamount"];
            NSString * boltOnID = [jsonData objectForKey:@"id"];
            strBoltOnId = boltOnID;
        }
        [boltOnListTable reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == boltOnListTable) {
        NSLog(@"user de-selected %@",[arrayBoltOnLookUp objectAtIndex:indexPath.section]);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.boltOnHistoryTableView) {
        return bolton.count;
    } else if (tableView == boltOnListTable) {
        return [arrayBoltOnLookUp count];
    } else if (tableView == tableViewInactive) {
        if (self.containsIntlVoice == YES) {
            return 4;
        }
        return 3;
    }
    return [productPlanArray count];
}

#pragma mark - Cell For Row At IndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.boltOnHistoryTableView) {
        
        BoltOnHistoryCell *cell = (BoltOnHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"boltOnHistoryCellId"];
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BoltOnHistoryCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDateFormatter *expiryFormatter = [[NSDateFormatter alloc] init];
        expiryFormatter.dateFormat = @"dd-MM-yyyy";
        NSDateFormatter *presentationFormatter = [[NSDateFormatter alloc] init];
        presentationFormatter.dateFormat = @"dd MMM yyyy";
        
        NSDictionary *boltOn = [bolton objectAtIndex:indexPath.section];
        
        NSDate *purchaseDate = [formatter dateFromString:boltOn[@"DateTimeInserted"]];
        NSDate *expiryDate = [expiryFormatter dateFromString:boltOn[@"expiry"]];
        
        cell.boltOnSizeLabel.text = [NSString stringWithFormat:@"%dGB Bolt-on",([boltOn[@"partition_incl_text"] intValue]/1024)];
        cell.purchasedDateLabel.text = [presentationFormatter stringFromDate:purchaseDate];
        cell.expiryDateLabel.text = [presentationFormatter stringFromDate:expiryDate];
        return cell;
        
    } else if (tableView == boltOnListTable) {
        NSString * planname = @"";
        NSString * planamount = @"";
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [arrayBoltOnLookUp objectAtIndex:indexPath.section];
        if (![jsonData  isEqual: @""]) {
            planname = [jsonData objectForKey:@"planname"];
            planname = [planname stringByReplacingOccurrencesOfString: @"Data Bolt-on" withString:@""];
            planamount = [jsonData objectForKey:@"planamount"];
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        if(indexPath.section == selectedCell){
            [myCheckBox setOn:YES animated:YES];
        } else {
            [myCheckBox setOn:NO animated:YES];
        }
        cell.accessoryView = myCheckBox;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - $%@",planname, planamount];
        return cell;
    } else if (tableView == tableViewInactive) {
        static NSString *simpleTableIdentifier = @"Cell";
        HomeViewItemCell *cell = (HomeViewItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeViewItemCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSString *name_text = self.waitingTextInCells;
        NSString *imageIconName = @"";
        NSString *denomination = @"";
        
        if (indexPath.section == 0){
            if (!self.waitingTextInCells) {
                name_text = @"Voice pack";
            }
            imageIconName = @"voice_icon";
            denomination = @"Min";
        } else if (indexPath.section == 1){
            if (!self.waitingTextInCells) {
                name_text = @"SMS pack";
            }
            imageIconName = @"sms_icon";
            denomination = @"SMS";
        } else if (indexPath.section == 2){
            if (!self.waitingTextInCells) {
                name_text = @"Data pack";
            }
            imageIconName = @"data_icon";
            denomination = @"GB";
        } else {
            if (!self.waitingTextInCells) {
                name_text = @"Intl Voice pack";
            }
            imageIconName = @"Intl_icon";
            denomination = @"Min";
        }
        
        cell.lblUnits.text = [NSString stringWithFormat:@"%@",denomination];
        cell.lblNameText.text = name_text;
        cell.lblNameText.textColor = [UIColor lightGrayColor];
        [cell.iconImg setImage:[UIImage imageNamed:imageIconName]];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
        progressView.color = [UIColor lightGrayColor];
        progressView.showText = @NO;
        progressView.progress = 100;
        progressView.borderRadius = @20;
        progressView.animate = @NO;
        progressView.showBackgroundInnerShadow = @NO;
        progressView.showStroke = @NO;
        progressView.background = [UIColor lightGrayColor];
        progressView.type = LDProgressSolid;
        cell.lblUsage.text = @"";
        cell.lblTotalData.text = @"";
        [cell.viewProgressHolder addSubview:progressView];
        return cell;
    } else {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:indexPath.section];
        static NSString *simpleTableIdentifier = @"Cell";
        HomeViewItemCell *cell = (HomeViewItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeViewItemCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.btnBoltOn addTarget:self action:@selector(boltOnClicked) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor clearColor];
        
        if (![jsonData  isEqual: @"temp"]) {
            NSString *expiry = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"expiry"]];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd-MM-yyyy";
            NSDate *yourDate = [dateFormatter dateFromString:expiry];
            dateFormatter.dateFormat = @"dd MMM yyyy";
            
            cell.lblExpiry.text = [NSString stringWithFormat:@"Your pack will expire on %@",[dateFormatter stringFromDate:yourDate]];
            cell.lblNameText.text = [NSString stringWithFormat:@"%@ %@",[jsonData objectForKey:@"name_text"],@"pack"];
            
            if ([validbolton isEqual: @"valid"]) {
                if ([cell.lblNameText.text isEqual:@"Data pack"]) {
                    if (!self.isHWBB) {
                        cell.btnBoltOn.hidden = NO;
                    } else {
                        cell.btnBoltOn.hidden = YES;
                    }
                    cell.btnBoltOnHistory.hidden = NO;
                    [self getDateRanges:yourDate];
                } else {
                    cell.btnBoltOn.hidden = YES;
                    cell.btnBoltOnHistory.hidden = YES;
                }
            } else {
                cell.btnBoltOn.hidden = YES;
                cell.btnBoltOnHistory.hidden = YES;
            }
            
            float currentUsage = [[jsonData objectForKey:@"usage"] floatValue];
            NSString *denomination =[jsonData objectForKey:@"denomination_text"];
            
            int unli = 0;
            NSString *name = [jsonData objectForKey:@"name"];
            if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
                unli = 0;
            } else {
                unli = 1;
            }
            
            NSString *name_text =[jsonData objectForKey:@"name_text"];
            NSString *imageIconName = @"sms_icon";
            NSString *progressColor = @"#FE4505";
            
            if ([name_text isEqualToString:@"Data"]) {
                imageIconName = @"data_icon";
                denomination = @"GB";
                progressColor = @"#FF8F05";//orange
            } else if ([name_text isEqualToString:@"Voice"]){
                imageIconName = @"voice_icon";
                progressColor = @"#E1054F";//purple
            } else if ([name_text isEqualToString:@"Intl Voice"]){
                imageIconName = @"Intl_icon";
                denomination = @"Min";
                progressColor = @"#939498";//grey
            } else if ([name_text isEqualToString:@"SMS"]){
                imageIconName = @"sms_icon";
                denomination = @"SMS";
                progressColor = @"#FE4505";
            } else if ([name_text isEqualToString:@"Yomojo Voice"]){
                imageIconName = @"voice_icon";
                progressColor = @"#E1054F";
            } else if ([name_text isEqualToString:@"Excess Credit"]){
                imageIconName = @"us-dollar-64";
                progressColor = @"#F1C73C";
                
//                NSString *expiry = [NSString stringWithFormat:@"%@",[resultDataForUsage objectForKey:@"credit_expirydate"]];
//                cell.lblExpiry.text = [NSString stringWithFormat:@"Your pack will expire on %@",[dateFormatter stringFromDate:yourDate]];
            } else if ([name_text isEqualToString:@"PAYG Spend"]){
                imageIconName = @"";
                progressColor = @"";
            }
            
            [cell.iconImg setImage:[UIImage imageNamed:imageIconName]];
            cell.lblUnits.text = [NSString stringWithFormat:@"%@",denomination];
            float partition_incl_text = [[jsonData objectForKey:@"partition_incl_text"] floatValue];
            float usage = [[jsonData objectForKey:@"usage"] floatValue];
            
            if (unli == 1) {
                NSString *expiry = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"expiry"]];
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"dd-MM-yyyy";
                NSDate *yourDate = [dateFormatter dateFromString:expiry];
                dateFormatter.dateFormat = @"dd MMM yyyy";
                
                NSString *autorenewal = [jsonData objectForKey:@"autorenewal"];
                if ([autorenewal isEqual: @"auto"]) {
                    lblDueDate.text = [NSString stringWithFormat:@"Plan renews on %@",[dateFormatter stringFromDate:yourDate]];
                } else {
                    lblDueDate.text = [NSString stringWithFormat:@"Plan expire on %@",[dateFormatter stringFromDate:yourDate]];
                }
                cell.lblUsage.text = @"unlimited";
                
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                
                progressView.color = [self colorFromHexString:progressColor];
                progressView.showText = @NO;
                progressView.progress = 100;
                progressView.borderRadius = @20;
                progressView.animate = @NO;
                progressView.showBackgroundInnerShadow = @NO;
                progressView.showStroke = @NO;
                progressView.background = [UIColor lightGrayColor];
                [self colorFromHexString:progressColor];
                
                progressView.type = LDProgressSolid;
                [cell.viewProgressHolder addSubview:progressView];
            } else if (unli == 0) {
                
                if ([name_text isEqualToString:@"PAYG Spend"]) {
                    cell.lblUsage.text = [NSString stringWithFormat:@"%@",payg];
                    cell.lblExpiry.text = nil;
                    cell.lblUsage.textColor = [UIColor darkGrayColor];
                } else {
                    if (accountUnli == 1) {
                        cell.lblExpiry.hidden = YES;
                    } else {
                        if ([planID isEqual: @"5"]) {
                            cell.lblExpiry.hidden = YES;
                        } else {
                            cell.lblExpiry.hidden = NO;
                        }
                    }
                    
                    UIColor *progressViewBackground = [UIColor lightGrayColor];
                    
                    if ([name_text isEqualToString:@"Data"]) {
                        float allocateddata = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
                        float totalData = (allocateddata + intBoltTotal);
                        float res12 = [[resource objectForKey:@"12"]floatValue];
                        float res1 = [[resource objectForKey:@"1"]floatValue];
                        float usedData = (totalData - (res12 + res1));
                        
                        if ( [[jsonData objectForKey:@"partition_incl_text"] isEqualToString: @"(null)"] ) {
                            cell.lblUnits.text = @"GB";
                            cell.lblUsage.text = @"unlimited";
                            progressViewBackground = [UIColor orangeColor];
                        } else {
                            if ((totalData/1024) < 0.99) {
                                cell.lblUnits.text = @"MB";
                                cell.lblUsage.text = [NSString stringWithFormat:@"%.2f of %.2f",(usedData),totalData];
                                cell.lblUsage.text = [NSString stringWithFormat:@"%.2f remaining",(totalData - usedData)];
                                cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.2f",totalData];
                            } else {
                                
                                NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
                                
                                if ([phoneDetails[@"network"] isEqualToString:@"HWBB"]) {
                                    self.isHWBB = YES;
                                    [self->btnChangePlanProp setHidden:YES];
                                    cell.lblUnits.text = @"GB";
                                    cell.lblUsage.text = [NSString stringWithFormat:@"%.2f remaining",((totalData - usage)/1024)];
                                    cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.2f",(totalData/1024)];
                                } else {
                                    cell.lblUnits.text = @"GB";
                                    cell.lblUsage.text = [NSString stringWithFormat:@"%.2f of %.2f",(usedData/1024),totalData/1024];
                                    cell.lblUsage.text = [NSString stringWithFormat:@"%.2f remaining",((totalData - usedData)/1024)];
                                    cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.2f",(totalData/1024)];
                                }
                            }
                        }
                        
                        if (intBoltTotal && usedData != allocateddata + intBoltTotal) {
                            //boltON
                            CGRect screenBounds = [[UIScreen mainScreen] bounds];
                            LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                            
                            progressView.color = [UIColor YomoLightOrangeColor];
                            progressView.showText = @NO;
                            progressView.progress = (((res1 + res12)/1024)/(totalData/1024));
                            progressView.borderRadius = @20;
                            progressView.animate = @NO;
                            progressView.showBackgroundInnerShadow = @NO;
                            progressView.showStroke = @NO;
                            progressView.background = progressViewBackground;
                            progressView.type = LDProgressSolid;
                            [cell.viewProgressHolder addSubview:progressView];
                            
                            CGRect screenBounds1 = [[UIScreen mainScreen] bounds];
                            LDProgressView *progressView1 = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds1.size.width -screenBounds1.size.width/20, 32)];
                            progressView1.color = [self colorFromHexString:progressColor];
                            progressView1.showText = @NO;
                            progressView1.progress = ((res12/1024)/(totalData/1024));
                            progressView1.borderRadius = @20;
                            progressView1.animate = @NO;
                            progressView1.showBackgroundInnerShadow = @NO;
                            progressView1.showStroke = @NO;
                            progressView1.background = [UIColor clearColor];
                            progressView1.type = LDProgressSolid;
                            [cell.viewProgressHolder addSubview:progressView1];
                        } else {
                            CGRect screenBounds = [[UIScreen mainScreen] bounds];
                            LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                            progressView.color = [self colorFromHexString:progressColor];// [UIColor YomoLightOrangeColor];
                            progressView.showText = @NO;
                            progressView.progress = 1 - ((usage/1024)/(totalData/1024));
                            progressView.borderRadius = @20;
                            progressView.animate = @NO;
                            progressView.showBackgroundInnerShadow = @NO;
                            progressView.showStroke = @NO;
//                            progressViewBackground = [UIColor orangeColor];
                            progressView.background = progressViewBackground;
                            progressView.type = LDProgressSolid;
                            [cell.viewProgressHolder addSubview:progressView];
                            
//                            cell.lblUnits.text = @"GB";
//                            cell.lblUsage.text = @"unlimited";
//                            cell.lblTotalData.text = NULL;
                        }
                        
                        if ([planID  isEqual: @"5"]) {
                            NSString *autorenewal = [jsonData objectForKey:@"autorenewal"];
                            if ([autorenewal  isEqual: @"auto"]) {
                                lblDueDate.text = [NSString stringWithFormat:@"Plan renews on %@",[dateFormatter stringFromDate:yourDate]];
                            } else {
                                lblDueDate.text = [NSString stringWithFormat:@"Plan expire on %@",[dateFormatter stringFromDate:yourDate]];
                            }
                            cell.lblExpiry.text = nil;
                        }
                        
                    } else if ([name_text isEqualToString:@"SMS"]) {
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f of %@",currentUsage,[jsonData objectForKey:@"partition_incl_text"]];
                        CGRect screenBounds = [[UIScreen mainScreen] bounds];
                        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                        progressView.color = [self colorFromHexString:progressColor];
                        progressView.showText = @NO;
                        progressView.progress = 1 - (usage/partition_incl_text);
                        progressView.borderRadius = @20;
                        progressView.animate = @NO;
                        progressView.showBackgroundInnerShadow = @NO;
                        progressView.showStroke = @NO;
                        progressView.background = progressViewBackground;
                        progressView.type = LDProgressSolid;
                        
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f remaining",(partition_incl_text - usage)];
                        cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.0f",partition_incl_text];
                        
                        [cell.viewProgressHolder addSubview:progressView];
                    } else if ([name_text isEqualToString:@"Voice"]) {
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f of %@",currentUsage,[jsonData objectForKey:@"partition_incl_text"]];
                        CGRect screenBounds = [[UIScreen mainScreen] bounds];
                        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                        progressView.color = [self colorFromHexString:progressColor];
                        progressView.showText = @NO;
                        progressView.progress = 1 - (usage/partition_incl_text);
                        progressView.borderRadius = @20;
                        progressView.animate = @NO;
                        progressView.showBackgroundInnerShadow = @NO;
                        progressView.showStroke = @NO;
                        progressView.background = progressViewBackground;
                        progressView.type = LDProgressSolid;
                        
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f remaining",(partition_incl_text - usage)];
                        cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.0f",partition_incl_text];
                        [cell.viewProgressHolder addSubview:progressView];
                    } else if ([name_text isEqualToString:@"Intl Voice"]) {
                        cell.lblExpiry.hidden = NO;
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f of %@",currentUsage,[jsonData objectForKey:@"partition_incl_text"]];
                        CGRect screenBounds = [[UIScreen mainScreen] bounds];
                        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                        progressView.color = [self colorFromHexString:progressColor];
                        progressView.showText = @NO;
                        progressView.progress = 1 - (usage/partition_incl_text);
                        progressView.borderRadius = @20;
                        progressView.animate = @NO;
                        progressView.showBackgroundInnerShadow = @NO;
                        progressView.showStroke = @NO;
                        progressView.background = progressViewBackground;
                        progressView.type = LDProgressSolid;
                        
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.0f remaining",(partition_incl_text - usage)];
                        cell.lblTotalData.text = [NSString stringWithFormat:@"out of %.0f",partition_incl_text];
                        
                        [cell.viewProgressHolder addSubview:progressView];
                    } else if ([name_text isEqualToString:@"Excess Credit"]){
                        cell.lblUnits.text = @"";
                        if (![expiry  isEqual: @"(null)"]) {
                            cell.lblExpiry.hidden = NO;
                        } else {
                            if (usage > 0) {
                                cell.lblExpiry.hidden = NO;
                                cell.lblExpiry.text = lblExcessCreditExpiry;
                                if (usage < 0.0001) {
                                    cell.lblExpiry.hidden = YES;
                                    progressColor = @"#939498";
                                }
                            } else {
                                cell.lblExpiry.hidden = YES;
                            }
                        }
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.2f remaining",usage];
                        CGRect screenBounds = [[UIScreen mainScreen] bounds];
                        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                        progressView.color = [self colorFromHexString:progressColor];
                        progressView.showText = @NO;
                        progressView.progress = usage/partition_incl_text;
                        progressView.borderRadius = @20;
                        progressView.animate = @NO;
                        progressView.showBackgroundInnerShadow = @NO;
                        progressView.showStroke = @NO;
                        progressView.background = progressViewBackground;
                        progressView.type = LDProgressSolid;
                        [cell.viewProgressHolder addSubview:progressView];
                    } else {
                        cell.lblUsage.text = [NSString stringWithFormat:@"%.2f of %@",currentUsage,[jsonData objectForKey:@"partition_incl_text"]];
                        CGRect screenBounds = [[UIScreen mainScreen] bounds];
                        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-7, 0, screenBounds.size.width -screenBounds.size.width/20, 32)];
                        progressView.color = [self colorFromHexString:progressColor];
                        progressView.showText = @NO;
                        progressView.progress = usage/partition_incl_text;
                        progressView.borderRadius = @20;
                        progressView.animate = @NO;
                        progressView.showBackgroundInnerShadow = @NO;
                        progressView.showStroke = @NO;
                        progressView.background = progressViewBackground;
                        progressView.type = LDProgressSolid;
                        [cell.viewProgressHolder addSubview:progressView];
                    }
                }
            }
        }
        
        if ([self.lblDueDate.text containsString: @"Plan renews"]) {
            self.lblDueDate.hidden = NO;
        }
        if ([cell.lblExpiry.text containsString: @"null"]) {
            cell.lblExpiry.hidden = YES;
        }
//        if ([planID  isEqual: @"5"]) {
//            NSString *autorenewal = [jsonData objectForKey:@"autorenewal"];
//            if ([autorenewal isEqual: @"auto"]) {
//                self.lblDueDate.hidden = NO;
//            }
//        }
//        cell.lblExpiry.hidden = YES; // remove this line to show lblExpiry in some cases
        return cell;
    }
    return nil;
}

@end
