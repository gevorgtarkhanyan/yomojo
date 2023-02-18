//
//  SimsAndDevicesViewController.m
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 11/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "SimsAndDevicesViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import <PKRevealController/PKRevealController.h>
//#import <Google/Analytics.h>

#define INT_ROAMING 1
#define SMS_LIMIT 2
#define VOICE_MAIL 3
#define CALL_WAITING 4
#define CALL_DIVERTS 5
#define CALLER_ID 6
#define AUTO_TOPUP 7
#define CANCEL_SIM 8
#define GET_NEW_SIM 9
#define REPORT_SIM 10
#define SET_PRIMARY 11
#define SET_PRIMARY_CONFIRM 12

@interface SimsAndDevicesViewController ()
{
    NSMutableArray *smsLimitArray;
    NSString *smsLimitStr;
    UIPickerView *smsPickerView;
    
    NSMutableArray *autoTopUpArray;
    NSString *autoTopUpStr;
    UIPickerView *autoTopUpPickerView;
    
    NSString *wpl;
    NSString *intl;
    NSString *chcw;
    NSString *fcp;
    NSString *fcr;
    NSString *tua;
    NSString *tuf;
    NSString *tud;
    NSString *tup;
    NSString *smstup;
    NSString *minbal;
    NSString *internationalRoaming;
    NSString *callStrURL;
    NSString *label;
    int tub;
    int callerID;
    int smsLimit;
    int callWaiting;
    int fnrt;
    int uncondf;
    int fbusy;
    NSString *fnoreply;
    int funreach;
    int voiceMailValue;
    int voiceMail;
    int callDiverts;
    int autoTopup;
    int speech_telephony_baroutall;
    int billingType;
    
    NSString *fname;
    NSString *lname;
    NSString *usersEmail;
    NSString *usersPhone;
    NSString *planId;
    NSString *planType;
    NSString *subcriptionType;
    BOOL primaryPhone;
    BOOL is4G;
}

@property (weak, nonatomic) IBOutlet UIView *internationalRoamingView;
@property (weak, nonatomic) IBOutlet UIView *callWaitingView;
@property (weak, nonatomic) IBOutlet UIView *callerIdView;
@property (weak, nonatomic) IBOutlet UIView *voicemailView;
@property (weak, nonatomic) IBOutlet UIView *callDivertsView;
@property (weak, nonatomic) IBOutlet UIView *autoTopUpListView;
//@property (weak, nonatomic) IBOutlet UIView *premiumSmsView;
@property (weak, nonatomic) IBOutlet UIView *getNewSimView;
@property (weak, nonatomic) IBOutlet UIView *reportLostSimListView;
//@property (weak, nonatomic) IBOutlet UIView *activateView;


//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getNewSimTopConstraint;

@end

@implementation SimsAndDevicesViewController
@synthesize oneSwitch,twoSwitch,myScrollView;//,contentView;
@synthesize urlData,phonesArrayIndex,phonesArray,lblName,lblNickName,lblNumber,lblDevice,withFamily;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    //    [tracker set:kGAIScreenName value:@"PhoneSettings Page"];
    //    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    }
    
    [lblNickName setHidden:YES];
    [simNickname setHidden:YES];
//    _btnSMSLimit.layer.cornerRadius = 10;
    autoTopUpAmountBtn.layer.cornerRadius = 10;
    
    //lblNickName.text= [lblNickName.text stringByReplacingOccurrencesOfString: @"'" withString:@""];
    //lblNickName.text = [lblNickName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
    
    
    // Do any additional setup after loading the view from its nib.
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getPhones) onTarget:self withObject:nil animated:YES];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"]intValue];
    billingType = [[userLogin objectForKey:@"billingType"]intValue];
    
    if (billingType == 1) {
        subcriptionType = @"POSTPAID";
    } else {
        subcriptionType = @"PREPAID";
    }
    
    if (phonesArrayIndex == 0) {
        primaryPhone = YES;
        primaryAccBtn.enabled = NO;
        [primaryAccBtn setTitle:@"Primary Service" forState:UIControlStateNormal];
    } else {
        primaryPhone = NO;
        primaryAccBtn.enabled = YES;
        [primaryAccBtn setTitle:@"Make Primary Service" forState:UIControlStateNormal];
    }
    
    NSLog(@"primaryPhone: %d",phonesArrayIndex);
    
    myScrollView.delegate = self;
    //autolayout scroll view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"%f",screenWidth);
    
//    contentView.translatesAutoresizingMaskIntoConstraints = NO;
//    [myScrollView addSubview:contentView];
//
//    NSDictionary *views = @{@"contentView":contentView};
//    NSDictionary *metrics = @{@"height" : @1050, @"width" : [NSString stringWithFormat:@"%f",screenWidth]};
//    [myScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView(height)]|" options:kNilOptions metrics:metrics views:views]];
//    [myScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]|" options:kNilOptions metrics:metrics views:views]];
//
    
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    phoneID = [phoneDetails objectForKey:@"id"];
    lblNickName.text = [phoneDetails objectForKey:@"label"];
    // lblName.text = [phoneDetails objectForKey:@"label"];
    lblName.text = [NSString stringWithFormat:@"%@ - %@",[phoneDetails objectForKey:@"label"],subcriptionType];
    
    NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
    
    if ([arrayPhoneNum count] <= 1) {
        lblNumber.text = [phoneDetails objectForKey:@"number"];
    } else {
        lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
    }
    
    NSMutableArray *personalDetailsArray = [responseDict objectForKey:@"PERSONDETAILS"];
    NSMutableDictionary *personalDetailsDict = [personalDetailsArray objectAtIndex:0];
    NSLog(@"personalDetailsDict: %@",personalDetailsDict);
    NSLog(@"%@",phoneDetails);
    
    
    fname = [personalDetailsDict objectForKey:@"FIRSTNAME"];
    lname = [personalDetailsDict objectForKey:@"LASTNAME"];
    usersEmail = [personalDetailsDict objectForKey:@"EMAILADDRESS"];
    usersPhone = [phoneDetails objectForKey:@"number"];
    
    if ([[phoneDetails objectForKey:@"network"] isEqualToString:@"HWBB"]) {
        planId = @"6";
    } else {
        planId = [phoneDetails objectForKey:@"planid"];
    }
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    
    [HUB showWhileExecuting:@selector(getSettingsValue) onTarget:self withObject:nil animated:YES];
    
    smsLimitArray = [[NSMutableArray alloc]initWithObjects:@"0",@"20",@"50",@"100", nil];
    
    smsPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(screenRect.origin.x, screenHeight-screenWidth/2, screenWidth, screenWidth/2)];
    smsPickerView.showsSelectionIndicator = YES;
    smsPickerView.hidden = NO;
    smsPickerView.delegate = self;
    [smsPickerView setBackgroundColor:[UIColor orangeColor]];
    smsPickerView.tag = SMS_LIMIT;
    [self.view addSubview:smsPickerView];
    [smsPickerView setHidden:YES];
    
    
    
    //    autoTopUpArray = [[NSMutableArray alloc]initWithObjects:@"0",@"20",@"50",@"100", nil];
    //    autoTopUpPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(screenRect.origin.x, screenHeight-screenWidth/2, screenWidth, screenWidth/2)];
    //    autoTopUpPickerView.showsSelectionIndicator = YES;
    //    autoTopUpPickerView.hidden = NO;
    //    autoTopUpPickerView.delegate = self;
    //    [autoTopUpPickerView setBackgroundColor:[UIColor orangeColor]];
    //    autoTopUpPickerView.tag = AUTO_TOPUP;
    //    [self.view addSubview:autoTopUpPickerView];
    //    [autoTopUpPickerView setHidden:YES];
    
    
    [self.view addSubview:reportView];
    [reportView setHidden:YES];
    [self.view addSubview:callDivertView];
    [callDivertView setHidden:YES];
    [self.view addSubview:autoTopUpView];
    [autoTopUpView setHidden:YES];
    
    autoTopUpArray = [[NSMutableArray alloc]initWithObjects:@"10",@"15",@"20",@"30",@"50",@"100", nil];
    
    autoTopUpPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(screenRect.origin.x, screenHeight-screenWidth/2, screenWidth, screenWidth/2)];
    autoTopUpPickerView.showsSelectionIndicator = YES;
    autoTopUpPickerView.hidden = NO;
    autoTopUpPickerView.delegate = self;
    [autoTopUpPickerView setBackgroundColor:[UIColor orangeColor]];
    autoTopUpPickerView.tag = AUTO_TOPUP;
    [self.view addSubview:autoTopUpPickerView];
    [autoTopUpPickerView setHidden:YES];
    
    [callDivertTxtField addTarget:self action:@selector(setupDivertTxtField:) forControlEvents:UIControlEventEditingChanged];
    callDivertTxtField.delegate=self;
}

-(void)setupDivertTxtField:(UITextField *)textField
{
    if ([textField.text length] > 8) {
        callDivertTxtField.text = [callDivertTxtField.text substringToIndex:8];
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


- (void) alertStatusConfirm:(NSString *)msg :(NSString *)title {
    alertSetPrimaryConfirm = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertSetPrimaryConfirm.tag = SET_PRIMARY_CONFIRM;
    [alertSetPrimaryConfirm show];
    
}

-(void) getPhones {
    __block NSMutableArray *tempPhonesArray = [[NSMutableArray alloc]init];
    NSMutableArray *phonesArrays = [[NSMutableArray alloc]init];
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/get_phones/%@/",clientID];
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
            tempPhonesArray = [dictData objectForKey:@"result"];
            
            for (int i = 0; i < [tempPhonesArray count]; i++) {
                NSMutableDictionary *dictPhones = [tempPhonesArray objectAtIndex:i];
                NSString * phoneStatus = [dictPhones objectForKey:@"phone_status"];
                if ([phoneStatus isEqual: @"Active"]) {
                    [phonesArrays addObject:dictPhones];
                }
            }
        } else {
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            [self alertStatus:strError:@"Error"];
        }
        self->phonesArray = phonesArrays;
}


-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}

- (void) getSettingsValue{
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/get_details_per_phone/%@/%@/%@",clientID,phoneID,sessionID];
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{

            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
            NSMutableDictionary *phoneResultData = [resultData objectForKey:@"phone"];
            
            self->planType = [resultData objectForKey:@"plan_type"];
            self->lblDevice.text = [phoneResultData objectForKey:@"phonetype_name"];
            self->callWaiting = [[phoneResultData objectForKey:@"primary_features_callholdcallwait"]intValue];
            self->smsLimit = [[phoneResultData objectForKey:@"psms_spend"]intValue];
            self->callerID = [[phoneResultData objectForKey:@"primary_features_clip"]intValue];
            self->internationalRoaming = [phoneResultData objectForKey:@"primary_features_roaming"];
            self->voiceMailValue = [[phoneResultData objectForKey:@"speech_telephony_forwardbusy"]intValue];
            self->voiceMail = [[phoneResultData objectForKey:@"voicemail"]intValue];
            self->autoTopup = [[phoneResultData objectForKey:@"top_up_balance"]intValue];
            self->speech_telephony_baroutall = [[phoneResultData objectForKey:@"speech_telephony_baroutall"]intValue];
            self->callDiverts = [[phoneResultData objectForKey:@"speech_telephony_forwarduncond"]intValue];
            self->wpl =[phoneResultData objectForKey:@"primary_servicecontract_whitepageslisting"];
            self->intl =[phoneResultData objectForKey:@"primary_features_roaming"];
            self->chcw =[phoneResultData objectForKey:@"primary_features_callholdcallwait"];
            self->fcp =[phoneResultData objectForKey:@"primary_features_clip"];
            self->fcr =[phoneResultData objectForKey:@"primary_features_clir"];
            self->tua =[phoneResultData objectForKey:@"top_up_amount"];
            self->tuf =[phoneResultData objectForKey:@"top_up_frequency"];
            self->tud =[phoneResultData objectForKey:@"top_up_day"];
            self->tub =[[phoneResultData objectForKey:@"top_up_balance"] intValue];
            self->tup =[phoneResultData objectForKey:@"top_up_password"];
            self->smstup =[phoneResultData objectForKey:@"sms_top_up"];
            self->minbal =[phoneResultData objectForKey:@"min_balance"];
            self->label =[phoneResultData objectForKey:@"label"];
            self->fnrt =[[phoneResultData objectForKey:@"speech_telephony_forwardnoreplytimer"] intValue];
            self->uncondf=[[phoneResultData objectForKey:@"speech_telephony_forwarduncond"] intValue];
            self->fbusy =[[phoneResultData objectForKey:@"speech_telephony_forwardbusy"] intValue];
            self->fnoreply =[phoneResultData objectForKey:@"speech_telephony_forwardnoreply"];
            self->funreach=[[phoneResultData objectForKey:@"speech_telephony_forwardunreach"] intValue];

            int fkPlanId = [[phoneResultData objectForKey:@"fkplanid"] intValue];
            
            NSString *strNoReply = [NSString stringWithFormat:@"%@",self->fnoreply];
            
            if (![strNoReply isEqual: @"0"]) {
                strNoReply = [strNoReply substringFromIndex:3];
            } else {
                strNoReply = @"11000321";
            }
            self->callDivertTxtField.placeholder = strNoReply;
            
            if (self->tub == 1) {
                [self.switchAutoTopUp setOn:YES];
            } else {
                [self.switchAutoTopUp setOn:NO];
            }
            
            if (fkPlanId > 1){
                self->is4G = YES;
                self->activatedBtn.enabled = NO;
            } else {
                self->is4G = NO;
                self->activatedBtn.enabled = YES;
                [self->activatedBtn setTitle:@"Activate 4G?" forState:UIControlStateNormal];
            }
            
            [self configUIElements: fkPlanId];

            if (self->speech_telephony_baroutall==0) {
                [self.switchBar setOn:NO];
            } else {
                [self.switchBar setOn:YES];
            }
            
            if (self->billingType == 1) {
                self.switchAutoTopUp.hidden = YES;
                self.lblAutoTopup.hidden = YES;
                self.autoTopUpListView.hidden = YES;
            } else {
                self.switchAutoTopUp.hidden = NO;
                self.lblAutoTopup.hidden = NO;
                self.autoTopUpListView.hidden = NO;
                if (self->autoTopup == 0)
                    [self.switchAutoTopUp setOn:NO];
                else
                    [self.switchAutoTopUp setOn:YES];
            }
            
            if (self->callWaiting == 1) {
                [self.switchCallWaiting setOn:YES];
            }
            
            
            if ([self->internationalRoaming  isEqual: @"Intl"]) {
                [self.switchIntRoaming setOn:YES];
            }

            NSLog(@"%i",self->smsLimit);
//            [self.btnSMSLimit setTitle:[NSString stringWithFormat:@"%i",self->smsLimit] forState:UIControlStateNormal];
            
            if (self->callerID == 1) {
                [self.switchCallerID setOn:YES];
            }
            
            if (self->voiceMailValue == 0) {
                [self.switchVoiceMail setOn:NO];
            } else {
                [self.switchVoiceMail setOn:YES];
            }
            
            if (self->callDiverts == 0) {
                [self.switchCallDiverts setOn:NO];
            } else {
                [self.switchCallDiverts setOn:YES];
            }
        });
    } else{
        NSLog(@"Error: %@",error);
    }
}

//MARK: - UI Actions
- (void) configUIElements: (int) fkPlanId {
    [self showOnlyRoaming: (fkPlanId == 5)];
    if ([planType  isEqual: @"4G"] || [planType  isEqual: @"5G"] || [self->lblNickName.text containsString:@"4ghome200"] ||  [self->lblNickName.text containsString:@"4ghome500"] ||  [self->lblNickName.text containsString:@"4GHOME20"] || [self->lblNickName.text containsString:@"5ghome100"] || [self->lblNickName.text containsString:@"5ghome100"] )  {
        self.internationalRoamingView.hidden = YES;
        self.callWaitingView.hidden = YES;
        self.callerIdView.hidden = YES;
        self.voicemailView.hidden = YES;
        self.callDivertsView.hidden = YES;
        self.autoTopUpListView.hidden = YES;
        self.getNewSimView.hidden = NO;
        self.reportLostSimListView.hidden = NO;
//        self.activateView.hidden = YES;
    }
    [self.view layoutIfNeeded];
}

- (void) showOnlyRoaming:(BOOL)onlyRoaming {
    self.internationalRoamingView.hidden = NO;
    self.callWaitingView.hidden = onlyRoaming;
    self.callerIdView.hidden = onlyRoaming;
    self.voicemailView.hidden = onlyRoaming;
    self.callDivertsView.hidden = onlyRoaming;
    self.autoTopUpListView.hidden = onlyRoaming;
//    self.premiumSmsView.hidden = onlyRoaming;
    self.getNewSimView.hidden = NO;
    self.reportLostSimListView.hidden = NO;
//    self.activateView.hidden = onlyRoaming;
    //    self.getNewSimTopConstraint.constant = onlyRoaming ? 0.0f : 264.0f;
}

-(IBAction)switchAutoTopUpAction:(id)sender{
    
    if([sender isOn]){
        [autoTopUpView setHidden:NO];
    } else {
        alertAutoTopUp = [[UIAlertView alloc]initWithTitle:@"Auto Top-Up" message:@"Are you sure you want to deactivate Auto Top-Up?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertAutoTopUp.tag = AUTO_TOPUP;
        [alertAutoTopUp show];
    }
}

-(IBAction)autoTopUpAmountAction:(id)sender{
    
    [autoTopUpPickerView setHidden:NO];
    
}

-(IBAction)autoTopUpCancelBtnAction:(id)sender{
    [autoTopUpView setHidden:YES];
    [autoTopUpPickerView setHidden:YES];
    NSLog(@"cancel auto top up");
    if ([self.switchAutoTopUp isOn]) {
        [self.switchAutoTopUp setOn:NO];
    } else {
        [self.switchAutoTopUp setOn:YES];
    }
}

// closes autoTopUpPickerView when tableview scrolles
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [smsPickerView setHidden:YES];
}

-(IBAction)autotopUpConfirmBtnAction:(id)sender{
    [autoTopUpView setHidden:YES];
    [autoTopUpPickerView setHidden:YES];

    tub = 1;
    tua = autoTopUpAmountBtn.titleLabel.text;

    callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/auto_topup?phoneid=%@&tub=%d&tua=%@&wpl=%@&chcw=%@&intl=%@&fcp=%@&fcr=%@&tuf=%@&tud=%@&tup=%@&smstup=%@&minbal=%@&label=%@&sess_var=%@",phoneID,tub,tua,wpl,chcw,intl,fcp,fcr,tuf,tud,tup,smstup,minbal,lblNickName.text,sessionID];
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
}

-(IBAction)switchCallWaitingAction:(id)sender{
    if([sender isOn]){
        NSLog(@"call waiting is ON");
        
        alertCallWaiting = [[UIAlertView alloc]initWithTitle:@"Call Waiting" message:@"Are you sure you want to activate Call Waiting?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertCallWaiting.tag = CALL_WAITING;
        [alertCallWaiting show];
        
    } else{
        
        alertCallWaiting = [[UIAlertView alloc]initWithTitle:@"Call Waiting" message:@"Are you sure you want to deactivate Call Waiting?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertCallWaiting.tag = CALL_WAITING;
        [alertCallWaiting show];
        
        NSLog(@"call waiting is OFF");
        
    }
    
}

-(IBAction)switchIntRoamingAction:(id)sender{
    if([sender isOn]){
        alertIntRoaming = [[UIAlertView alloc]initWithTitle:@"International Roaming" message:@"Are you sure you want to activate International Roaming?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertIntRoaming.tag = INT_ROAMING;
        [alertIntRoaming show];
        
    } else{
        alertIntRoaming = [[UIAlertView alloc]initWithTitle:@"International Roaming" message:@"Are you sure you want to deactivate International Roaming?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertIntRoaming.tag = INT_ROAMING;
        [alertIntRoaming show];
    }
}

-(IBAction)btnSMSLimitAction:(id)sender{
    NSLog(@"choose");
    [smsPickerView setHidden:NO];
    NSInteger selectedRow = [smsLimitArray indexOfObject:[NSString stringWithFormat:@"%i",smsLimit]];
    [smsPickerView selectRow:selectedRow inComponent:0 animated:YES];
}


-(IBAction)switchCallerIDaction:(id)sender{
    if([sender isOn]){
        alertCalerID = [[UIAlertView alloc]initWithTitle:@"Caller ID" message:@"Are you sure you want to activate Caller ID?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertCalerID.tag = CALLER_ID;
        [alertCalerID show];
        
    } else{
        alertCalerID = [[UIAlertView alloc]initWithTitle:@"Caller Id" message:@"Are you sure you want to deactivate Caller ID?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertCalerID.tag = CALLER_ID;
        [alertCalerID show];
        
    }
}

-(IBAction)switchVoiceMailaction:(id)sender{
    if([sender isOn]){
        alertVoiceMail = [[UIAlertView alloc]initWithTitle:@"Voicemail" message:@"Are you sure you want to activate Voicemail?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertVoiceMail.tag = VOICE_MAIL;
        [alertVoiceMail show];
    } else {
        alertVoiceMail = [[UIAlertView alloc]initWithTitle:@"Voicemail" message:@"Are you sure you want to deactivate Voicemail?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertVoiceMail.tag = VOICE_MAIL;
        [alertVoiceMail show];
    }
}

-(IBAction)switchCallDivertsaction:(id)sender{
    if([sender isOn]){
        [callDivertView setHidden:NO];
    } else {
        alertCallDiverts = [[UIAlertView alloc]initWithTitle:@"Call Divert" message:@"Are you sure you want to deactivate Call Divert?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        alertCallDiverts.tag = CALL_DIVERTS;
        [alertCallDiverts show];
        
    }
}

-(IBAction)cancelCallDivert:(id)sender{
    NSLog(@"cancel divert");
    if ([self.switchCallDiverts isOn]) {
        [self.switchCallDiverts setOn:NO];
        
    }else{
        [self.switchCallDiverts setOn:YES];
    }
    
    [callDivertView setHidden:YES];
    [callDivertTxtField resignFirstResponder];
}

-(IBAction)confirmCallDivert:(id)sender{
    
    NSLog(@"confirm divert");
    [callDivertView setHidden:YES];
    [callDivertTxtField resignFirstResponder];
    
    if ([self.switchCallDiverts isOn]) {
        if ([callDivertTxtField.text  isEqual: @""]) {
            [self alertStatus:@"Please input a valid number":@"Error"];
            [self.switchCallDiverts setOn:NO];
        } else {
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/call_divert/%@/614%@/%d/%@/%d/%d/%@",phoneID,callDivertTxtField.text,fbusy,fnoreply,fnrt,funreach,sessionID];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    } else {
        callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/call_divert/%@/614%@/%d/%@/%d/%d/%@",phoneID,@"0",fbusy,fnoreply,fnrt,funreach,sessionID];
        
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
    }
}

-(IBAction)cancelSimAction:(id)sender{
    alertCancelSim = [[UIAlertView alloc]initWithTitle:@"Cancel Sim" message:@"Are you sure you want to cancel sim?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alertCancelSim.tag = CANCEL_SIM;
    [alertCancelSim show];
}

-(IBAction)getNewSimActions:(id)sender{
    
    alertgetNewSim = [[UIAlertView alloc]initWithTitle:@"Order New SIM" message:@"Has your SIM been lost, stolen or damaged? No worries - we can get you sorted so that you're back up & running in no time! Please allow 3-5 business days for your SIM to be delivered (no charges will be made to your account)." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alertgetNewSim.tag = GET_NEW_SIM;
    [alertgetNewSim show];
}

-(IBAction)reportSim:(id)sender{
    [reportView setHidden:NO];
    insideReportView.alpha = 1;
    NSLog(@"report sim");
}

-(IBAction)cancelReportSim:(id)sender{
    NSLog(@"cancel report");
    [self.switchBar setOn:NO];
    [reportView setHidden:YES];
}

-(IBAction)confirmReportSim:(id)sender{
    NSLog(@"confirm report");
    if ([self.switchBar isOn])
        callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/bar_sim/%@/%@",sessionID,phoneID];
    else{
        callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/unbar_sim/%@/%@",sessionID,phoneID];
    }
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
    [reportView setHidden:YES];
}


-(IBAction)switchReportSimAction:(id)sender{
    if([sender isOn]){
        NSLog(@"switch report is on");
    } else {
        NSLog(@"switch report is off");
    }
}

- (IBAction)primaryAccBtn:(id)sender{

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Set Primary"
                                 message:@"Are you sure you want to change your primary service?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Confirm"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        [self callURLMakePrimary];
    }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        //Handle no, thanks button
    }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void) callURLMakePrimary {
    callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/make_primary_phone/%@/%@/%@",clientID,sessionID,phoneID];
    NSLog(@"strURL: %@",callStrURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:callStrURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseString: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
        NSLog(@"resultData: %@",resultData);
        
        NSString * successMessage = @"";
        
        if (![resultData  isEqual: @"Success"]) {
            NSString * responseText = [resultData objectForKey:@"responseText"];
            NSString * Message =[resultData objectForKey:@"Message"];
            NSString *resultText = [resultData objectForKey:@"RESULTTEXT"];
            resultText = [resultText stringByReplacingOccurrencesOfString:@"func_setBar.cfm Failed -" withString:@""];
            NSString *details = [resultData objectForKey:@"detail"];
            
            if (responseText) {
                successMessage = [NSString stringWithFormat:@"%@ - %@",responseText,Message];
                [self alertStatus:successMessage:@""];
            } else if (resultText) {
                [self alertStatus:resultText:@""];
            } else if (details) {
                [self alertStatus:details:@""];
            } else {
                self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
                [self.view addSubview:self->HUB];
                [self->HUB showWhileExecuting:@selector(gotoMainPage) onTarget:self withObject:nil animated:YES];
            }
        } else {
            self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:self->HUB];
            [self->HUB showWhileExecuting:@selector(gotoMainPage) onTarget:self withObject:nil animated:YES];
        }
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:@"0" forKey:@"phonesArrayIndex"];
    }
    else{
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        [self alertStatus:strError:@"Error"];
    }
}

- (void) gotoMainPage {
    [self getPhones];
    if ([phonesArray count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
            mvc.urlData = self->urlData;
            mvc.phonesArray = self->phonesArray;
            
            SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
            smvc.urlData = self->urlData;
            smvc.phonesArray = self->phonesArray;
            smvc.fromFB = NO;
            smvc.withFamily = self->withFamily;
            
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
}


-(IBAction)activatedBtnAction:(id)sender{
    callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/activate_4g/%@/%@",clientID,phoneID];
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
    is4G = YES;
    activatedBtn.enabled = NO;
    [activatedBtn setTitle:@"Activated" forState:UIControlStateNormal];
    [reportView setHidden:YES];
}

#define ALERT VIEW DELEGATE

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == CALL_WAITING) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel call waiting");
            
            if ([self.switchCallWaiting isOn]) {
                [self.switchCallWaiting setOn:NO];
                
            }else{
                [self.switchCallWaiting setOn:YES];
            }
        }else{
            //confirm clicked
            NSLog(@"confirm call waiting");
            int status;
            if (callWaiting == 0 ) {
                status = 1;
                callWaiting = 1;
            }
            else{
                status = 0;
                callWaiting = 0;
            }
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/call_waiting?phoneid=%@&status=%d&wpl=%@&intl=%@&fcp=%@&fcr=%@&tua=%@&tuf=%@&tud=%@&tub=%d&tup=%@&smstup=%@&minbal=%@&label=%@&sess_var=%@",phoneID,status,wpl,intl,fcp,fcr,tua,tuf,tud,tub,tup,smstup,minbal,lblNickName.text,sessionID];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    } else if (alertView.tag == SET_PRIMARY_CONFIRM) {

    } else if (alertView.tag == AUTO_TOPUP) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel auto top up");
            if ([self.switchAutoTopUp isOn]) {
                [self.switchAutoTopUp setOn:NO];
            } else {
                [self.switchAutoTopUp setOn:YES];
            }
        } else {
            //confirm clicked
            NSLog(@"confirm auto top up");
            tub = 0;
            tua = @"0";

            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/auto_topup?phoneid=%@&tub=%d&tua=%@&wpl=%@&chcw=%@&intl=%@&fcp=%@&fcr=%@&tuf=%@&tud=%@&tup=%@&smstup=%@&minbal=%@&label=%@&sess_var=%@",phoneID,tub,tua,wpl,chcw,intl,fcp,fcr,tuf,tud,tup,smstup,minbal,lblNickName.text,sessionID];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    } else if (alertView.tag == INT_ROAMING) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel roaming");
            if ([self.switchIntRoaming isOn]) {
                [self.switchIntRoaming setOn:NO];
            } else {
                [self.switchIntRoaming setOn:YES];
            }
        } else {
            //confirm clicked
            NSLog(@"confirm roaming");
            NSString * status = internationalRoaming;
            if ([internationalRoaming  isEqual: @"Intl"]) {
                status = @"Home";
                internationalRoaming = @"Home";
            } else {
                status = @"Intl";
                internationalRoaming = @"Intl";
            }

            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/international_roaming?phoneid=%@&status=%@&wpl=%@&chcw=%@&fcp=%@&fcr=%@&tua=%@&tuf=%@&tud=%@&tub=%d&tup=%@&smstup=%@&minbal=%@&label=%@&sess_var=%@",phoneID,status,wpl,chcw,fcp,fcr,tua,tuf,tud,tub,tup,smstup,minbal,lblNickName.text,sessionID];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
            
        }
    }
    else if (alertView.tag == CALLER_ID){
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel caller ID");
            
            if ([self.switchCallerID isOn]) {
                
                [self.switchCallerID setOn:NO];
                
            } else {
                
                [self.switchCallerID setOn:YES];
                
            }
            
        } else {
            //confirm clicked
            NSLog(@"confirm caller ID");
            NSString * status = @"0";
            if (callerID == 1) {
                status = @"0";
                callerID = 0;
            } else {
                status = @"1";
                callerID = 1;
            }

            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/features_clip?phoneid=%@&status=%@&wpl=%@&chcw=%@&intl=%@&fcr=%@&tua=%@&tuf=%@&tud=%@&tub=%d&tup=%@&smstup=%@&minbal=%@&label=%@&sess_var=%@",phoneID,status,wpl,chcw,intl,fcr,tua,tuf,tud,tub,tup,smstup,minbal,lblNickName.text,sessionID];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    } else if (alertView.tag == VOICE_MAIL) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel voice mail");
            if ([self.switchVoiceMail isOn]) {
                [self.switchVoiceMail setOn:NO];
            }
            else{
                [self.switchVoiceMail setOn:YES];
            }
        } else {
            //confirm clicked
            NSLog(@"confirm voice mail");
            if ([self.switchVoiceMail isOn]) {
                callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/voicemail/%@/61411000321/%d/%d/%@",phoneID,fnrt,uncondf,sessionID];
            } else {
                callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/voicemail/%@/0/%d/%d/%@",phoneID,fnrt,uncondf,sessionID];
            }
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    }
    else if (alertView.tag == CALL_DIVERTS){
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel call divert");
            if ([self.switchCallDiverts isOn]) {
                [self.switchCallDiverts setOn:NO];
                
            }else{
                [self.switchCallDiverts setOn:YES];
            }
        }
        else{
            //confirm clicked
            NSLog(@"confirm call divert");
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/call_divert/%@/0/%d/%@/%d/%d/%@",phoneID,fbusy,fnoreply,fnrt,funreach,sessionID];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    }
    else if (alertView.tag == SMS_LIMIT){
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel SMS limit");
//            [self.btnSMSLimit setTitle:[NSString stringWithFormat:@"%i",smsLimit] forState:UIControlStateNormal];
        }
        else{
            //confirm clicked
            NSLog(@"%@",smsLimitStr);
            NSLog(@"confirm SMS limit");
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/sms_limit/%@/%@/%@",phoneID,smsLimitStr,sessionID];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    }
    else if (alertView.tag == CANCEL_SIM) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel");
        }
        else{
            //confirm clicked
            NSLog(@"confirm cancel sim");
            //https://yomojo.com.au/api/cancel_sim/$clientid/$firstname/$lastname/$emailaddress/$phoneno
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/cancel_sim/%@/%@/%@/%@/%@",clientID,fname,lname,usersEmail,usersPhone];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURL) onTarget:self withObject:nil animated:YES];
        }
    }
    else if (alertView.tag == GET_NEW_SIM) {
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"cancel get sim");
        }
        else{
            //confirm clicked
            NSLog(@"confirm get sim");

            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/order_new_sim2/%@/%@/%@", clientID, phoneID, planId];
            
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURLGetNewSIM) onTarget:self withObject:nil animated:YES];
        }
    }
    else if (alertView.tag == SET_PRIMARY){
        if (buttonIndex == [alertView cancelButtonIndex]) {
            //cancel clicked ...do your action
            NSLog(@"cancel primary");
        }
        else{
            callStrURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/make_primary_phone/%@/%@/%@",clientID,sessionID,phoneID];
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(callURLMakePrimary) onTarget:self withObject:nil animated:YES];
            [reportView setHidden:YES];
        }
    }
}


-(void) callURLGetNewSIM{
    NSLog(@"strURL: %@",callStrURL);
    NSString* encodedUrl = [callStrURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url:%@",encodedUrl);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        if (!error) {
            NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseString: %@",responseData);
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
            NSLog(@"resultData: %@",resultData);
            
            //        NSString * successMessage = @"";
            
            if(![resultData[@"Acknowledgement"] isKindOfClass:[NSNull class]] && resultData[@"Acknowledgement"]) {
                if (![resultData[@"Acknowledgement"][@"Text"] isKindOfClass:[NSNull class]] && resultData[@"Acknowledgement"][@"Text"]) {
                    NSString *message = resultData[@"Acknowledgement"][@"Text"];
                    message = [message stringByReplacingOccurrencesOfString:@"<br/>"
                                                                 withString:@"\n"];
                    [self alertStatus:message:@"Success"];
                }
            }
            //
            //
            //        if ([resultData  isEqual: @""]) {
            //            [self alertStatus:@"Invalid number":@"Error"];
            //            [self.switchCallDiverts setOn:NO];
            //        } else if ([resultData  isEqual: @"Phone is barred"]) {
            //            [self alertStatus:@"Service updated":@"Phone is barred"];
            //        } else if ([resultData  isEqual: @"Success"]){
            //            [self alertStatus:@"Your request has been received. You will be contacted by our customer service team within the next 24-48 hours.":@"Success"];
            //        } else if ([resultData isKindOfClass:[NSString class]] == YES) {
            //            [self alertStatus:[NSString stringWithFormat:@"%@",resultData]:@"Error"];
            //            [self.switchCallDiverts setOn:NO];
            //        } else{
            //            NSString * responseText = [resultData objectForKey:@"responseText"];
            //            NSString * Message =[resultData objectForKey:@"Message"];
            //            NSString *resultText = [resultData objectForKey:@"RESULTTEXT"];
            //            resultText = [resultText stringByReplacingOccurrencesOfString:@"func_setBar.cfm Failed -" withString:@""];
            //            NSString *details = [resultData objectForKey:@"detail"];
            //
            //            if (responseText) {
            //                successMessage = [NSString stringWithFormat:@"%@ - %@",responseText,Message];
            //                [self alertStatus:successMessage:@""];
            //            } else if (resultText) {
            //                [self alertStatus:resultText:@""];
            //            } else if (details) {
            //                [self alertStatus:details:@""];
            //            } else {
            //                [self alertStatus:@"Your request has been received. You will be contacted by our customer service team within the next 24-48 hours.":@"Success"];
            //            }
            //        }
        } else{
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            [self alertStatus:strError:@"Error"];
        }
}

- (void) callURL {
    NSLog(@"strURL: %@",callStrURL);
    NSString* encodedUrl = [callStrURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url:%@",encodedUrl);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        if (!error) {
            NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseString: %@",responseData);
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
            NSLog(@"resultData: %@",resultData);
            
            NSString * successMessage = @"";
            
            if ([resultData  isEqual: @""]) {
                [self alertStatus:@"Invalid number":@"Error"];
                [self.switchCallDiverts setOn:NO];
            } else if ([resultData  isEqual: @"Phone is barred"]) {
                [self alertStatus:@"Service updated":@"Phone is barred"];
            } else if ([resultData  isEqual: @"Success"]) {
                [self alertStatus:@"Service updated":@"Success"];
            } else if ([resultData isKindOfClass:[NSString class]] == YES) {
                [self alertStatus:[NSString stringWithFormat:@"%@",resultData]:@"Error"];
                [self.switchCallDiverts setOn:NO];
            } else {
                NSString * responseText = [resultData objectForKey:@"responseText"];
                NSString * Message =[resultData objectForKey:@"Message"];
                NSString *resultText = [resultData objectForKey:@"RESULTTEXT"];
                resultText = [resultText stringByReplacingOccurrencesOfString:@"func_setBar.cfm Failed -" withString:@""];
                NSString *details = [resultData objectForKey:@"detail"];
                
                if (responseText) {
                    successMessage = [NSString stringWithFormat:@"%@ - %@",responseText,Message];
                    [self alertStatus:successMessage:@""];
                } else if (resultText) {
                    [self alertStatus:resultText:@""];
                } else if (details) {
                    [self alertStatus:details:@""];
                } else {
                    [self alertStatus:@"Service updated":@"Success"];
                }
            }
        } else {
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            [self alertStatus:strError:@"Error"];
        }
}

#define PICKER VIEW DELEGATE

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    int rows = 0;
    if (pickerView.tag == SMS_LIMIT) {
        rows = 4;
    }
    if (pickerView.tag == AUTO_TOPUP) {
        rows = 6;
    }
    return rows;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *str = @"";
    
    if (pickerView.tag == SMS_LIMIT) {
        str =  [smsLimitArray objectAtIndex:row];
    }
    if (pickerView.tag == AUTO_TOPUP) {
        str =  [autoTopUpArray objectAtIndex:row];
    }
    return  str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    if (pickerView.tag == SMS_LIMIT) {
        [smsPickerView setHidden:YES];
        
//        [self.btnSMSLimit setTitle:[smsLimitArray objectAtIndex:row] forState:UIControlStateNormal];
//        smsLimitStr = [smsLimitArray objectAtIndex:row];
//        alertSMSLimit = [[UIAlertView alloc] initWithTitle:@"Premium SMS limit" message:@"Are you sure you want to change Premium SMS limit?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
//        alertSMSLimit.tag = SMS_LIMIT;
//        [alertSMSLimit show];
    } else if (pickerView.tag == AUTO_TOPUP) {
        [autoTopUpPickerView setHidden:YES];
        [autoTopUpAmountBtn setTitle:[autoTopUpArray objectAtIndex:row] forState:UIControlStateNormal];
    }
    
    //Write the required logic here that should happen after you select a row in Picker View.
}

-(IBAction)backBtnAction:(id)sender{
    [self showRightView:sender];
}

- (void)showRightView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

@end

