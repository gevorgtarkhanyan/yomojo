//
//  FinalizedChangePlanViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 19/04/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "FinalizedChangePlanViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import <PKRevealController/PKRevealController.h>
#import "Constants.h"
#import "UIColor+Yomojo.h"

@interface FinalizedChangePlanViewController ()

@end

@implementation FinalizedChangePlanViewController
@synthesize viewPlanHolder, lbl4G3G, img4G3G, lblData, lblPrice, lblDescription, sim_type, jsonData;
@synthesize  intlPlanArray, productplans, productPlan, productPlanArray, imgBGIntl, imgProgressIntl, amountIntl, personIntl, selectedIntl, viewIntlPackHolder, lblTotalPrice, amountUnli, planID, pending_fkbundleid, lblIntlPackPrice, urlData, phonesArray, billingType, amountMBB, fromFB;

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        [self moveToMain];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictData = [userLogin objectForKey:@"getPhoneDetails"];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    
    NSString *strFromFB = [userLogin objectForKey:@"fromFB"];
    if ([strFromFB  isEqual: @"YES"]) {
        fromFB = YES;
    }
    else{
        fromFB = NO;
    }
    
    billingType = [[resultData objectForKey:@"billing_type"]intValue];
    
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    planID = [phoneDetails objectForKey:@"planid"];
    
    if ([planID  isEqual: @"5"]){
        NSString * titleLabel = [jsonData objectForKey:@"planname"];
        NSString * sim_type = @"4G";
        NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @" "];
        
        img4G3G.backgroundColor = [UIColor YomoPinkColor];
        lblData.textColor = [UIColor YomoPinkColor];
        lblPrice.textColor = [UIColor YomoPinkColor];
        viewPlanHolder.layer.borderColor = [UIColor YomoPinkColor].CGColor;
        
        NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
        strDescription = [strDescription lowercaseString];
        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
        lblDescription.text = strDescription;
        
        NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
        
        //lbl4G3G.text = [NSString stringWithFormat:@"%@",sim_type];
        lbl4G3G.text = @"4G";
        lbl4G3G.textColor = [UIColor whiteColor];
        lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
        lblDescription.text = titleLabel;
        
        CGFloat borderWidth = 2.0f;
        viewPlanHolder.frame = CGRectInset(viewPlanHolder.frame, -borderWidth, -borderWidth);
        viewPlanHolder.layer.borderWidth = borderWidth;
        viewPlanHolder.layer.cornerRadius = 15;
        viewPlanHolder.layer.masksToBounds = true;
        
        lblPrice.text = [NSString stringWithFormat:@"$%@", [jsonData objectForKey:@"planamount"]];
        lblTotalPrice.text = [NSString stringWithFormat:@"$%@*", [jsonData objectForKey:@"planamount"]];
        
        viewIntlPackHolder.hidden = YES;
    }
    else{
        NSString * sim_type = [jsonData objectForKey:@"sim_type"];
        if (sim_type) {
            if ([sim_type isEqual: @"3G"]) {
                img4G3G.backgroundColor = [UIColor YomoOrangeColor];
                lblData.textColor = [UIColor YomoOrangeColor];
                lblPrice.textColor = [UIColor YomoOrangeColor];
                viewPlanHolder.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
                lbl4G3G.text = @"3G";
            }
            else{
                img4G3G.backgroundColor = [UIColor YomoPinkColor];
                lblData.textColor = [UIColor YomoPinkColor];
                lblPrice.textColor = [UIColor YomoPinkColor];
                viewPlanHolder.layer.borderColor = [UIColor YomoPinkColor].CGColor;
                lbl4G3G.text = @"4G";
            }
        }
        NSString * titleLabel = [jsonData objectForKey:@"description"];
//        if ([titleLabel  isEqual: @"Kids Plan"]) {
//            lblDescription.text = titleLabel;
//            lblData.text = @"1GB";
//            lblDescription.text = @"200 mins talk & unlimited text";
//        }
//        else{
            NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
            NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
//            strDescription = [strDescription lowercaseString];
//            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
            lblDescription.text = strDescription;
            NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
            lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
        lblDescription.text = strDescription;//[strDescription stringByReplacingOccurrencesOfString:@"sms" withString:@"text"];
//        }
        lbl4G3G.textColor = [UIColor whiteColor];
        CGFloat borderWidth = 2.0f;
        viewPlanHolder.frame = CGRectInset(viewPlanHolder.frame, -borderWidth, -borderWidth);
        viewPlanHolder.layer.borderWidth = borderWidth;
        viewPlanHolder.layer.cornerRadius = 15;
        viewPlanHolder.layer.masksToBounds = true;
        
        lblPrice.text = [NSString stringWithFormat:@"$%@*", [jsonData objectForKey:@"amount"]];
        amountUnli = [jsonData objectForKey:@"amount"];
        if ([sim_type isEqual: @"3G"]) {
            img4G3G.backgroundColor = [UIColor YomoOrangeColor];
            lblData.textColor = [UIColor YomoOrangeColor];
            lblPrice.textColor = [UIColor YomoOrangeColor];
            viewPlanHolder.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
        }
        else{
            img4G3G.backgroundColor = [UIColor YomoPinkColor];
            lblData.textColor = [UIColor YomoPinkColor];
            lblPrice.textColor = [UIColor YomoPinkColor];
            viewPlanHolder.layer.borderColor = [UIColor YomoPinkColor].CGColor;
        }
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(processAllPlan) onTarget:self withObject:nil animated:YES];
    }
}

- (void) processAllPlan{
    [self getProductPlans]; //get list of personliazed plan including Intl
    [self processAllData];  // get current plan of user
    [self getCurrentPlanPriceIntl]; // get this month price international
    [self sliderIntlPack];
}

-(void) getProductPlans{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getproductplans2",PORTAL_URL];
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
        productplans = [[NSMutableDictionary alloc] init];
        productplans = [dictData objectForKey:@"productplans"];
        
        NSMutableDictionary *resultRP9 = [productplans objectForKey:@"RP9"];
        NSArray *voicePlanID = [resultRP9 allKeys];
        NSMutableArray* voicePlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [voicePlanID count]; i++) {
            NSMutableDictionary * rp9IDValue = [[NSMutableDictionary alloc] init];
            rp9IDValue = [resultRP9 objectForKey:[voicePlanID objectAtIndex:i]];
            [voicePlanArrayMutable addObject:rp9IDValue];
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"slider"  ascending:YES];
        
        intlPlanArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *resultRP11 = [productplans objectForKey:@"RP11"];
        NSArray *intlPlanID = [resultRP11 allKeys];
        NSMutableArray* intlPlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [intlPlanID count]; i++) {
            NSMutableDictionary * rp11IDValue = [[NSMutableDictionary alloc] init];
            rp11IDValue = [resultRP11 objectForKey:[intlPlanID objectAtIndex:i]];
            [intlPlanArrayMutable addObject:rp11IDValue];
        }
        intlPlanArray = [intlPlanArrayMutable sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    }
}

- (void) processAllData{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictDataPhoneDetails = [userLogin objectForKey:@"getPhoneDetails"];
    [self processDictData:dictDataPhoneDetails];
}

-(void) processDictData: (NSMutableDictionary*) dictData{
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:[resultData objectForKey:@"billing_type"] forKey:@"billingType"];
    [userLogin setObject:dictData forKey:@"getPhoneDetails"];
    productPlan = [[NSMutableArray alloc]init];
    productPlan = [resultData objectForKey:@"productplan"];
    productPlanArray = [[NSMutableArray alloc]init];
    for (int i=0; i < [productPlan count]; i++) {
        NSMutableDictionary *productplanDict = [productPlan objectAtIndex:i];
        NSString *name_text = [productplanDict objectForKey:@"name_text"];
        if ([name_text  isEqual: @"Yomojo Voice"]) {
            NSLog(@"name_text: %@",name_text);
        }
        else{
            [self addToArray:productplanDict];
        }
    }
}

- (void) addToArray:(NSMutableDictionary*)productDict{
    //int num = 0;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    NSString *productExpiry = [productDict objectForKey:@"expiry"];
    NSDate *currDate = [NSDate date];
    NSString *strCurrDate = [dateFormatter stringFromDate:currDate];
    [productPlanArray addObject:productDict];
    NSLog(@"productPlanArray: %@",productPlanArray);
}


-(NSString *) getCurrentPlanPriceIntl{
    NSString * strTotalPrice = @"";
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            NSString *name_text =[jsonData objectForKey:@"name_text"];
            NSString *pending_text =[jsonData objectForKey:@"pending"];
            NSString *expiry_real = [jsonData objectForKey:@"expiry_real"];
            NSString *autorenewal = [jsonData objectForKey:@"autorenewal"];
            int pendingExist = 0;
            if ([name_text isEqualToString:@"Intl Voice"]){
                for (int z=0; [intlPlanArray count] > z; z++) {
                    NSString * intlID = [[intlPlanArray objectAtIndex:z] objectForKey:@"id"];
                    if (([intlID isEqualToString:planId]) && (![pending_text  isEqual: @""])){
                        if ([expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                            if (![autorenewal  isEqual: @"noauto"]) {
                                NSString * amount = [[intlPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                                NSLog(@"Name: %@",name_text);
                                NSLog(@"$%.02f",[amount floatValue]);
                                int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
                                float oneSlotSize = (CGRectGetWidth(imgBGIntl.frame))/(itemCount);
                                imgProgressIntl.frame = CGRectMake(imgProgressIntl.frame.origin.x, imgProgressIntl.frame.origin.y, oneSlotSize*(z+1), 15);
                                NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:z];
                                amountIntl = [dictValue objectForKey:@"planamount"];
                                personIntl = [[dictValue objectForKey:@"id"] intValue];
                                selectedIntl = z+1;
                                pendingExist = 1;
                            }
                        }
                    }
                    else if (([intlID isEqualToString:planId]) && (pendingExist < 1)) {
                        if (![autorenewal  isEqual: @"noauto"]) {
                            NSString * amount = [[intlPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGIntl.frame))/(itemCount);
                            imgProgressIntl.frame = CGRectMake(imgProgressIntl.frame.origin.x, imgProgressIntl.frame.origin.y, oneSlotSize*(z+1), 15);
                            NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:z];
                            amountIntl = [dictValue objectForKey:@"planamount"];
                            personIntl = [[dictValue objectForKey:@"id"] intValue];
                            selectedIntl = z+1;
                        }
                    }
                }
            }
        }
    }
    //lblThisMonthPrice.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    dispatch_async(dispatch_get_main_queue(), ^{
        lblTotalPrice.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    });
    return strTotalPrice;
}

- (void) sliderIntlPack {
    dispatch_async(dispatch_get_main_queue(), ^{
        //set intl slider bar
        NSMutableArray *valueSelectionIntl = [[NSMutableArray alloc]init];
        for (int i=0; [self.intlPlanArray count] > i; i++) {
            if (i == 0) {
                [valueSelectionIntl addObject: @"0"];
            }
            NSString * titleLabel = [[self.intlPlanArray objectAtIndex:i] objectForKey:@"planname"];
            titleLabel = [titleLabel stringByReplacingOccurrencesOfString: @"International Voice " withString:@""];
            [valueSelectionIntl addObject: titleLabel];
        }
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        self.imgBGIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
        [self.imgBGIntl setBackgroundColor:[UIColor YomoLightGrayColor]];
        self.imgProgressIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
        [self.imgProgressIntl setBackgroundColor:[UIColor YomoDarkGrayColor]];
        SEFilterControl* filterIntl = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionIntl];
        [filterIntl addTarget:self action:@selector(actionSliderIntl:) forControlEvents:UIControlEventValueChanged];
        filterIntl.progressColor = [UIColor YomoDarkGrayColor];
        [filterIntl setSelectedIndex:self.selectedIntl animated:YES];
        [self.viewIntlPackHolder addSubview:self.imgBGIntl];
        [self.viewIntlPackHolder addSubview:self.imgProgressIntl];
        [self.viewIntlPackHolder addSubview:filterIntl];
    });
}

- (IBAction)actionSliderIntl:(SEFilterControl *) sender{
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    
    float oneSlotSize = (CGRectGetWidth(imgBGIntl.frame))/itemCount;
    imgProgressIntl.frame = CGRectMake(imgProgressIntl.frame.origin.x, imgProgressIntl.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
    
    if (sender.selectedIndex == 0){
        amountIntl = @"0";
        personIntl = 0;
    }
    else{
        NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountIntl = [dictValue objectForKey:@"planamount"];
        personIntl = [[dictValue objectForKey:@"id"] intValue];
    }
    selectedIntl = sender.selectedIndex;
    float totalPrice = 0.0;
//    if (pending_fkbundleid > 0) {
//        totalPrice  = [amountIntl floatValue] + [amountUnliPending floatValue];
//    }
//    else{
//        totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
//    }
    lblIntlPackPrice.text = [NSString stringWithFormat:@"$%.02f*", [amountIntl floatValue]];
    totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
    lblTotalPrice.text = [NSString stringWithFormat:@"$%.02f*", totalPrice];
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)btnSavePlan:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callURLChangPlan) onTarget:self withObject:nil animated:YES];
}

- (void) callURLChangPlan{
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    NSString *clientID = [responseDict objectForKey:@"CLIENTID"];
    NSString *sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    NSString *phoneID = [phoneDetails objectForKey:@"id"];
    planID = [phoneDetails objectForKey:@"planid"];
    NSString * strPortalURL = @"";
    NSString * planType = @"unlimited";
    float baseAmountUnli = 9.90;
    
    if ([planID  isEqual: @"5"]) {
        amountMBB =  [jsonData objectForKey:@"planamount"];
        planType = @"broadband";

        strPortalURL = [NSString stringWithFormat:@"%@/computeplan2?unlibundleid=-1&plantype=broadband&phoneid=%@&clientid=%@&unlidata=-1&unliintl=-1&unlitopup=0&broadbanddata=%@&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=0&session_var=%@", @"http://yomojo.com.au/api_dev", phoneID, clientID, amountMBB, sessionID];
        
//        strPortalURL = [NSString stringWithFormat:@"%@/computeplan2?unlibundleid=-1&plantype=broadband&phoneid=%@&clientid=%@&unlidata=-1&unliintl=-1&unlitopup=0&broadbanddata=%@&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=0&session_var=%@", PORTAL_URL, phoneID, clientID, amountMBB, sessionID];
        
    }
    else {
        int unliData = [[jsonData objectForKey:@"id"] intValue];
        int unliTopup = 0;
        
        if ([amountUnli isEqual: @"0"] || [amountUnli isEqual: @"(null)"])
            amountUnli = @"-1";
        
        if ([amountIntl isEqual: @"0"])
            amountIntl = @"0";
        
        float totalPriceUnli = [amountUnli floatValue] - baseAmountUnli;
        amountUnli = [NSString stringWithFormat:@"%.02f",totalPriceUnli];
        planType = @"unlimited";
        
        strPortalURL = [NSString stringWithFormat:@"%@/computeplan2?unlibundleid=%d&plantype=unlimited&phoneid=%@&clientid=%@&unlidata=%@&unliintl=%@&unlitopup=%d&broadbanddata=-1&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=0&session_var=%@", @"http://yomojo.com.au/api_dev", unliData, phoneID, clientID, amountUnli, amountIntl, unliTopup, sessionID];
        
//        strPortalURL = [NSString stringWithFormat:@"%@/computeplan2?unlibundleid=%d&plantype=unlimited&phoneid=%@&clientid=%@&unlidata=%@&unliintl=%@&unlitopup=%d&broadbanddata=-1&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=0&session_var=%@", PORTAL_URL, unliData, phoneID, clientID, amountUnli, amountIntl, unliTopup, sessionID];
        
    }
    
    NSLog(@"url: %@", strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:dataFromURL encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        
        int dataError = [[dictData objectForKey:@"error"] intValue];
        NSString * errorMsg = [dictData objectForKey:@"errormsg"];
        
        if (dataError != 0) {
            [self alertStatus:errorMsg : @"Error"];
        }
        else{
            [self alertStatus:@"Change Plan successful!" : @"Success"];
            //[self moveToMain];
        }
    }
}


-(void) moveToMain{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];

    MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    //mvc.urlData = [userLogin objectForKey:@"urlData"];
    mvc.urlData = urlData;
    mvc.phonesArray = phonesArray;
    mvc.withFamily = [userLogin objectForKey:@"withFamily"];
    mvc.fromFB = fromFB;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArray;
    smvc.fromFB = fromFB;
    smvc.withFamily = [userLogin objectForKey:@"withFamily"];
    
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

@end
