//
//  ChangePlanViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 28/03/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "ChangePlanViewController.h"
#import "MainViewController.h"
#import "SideMenuViewController.h"
#import "ChangePlanNewTableViewCell.h"
#import "FinalizedChangePlanViewController.h"
#import "Constants.h"
#import "UIColor+Yomojo.h"

@interface ChangePlanViewController ()

@property(weak, nonatomic) IBOutlet UITextView *bottomTextView;

@end

@implementation ChangePlanViewController

@synthesize arrayUnliBundles, billingType, phonesArray, planID, urlData, accountUnli, imgBGColor, viewBundlePlans, missingID, missingIDMBB, lblBundlePlanData, lblBundlePlansDescription, lbl4G3G, lblNextmonthAmount, imgBGIntl, imgProgressIntl, productplans, intlPlanArray, selectedIntl, personIntl, amountIntl, viewIntlPackHolder, tableBundles, lblIntlPackPrice, selectedUnli, selectedUnliStr, amountUnli, productPlan, productPlanArray, pending_fkbundleid, amountUnliPending, unliDataPending, lblThisMonthPrice, unliData, oldSimType, currentPlanUnliIndex, pendingProduct, pendingPlansService, isUnliPlan;
@synthesize mbbPlans, mbbPlanArray, selectedMBB, mbbBundle, amountMBB, pendingMBB, currentPlanFromMissing, jsonDataSubmit, cuurentID, fkbundleid, productPlanFromMainVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    selectedMBB = -1;
    currentPlanFromMissing = @"";
    [self addAttributesToBottomTextView];
}

- (void)viewDidAppear:(BOOL)animated {
    missingID = @"";
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictData = [userLogin objectForKey:@"getPhoneDetails"];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    
    billingType = [[resultData objectForKey:@"billing_type"]intValue];
    
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    planID = [phoneDetails objectForKey:@"planid"];
    
    //    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    //    [self.view addSubview:HUB];
    //    [HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
    
    [self checkPendingPlans:dictData];
    
    if ([planID  isEqual: @"5"]) {
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(processMBBPlans) onTarget:self withObject:nil animated:YES];
    }
    else {
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(processAllPlan) onTarget:self withObject:nil animated:YES];
    }
    //[tableBundles reloadData];
}


- (void) addAttributesToBottomTextView {
    
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithString:self.bottomTextView.text];
    NSRange range = [self.bottomTextView.text rangeOfString:@"chat"];
    [newAttributedString addAttribute:NSFontAttributeName value:self.bottomTextView.font range:NSMakeRange(0, self.bottomTextView.text.length - 1)];
    [newAttributedString enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        [newAttributedString addAttribute:NSLinkAttributeName value:[NSURL URLWithString: @"https://www.yomojo.com.au/chat"] range:range];
    }];
    self.bottomTextView.text = nil;
    self.bottomTextView.attributedText = newAttributedString;
    self.bottomTextView.textAlignment = NSTextAlignmentCenter;
}

- (void) getPhoneDetails {
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [[NSMutableDictionary alloc]init];
    resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    NSString *clientID = [responseDict objectForKey:@"CLIENTID"];
    NSString *sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    NSString *phoneID = [phoneDetails objectForKey:@"id"];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/get_phone_details_v2/%@/%@/%@",PORTAL_URL, phoneID, clientID,sessionID];
    
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
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:dictData forKey:@"getPhoneDetails"];
    }
}



- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO", nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void) processAllPlan{
    //[self getPhoneDetails];
    [self getProductPlans]; //get list of personliazed plan including Intl
    [self getBundlePlans];  //get bundle list unlimited
    [self processAllData];  // get current plan of user
    [self checkIfOldBundleExist]; // compare if current plan exist in current bundles
    [self getCurrentPlanPriceUnli]; // get this month price unlimited
    [self getCurrentPlanPriceIntl]; // get this month price international
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableBundles reloadData];
    });
}

- (void) processMBBPlans{
    //[self getPhoneDetails];
    [self getMBBPlans];
    [self processAllData];
    [self checkIfOldBundleExistMBB];
    [self getCurrentPlanPrice];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableBundles reloadData];
    });
}

- (NSString*) checkIfOldBundleExistMBB{
    missingIDMBB = @"";
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            if ([planID  isEqual: @"5"]) {
                int checkExistMBBBundle = 0;
                for (int j=0; [mbbPlanArray count] > j; j++) {
                    NSString * dataID = [[mbbPlanArray objectAtIndex:j] objectForKey:@"id"];
                    if ([dataID isEqualToString:planId]) {
                        checkExistMBBBundle = 1;
                    }
                }
                if (checkExistMBBBundle == 0) {
                    missingIDMBB = planId;
                    //[self getMBBPlans];
                    return planId;
                }
            }
        }
    }
    return @"";
}

-(void) getMBBPlans{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbroadbandplans2/%@",PORTAL_URL, missingIDMBB];
    
    if (pending_fkbundleid >= 0) {
        strPortalURL = [NSString stringWithFormat:@"%@/getbroadbandplans2/%d",PORTAL_URL, pending_fkbundleid];
    } else {
        strPortalURL = [NSString stringWithFormat:@"%@/getbroadbandplans2/%@", PORTAL_URL, missingID];
    }
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
        mbbPlans = [[NSMutableDictionary alloc] init];
        mbbPlans = [dictData objectForKey:@"broadbandplans"];
        NSMutableDictionary *resultRP12MBB = [mbbPlans objectForKey:@"RP12"];
        NSArray *mbbID = [resultRP12MBB allKeys];
        NSMutableArray* mbbPlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [mbbID count]; i++) {
            NSMutableDictionary * rp12IDValue = [[NSMutableDictionary alloc] init];
            rp12IDValue = [resultRP12MBB objectForKey:[mbbID objectAtIndex:i]];
            [mbbPlanArrayMutable addObject:rp12IDValue];
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"slider"  ascending:YES];
        mbbPlanArray = [mbbPlanArrayMutable sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    }
}


-(void) checkPendingPlans: (NSMutableDictionary*) dictData{
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    pending_fkbundleid = [[resultData objectForKey:@"pending_fkbundleid"] intValue];
    fkbundleid = [resultData objectForKey:@"fkbundleid"];
    NSMutableArray * arrayProductPlan = [[NSMutableArray alloc]init];
    arrayProductPlan = [resultData objectForKey:@"productplan"];
    pendingProduct = [[NSMutableArray alloc]init];
    for (int i=0; i < [arrayProductPlan count]; i++) {
        NSMutableDictionary *productplanDict = [arrayProductPlan objectAtIndex:i];
        NSString *name_text = [productplanDict objectForKey:@"name_text"];
        NSString *pending = [productplanDict objectForKey:@"pending"];
        NSString *expiry_real = [productplanDict objectForKey:@"expiry_real"];
        if ([name_text  isEqual: @"Yomojo Voice"]) {
            NSLog(@"name_text: %@",name_text);
        } else {
            if (pending_fkbundleid > 0) {
                if (![pending isEqual: @""]) {
                    if ([expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                        [pendingProduct addObject:productplanDict];
                    }
                }
                pendingPlansService = @"unlimited";
            } else if (![pending  isEqual: @""]) {
                if ([expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                    [pendingProduct addObject:productplanDict];
                }
                pendingPlansService = @"personalized";
            }
        }
    }
}

//MARK: - getBundlePlans
- (void) getBundlePlans {
    if (![missingID  isEqual: @""]) {
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbundles2/%@", PORTAL_URL, missingID];
        
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
                if ([missingID isEqual: @""]) {
                    //[arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                } else {
                    NSString * strID = [[arrayBundles objectAtIndex:i] objectForKey:@"id"];
                    if ([missingID isEqualToString: strID]) {
                        NSString * amount = [[arrayBundles objectAtIndex:i] objectForKey:@"amount"];
                        NSString * description = [[arrayBundles objectAtIndex:i] objectForKey:@"description"];
                        if (i > 0) {
                            NSString * amountMinus1 = [[arrayBundles objectAtIndex:i-1] objectForKey:@"amount"];
                            NSString * descriptionMinus1 = [[arrayBundles objectAtIndex:i-1] objectForKey:@"description"];
                            if (([amount isEqualToString:amountMinus1]) && ([description isEqualToString:descriptionMinus1])) {
                                missingID = @"";
                                currentPlanFromMissing = [[arrayBundles objectAtIndex:i-1] objectForKey:@"id"];
                                currentPlanUnliIndex = i-1;
                            }
                        } else {
                            // [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                        }
                    } else {
                        // [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                    }
                }
            }
        }
    } else {
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbundles2", PORTAL_URL];
        
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
            arrayUnliBundles = [[NSMutableArray alloc]init];
            for (int i=0; [arrayBundles count] > i; i++) {
                if ([missingID isEqual: @""]) {
                    [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                } else {
                    NSString * strID = [[arrayBundles objectAtIndex:i] objectForKey:@"id"];
                    if ([missingID isEqualToString: strID]) {
                        NSString * amount = [[arrayBundles objectAtIndex:i] objectForKey:@"amount"];
                        NSString * description = [[arrayBundles objectAtIndex:i] objectForKey:@"description"];
                        NSString * amountMinus1 = [[arrayBundles objectAtIndex:i-1] objectForKey:@"amount"];
                        NSString * descriptionMinus1 = [[arrayBundles objectAtIndex:i-1] objectForKey:@"description"];
                        if (([amount isEqualToString:amountMinus1]) && ([description isEqualToString:descriptionMinus1])) {
                            missingID = @"";
                            currentPlanFromMissing = [[arrayBundles objectAtIndex:i-1] objectForKey:@"id"];
                            currentPlanUnliIndex = i-1;
                        } else {
                            [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                        }
                    } else {
                        [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
                    }
                }
            }
        }
    }
}

//MARK: - sliderIntlPack
- (void) sliderIntlPack {
    //set intl slider bar
    NSMutableArray *valueSelectionIntl = [[NSMutableArray alloc]init];
    for (int i=0; [intlPlanArray count] > i; i++) {
        if (i == 0) {
            [valueSelectionIntl addObject: @"0"];
        }
        NSString * titleLabel = [[intlPlanArray objectAtIndex:i] objectForKey:@"planname"];
        titleLabel = [titleLabel stringByReplacingOccurrencesOfString: @"International Voice " withString:@""];
        [valueSelectionIntl addObject: titleLabel];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    imgBGIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
    [imgBGIntl setBackgroundColor:[UIColor YomoLightGrayColor]];
    imgProgressIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
    [imgProgressIntl setBackgroundColor:[UIColor YomoDarkGrayColor]];
    SEFilterControl* filterIntl = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionIntl];
    [filterIntl addTarget:self action:@selector(actionSliderIntl:) forControlEvents:UIControlEventValueChanged];
    filterIntl.progressColor = [UIColor YomoDarkGrayColor];
    [filterIntl setSelectedIndex:selectedIntl animated:YES];
    [viewIntlPackHolder addSubview:imgBGIntl];
    [viewIntlPackHolder addSubview:imgProgressIntl];
    [viewIntlPackHolder addSubview:filterIntl];
}

-(void) getProductPlans{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getproductplans2", PORTAL_URL];
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
        
        NSMutableDictionary *resultRP9 = [productplans objectForKey:@"RP12"];
        NSArray *voicePlanID = [resultRP9 allKeys];
        NSMutableArray* voicePlanArrayMutable = [[NSMutableArray alloc] init];
        for (int i=0; i < [voicePlanID count]; i++) {
            NSMutableDictionary *rp9IDValue = [[NSMutableDictionary alloc] init];
            rp9IDValue = [resultRP9 objectForKey:[voicePlanID objectAtIndex:i]];
            [voicePlanArrayMutable addObject:rp9IDValue];
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"slider"  ascending:YES];
        
        intlPlanArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *resultRP11 = [productplans objectForKey:@"RP11"];
        NSArray *intlPlanID = [resultRP11 allKeys];
        NSMutableArray* intlPlanArrayMutable = [[NSMutableArray alloc] init];
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
        } else {
            [self addToArray:productplanDict];
        }
    }
}

//- (void) addToArray:(NSMutableDictionary*)productDict{
//    //int num = 0;
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"dd-MM-yyyy";
//    NSString *productExpiry = [productDict objectForKey:@"expiry"];
//    NSDate *currDate = [NSDate date];
//    NSString *strCurrDate = [dateFormatter stringFromDate:currDate];
//    [productPlanArray addObject:productDict];
//
//    NSLog(@"productPlanArray: %@",productPlanArray);
//}

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
        //NSString *Pid = [arrayContent objectForKey:@"id"];
        NSString *nameText = [arrayContent objectForKey:@"name_text"];
        NSString *strExpiry = [arrayContent objectForKey:@"expiry"];
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
    }
}

//MARK: - checkIfOldBundleExist
- (NSString*) checkIfOldBundleExist{
    int unli = 0;
    isUnliPlan = 0;
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        NSString *planId = [jsonData objectForKey:@"id"];
        NSString *planCode = [jsonData objectForKey:@"code"];
        NSString *name = [jsonData objectForKey:@"name"];
        if (unli == 0) {
            if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
                //unli = 0;
                //isUnliPlan = 0;
                NSLog(@"not unli");
            } else {
                unli = 1;
                isUnliPlan = 1;
            }
        }
        NSMutableDictionary *resultRP = [productplans objectForKey:planCode];
        NSMutableDictionary *planDetails = [resultRP objectForKey:planId];
        NSString *planname = [planDetails objectForKey:@"planname"];
        NSString *name_text =[jsonData objectForKey:@"name_text"];
//        fkbundleid = [jsonData objectForKey:@"fkbundleid"];
        if ([name_text isEqualToString:@"Data"]){
            NSString *strGB = [planname stringByReplacingOccurrencesOfString:@"National Data " withString:@""];
            strGB = [NSString stringWithFormat:@"Unlimited Voice & SMS & %@ Data",strGB];
            int checkExistDataBundle = 0;
            for (int i=0; [arrayUnliBundles count] > i; i++) {
                NSString * strID = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"id"];
                if ([fkbundleid isEqualToString:strID]) {
                    checkExistDataBundle = 1;
                }
            }
            if (checkExistDataBundle == 0) {
                missingID = fkbundleid;
                if (![missingID  isEqual: @""]) {
                    isUnliPlan = 1;
                    [self getBundlePlans];
                }
                return fkbundleid;
            }
        }
    }
    return @"";
}

//MARK: - getCurrentPlanPrice
- (NSString *) getCurrentPlanPrice {
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            if ([planID  isEqual: @"5"]) {
                NSString *name_text =[jsonData objectForKey:@"name_text"];
                NSString *pedPlanID = @"";
                for (int j=0; [mbbPlanArray count] > j; j++) {
                    NSString * dataID = [[mbbPlanArray objectAtIndex:j] objectForKey:@"id"];
                    NSString * amount = [[mbbPlanArray objectAtIndex:j] objectForKey:@"planamount"];
                    NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:j];
                    if ([pendingProduct count] > 0) {
                        for (int x=0; x < [pendingProduct count]; x++) {
                            NSDictionary *jsonData1 = [[NSDictionary alloc]init];
                            jsonData1 = [pendingProduct objectAtIndex:x];
                            NSString *pendingPlanId = [jsonData1 objectForKey:@"id"];
                            NSString *name_text1 =[jsonData1 objectForKey:@"name_text"];
                            if ([dataID isEqualToString:pendingPlanId]) {
                                NSLog(@"Name: %@",name_text1);
                                NSLog(@"$%.02f",[amount floatValue]);
                                pendingMBB = j;
                                pedPlanID = pendingPlanId;
                            }
                        }
                    }
                    if ([dataID isEqualToString:planId] && ![dataID isEqualToString:pedPlanID]) {
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        amountMBB = [dictValue objectForKey:@"planamount"];
                        mbbBundle = [[dictValue objectForKey:@"id"] intValue];
                        selectedMBB = j;
                    }
                }
            }
        }
    }
    return @"";
}

//MARK: - getCurrentPlanPriceUnli
- (NSString *) getCurrentPlanPriceUnli {
    NSString * strTotalPrice = @"";
    float newTotalPriceCurrent = 0.0;
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            NSString *planCode = [jsonData objectForKey:@"code"];
            NSMutableDictionary *resultRP = [productplans objectForKey:planCode];
            NSMutableDictionary *planDetails = [resultRP objectForKey:planId];
            NSString *planname = [planDetails objectForKey:@"planname"];
            NSString *name_text =[jsonData objectForKey:@"name_text"];
//            fkbundleid = [jsonData objectForKey:@"fkbundleid"];
            NSString *strGB = [planname stringByReplacingOccurrencesOfString:@"National Data " withString:@""];
            strGB = [NSString stringWithFormat:@"Unlimited Voice & SMS & %@ Data",strGB];
            int withPendingData = 0;
            for (int i=0; [arrayUnliBundles count] > i; i++) {
                if (i > 0) {
                    NSString * strID = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"id"];
                    if (pending_fkbundleid == [strID intValue]) {
                        NSString * amount = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"amount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        newTotalPriceCurrent = newTotalPriceCurrent + [amount floatValue];
                        strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPriceCurrent];
                        NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                        amountUnliPending = [dictValue objectForKey:@"amount"];
                        unliDataPending = [[dictValue objectForKey:@"id"] intValue];
                        selectedUnli = i;
                        //currentPlanUnliIndex = i;
                        withPendingData = 1;
                    } else if ([fkbundleid isEqualToString:strID]) {
                        NSString * amount = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"amount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        newTotalPriceCurrent = newTotalPriceCurrent + [amount floatValue];
                        strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPriceCurrent];
                        NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                        amountUnli = [dictValue objectForKey:@"amount"];
                        unliData = [[dictValue objectForKey:@"id"] intValue];
                        //selectedUnli = i ;
                        currentPlanUnliIndex = i;
                    } else if ([currentPlanFromMissing isEqualToString:strID]) {
                        NSString * amount = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"amount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        newTotalPriceCurrent = newTotalPriceCurrent + [amount floatValue];
                        strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPriceCurrent];
                        if (i == 0) {
                            NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:(i + 1)];
                            amountUnli = [dictValue objectForKey:@"amount"];
                            unliData = [[dictValue objectForKey:@"id"] intValue];
                            //selectedUnli = i + 1;
                            currentPlanUnliIndex = i + 1;
                        } else {
                            NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                            amountUnli = [dictValue objectForKey:@"amount"];
                            unliData = [[dictValue objectForKey:@"id"] intValue];
                            //selectedUnli = i ;
                            currentPlanUnliIndex = i;
                        }
                    }
                }
            }
        }
    }
    lblThisMonthPrice.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    lblNextmonthAmount.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    return strTotalPrice;
}

//MARK: - getCurrentPlanPriceIntl
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
                    } else if (([intlID isEqualToString:planId]) && (pendingExist < 1)) {
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
    lblThisMonthPrice.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    lblNextmonthAmount.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];
    return strTotalPrice;
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
    } else {
        NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountIntl = [dictValue objectForKey:@"planamount"];
        personIntl = [[dictValue objectForKey:@"id"] intValue];
    }
    selectedIntl = sender.selectedIndex;
    float totalPrice = 0.0;
    if (pending_fkbundleid > 0) {
        totalPrice  = [amountIntl floatValue] + [amountUnliPending floatValue];
    } else {
        totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
    }
    lblIntlPackPrice.text = [NSString stringWithFormat:@"$%.02f*", [amountIntl floatValue]];
    lblNextmonthAmount.text = [NSString stringWithFormat:@"$%.02f*", totalPrice];
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

//MARK: - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([planID  isEqual: @"5"]){
        return [mbbPlanArray count];
    }
    return [arrayUnliBundles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    ChangePlanNewTableViewCell *cell = (ChangePlanNewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    BOOL isCurrent = NO;
    BOOL is3g = NO;
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChangePlanNewTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    
    if ([planID isEqual: @"5"]){
        jsonData = [mbbPlanArray objectAtIndex:indexPath.section];
        NSString * titleLabel = [jsonData objectForKey:@"planname"];
        NSString * sim_type = @"";
        NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @" "];
        
        cell.img4G3G.backgroundColor = [UIColor YomoPinkColor];
        cell.lblData.textColor = [UIColor YomoPinkColor];
        cell.lblPrice.textColor = [UIColor YomoPinkColor];
        cell.viewBoxPlan.layer.borderColor = [UIColor YomoPinkColor].CGColor;
        cell.lblCurrentNetMont.textColor = [UIColor YomoPinkColor];
        
        
        NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
        strDescription = [strDescription lowercaseString];
        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
        lblBundlePlansDescription.text = strDescription;
        
        NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
        
        cell.lbl4G3G.text = [NSString stringWithFormat:@"%@",sim_type];
        
        cell.lbl4G3G.textColor = [UIColor whiteColor];
        cell.lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
        cell.lblDescription.text = titleLabel;
        
        CGFloat borderWidth = 2.0f;
        cell.viewBoxPlan.frame = CGRectInset(cell.viewBoxPlan.frame, -borderWidth, -borderWidth);
        cell.viewBoxPlan.layer.borderWidth = borderWidth;
        cell.viewBoxPlan.layer.cornerRadius = 15;
        cell.viewBoxPlan.layer.masksToBounds = true;
        
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@", [jsonData objectForKey:@"planamount"]];
        cell.lbl4G3G.text = @"4G";
        if (selectedMBB == indexPath.section){
            isCurrent = YES;
            cell.viewCurrentPlan.hidden = NO;
            cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
            cell.lblCurrentNetMont.text = @"Current plan";
            
            //            cell.viewBoxPlan.backgroundColor = [UIColor groupTableViewBackgroundColor];
            //            cell.lblData.textColor = [UIColor darkGrayColor];
            //            cell.lblPrice.textColor = [UIColor darkGrayColor];
            //            cell.img4G3G.backgroundColor =  [UIColor lightGrayColor];
            //            cell.viewBoxPlan.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
        }
        if ([pendingProduct count] > 0){
            if (pendingMBB == indexPath.section){
                isCurrent = NO;
                cell.viewCurrentPlan.hidden = NO;
                cell.lblCurrentNetMont.text = @"Next month";
                cell.imgBannerImage.image = [UIImage imageNamed:@"nextMonth4G"];
            }
        }
    } else {
        jsonData = [arrayUnliBundles objectAtIndex:indexPath.section];
        NSString * titleLabel = [jsonData objectForKey:@"description"];
        NSString * sim_type = [jsonData objectForKey:@"sim_type"];
        
        if (sim_type) {
            if ([sim_type isEqual: @"3G"]) {
                is3g = YES;
                cell.img4G3G.backgroundColor = [UIColor YomoOrangeColor];
                cell.lblData.textColor = [UIColor YomoOrangeColor];
                cell.lblPrice.textColor = [UIColor YomoOrangeColor];
                cell.viewBoxPlan.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
                cell.lblCurrentNetMont.textColor  = [UIColor YomoOrangeColor];
            } else {
                is3g = NO;
                cell.img4G3G.backgroundColor = [UIColor YomoPinkColor];
                cell.lblData.textColor = [UIColor YomoPinkColor];
                cell.lblPrice.textColor = [UIColor YomoPinkColor];
                cell.viewBoxPlan.layer.borderColor = [UIColor YomoPinkColor].CGColor;
                cell.lblCurrentNetMont.textColor = [UIColor YomoPinkColor];
            }
        }
        
//        if ([titleLabel isEqualToString:@"Kids Plan"] || (jsonData[@"allocation"] && ![jsonData[@"allocation"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@", jsonData[@"allocation"]] isEqualToString:@"1048576"])) {
//            NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
//            NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
//            lblBundlePlansDescription.text = titleLabel;
//            cell.lblData.text = @"1GB";
//            cell.lblDescription.text = strDescription;//@"200 mins talk & unlimited text";
//        } else {
        NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
        NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
//            strDescription = [strDescription lowercaseString];
//            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
        lblBundlePlansDescription.text = strDescription;
        
        NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
        cell.lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
        cell.lblDescription.text = strDescription;//[strDescription stringByReplacingOccurrencesOfString:@"sms" withString:@"text"];
        
//        }
        cell.lbl4G3G.text = [NSString stringWithFormat:@"%@",sim_type];
        cell.lbl4G3G.textColor = [UIColor whiteColor];
        CGFloat borderWidth = 2.0f;
        cell.viewBoxPlan.frame = CGRectInset(cell.viewBoxPlan.frame, -borderWidth, -borderWidth);
        cell.viewBoxPlan.layer.borderWidth = borderWidth;
        cell.viewBoxPlan.layer.cornerRadius = 15;
        cell.viewBoxPlan.layer.masksToBounds = true;
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@", [jsonData objectForKey:@"amount"]];
        if (isUnliPlan == 0) {
            cell.imgBannerImage.hidden = YES;
        } else {
            cell.imgBannerImage.hidden = NO;
        }
        if (pending_fkbundleid > 0) {
            if (selectedUnli == indexPath.section) {
                isCurrent = NO;
                if ([sim_type isEqual: @"3G"]) {
                    is3g = YES;
                    cell.imgBannerImage.image = [UIImage imageNamed:@"NextMonthSash3G"];
                } else {
                    is3g = NO;
                    cell.imgBannerImage.image = [UIImage imageNamed:@"nextMonth4G"];
                }
                cell.viewCurrentPlan.hidden = NO;
                cell.imgBannerImage.hidden = NO;
            }
        }
        if (currentPlanUnliIndex == 0) {
            if (![currentPlanFromMissing  isEqual: @""]) {
                if (currentPlanUnliIndex == indexPath.section) {
                    cell.viewCurrentPlan.hidden = NO;
                    isCurrent = YES;
                    if ([sim_type isEqual: @"3G"]){
                        is3g = YES;
                        cell.imgBannerImage.image = [UIImage imageNamed:@"CurrentMonthSash3G"];
                    } else {
                        is3g = NO;
                        cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
                        cell.lbl4G3G.text = @"4G";
                    }
                    if (isUnliPlan > 0) {
                        if (![missingID  isEqual: @""]) {
                            cell.viewCurrentPlan.hidden = YES;
                            cell.viewBoxPlan.backgroundColor = [UIColor groupTableViewBackgroundColor];
                            cell.lblData.textColor = [UIColor darkGrayColor];
                            cell.lblPrice.textColor = [UIColor darkGrayColor];
                            cell.img4G3G.backgroundColor =  [UIColor lightGrayColor];
                            cell.viewBoxPlan.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        }
                    }
                }
            } else {
                if (isUnliPlan > 0) {
                    NSString * strId = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"id"]];
                    
                    if (pending_fkbundleid == [fkbundleid intValue]) {
                        NSLog(@"Current is pending");
                        //cell.viewCurrentPlan.hidden = YES;
                    } else {
                        if (([strId isEqual: @"30"]) && [missingID isEqual: @""]) {
                            isCurrent = YES;
                            cell.viewCurrentPlan.hidden = NO;
                            cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
                            cell.lbl4G3G.text = @"4G";
                        }
                    }
                }
            }
        } else {
            if (currentPlanUnliIndex == indexPath.section) {
                cell.viewCurrentPlan.hidden = NO;
                isCurrent = YES;
                if ([sim_type isEqual: @"3G"]){
                    is3g = YES;
                    cell.imgBannerImage.image = [UIImage imageNamed:@"CurrentMonthSash3G"];
                } else {
                    is3g = NO;
                    cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
                    cell.lbl4G3G.text = @"4G";
                }
                if (isUnliPlan > 0) {
                    if (![missingID  isEqual: @""]) {
                        cell.viewBoxPlan.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.lblData.textColor = [UIColor darkGrayColor];
                        cell.lblPrice.textColor = [UIColor darkGrayColor];
                        cell.img4G3G.backgroundColor =  [UIColor lightGrayColor];
                        cell.viewBoxPlan.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    }
                }
            }
        }
    }
    
    if (![planID isEqualToString:@"5"] && (!pendingPlansService || [pendingPlansService isEqualToString:@"unlimited"])) {
        // last check, checking current plan
        NSString *partitionIds = [jsonData valueForKey:@"partitionids"];
        NSArray *partitionIdsArray = [partitionIds componentsSeparatedByString:@","];
        BOOL showViewCurrentPlan = YES;
        NSMutableArray *planIdsFromMainVC = [NSMutableArray new];
        for (NSDictionary *product in self.productPlanFromMainVC) {
            if (![[product valueForKey:@"id"] isKindOfClass:[NSNull class]] && [product valueForKey:@"id"]) {
                NSString *idOfPlan = [product valueForKey:@"id"];
                [planIdsFromMainVC addObject:idOfPlan];
            }
        }
        if (partitionIds == nil || partitionIds.length == 0) {
            showViewCurrentPlan = NO;
        } else {
            for (NSString *partitionId in partitionIdsArray) {
                if ([planIdsFromMainVC containsObject:partitionId]) {
                    showViewCurrentPlan = YES;
//                    break;
                } else {
                    showViewCurrentPlan = NO;
                }
            }
        }
        if (showViewCurrentPlan) {
            isCurrent = YES;
            cell.viewCurrentPlan.hidden = NO;
            cell.imgBannerImage.hidden = NO;
            cell.lblCurrentNetMont.text = @"Current plan";
            if (is3g) {
                cell.imgBannerImage.image = [UIImage imageNamed:@"CurrentMonthSash3G"];
            } else {
                cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
            }
        } else {
            isCurrent = NO;
            cell.viewCurrentPlan.hidden = YES;
            cell.imgBannerImage.hidden = YES;
            cell.lblCurrentNetMont.text = @"Next month";
            if (is3g) {
                cell.imgBannerImage.image = [UIImage imageNamed:@"NextMonthSash3G"];
            } else {
                cell.imgBannerImage.image = [UIImage imageNamed:@"nextMonth4G"];
            }
        }
    }
    
    NSString * strID = [[arrayUnliBundles objectAtIndex:indexPath.section] objectForKey:@"id"];
    if (pending_fkbundleid == [strID intValue] && strID != nil && arrayUnliBundles != nil) {
        if (!isCurrent) {
            cell.viewCurrentPlan.hidden = NO;
            cell.imgBannerImage.hidden = NO;
            cell.lblCurrentNetMont.text = @"Next month";
            if (is3g) {
                cell.imgBannerImage.image = [UIImage imageNamed:@"NextMonthSash3G"];
            } else {
                cell.imgBannerImage.image = [UIImage imageNamed:@"nextMonth4G"];
            }
        }
    }
    //later we will clean the excess parts
    if (fkbundleid == strID && strID != nil && arrayUnliBundles != nil) {
        if (!isCurrent) {
            cell.viewCurrentPlan.hidden = NO;
            cell.imgBannerImage.hidden = NO;
            cell.lblCurrentNetMont.text = @"Current Plan";
            if (is3g) {
                cell.imgBannerImage.image = [UIImage imageNamed:@"CurrentMonthSash3G"];
            } else {
                cell.imgBannerImage.image = [UIImage imageNamed:@"currentPlanSash4G"];
            }
        }
    }
    return cell;
}

//MARK: - TableView DidSelectRowAt
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    NSInteger selectedIndex = 0;
    if ([planID  isEqual: @"5"]){
        jsonData = [mbbPlanArray objectAtIndex:indexPath.section];
        selectedIndex = selectedMBB;
    } else {
        jsonData = [arrayUnliBundles objectAtIndex:indexPath.section];
        selectedIndex = currentPlanUnliIndex;
    }
    
    amountUnli = [jsonData objectForKey:@"amount"];
    lblNextmonthAmount.text = [NSString stringWithFormat:@"$%.02f*", ([amountUnli floatValue] + [amountIntl floatValue])];

    NSString * titleLabel = [jsonData objectForKey:@"description"];
    if ([titleLabel isEqualToString:@"Kids Plan"] || (jsonData[@"allocation"] && ![jsonData[@"allocation"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@", jsonData[@"allocation"]] isEqualToString:@"1048576"])) {
        lblBundlePlansDescription.text = titleLabel;
        //cell.lblData.text = @"1GB";
        lblBundlePlansDescription.text = @"200 mins talk & unlimited text";
    } else {
        NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
        NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
        strDescription = [strDescription lowercaseString];
        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
        lblBundlePlansDescription.text = strDescription;
    }
    
    NSString *serviceID = [jsonData objectForKey:@"id"];
    
    if (![missingID  isEqual: serviceID]) {
//        if (selectedIndex == indexPath.section) {
            NSLog(@"Current plan");
            jsonDataSubmit = [[NSMutableDictionary alloc] init];
            jsonDataSubmit = jsonData;
            
            cuurentID = [[jsonData objectForKey:@"id"] intValue];
            
            NSString *alertString = @"";
            if ([planID  isEqual: @"5"]){
                NSString * titleLabel = [jsonData objectForKey:@"planname"];
                alertString = [NSString stringWithFormat:@"Cancel pending plan, change to %@",titleLabel];
            } else {
                alertString = [NSString stringWithFormat:@"Cancel pending plan, change to %@",titleLabel];
            }
            
            if ((pending_fkbundleid > 0) &&  (pending_fkbundleid != cuurentID)){
                NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                ChangePlanNewTableViewCell *cell = (ChangePlanNewTableViewCell *)[tableBundles cellForRowAtIndexPath:a];
                if (cell.viewCurrentPlan.hidden == NO) {
                    [self alertStatus:@"" :alertString];
                } else {
                    FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
                    nmvc.jsonData = jsonDataSubmit;
                    nmvc.planID = planID;
                    nmvc.urlData = urlData;
                    nmvc.phonesArray = phonesArray;
                    nmvc.amountMBB = amountMBB;
                    [self.navigationController setNavigationBarHidden:YES];
                    [self.navigationController pushViewController:nmvc animated:YES];
                }
            } else {
                NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                ChangePlanNewTableViewCell *cell = (ChangePlanNewTableViewCell *)[tableBundles cellForRowAtIndexPath:a];
                
                if ([planID  isEqual: @"5"]){
                    if ([pendingProduct count] > 0){
                        if (cell.viewCurrentPlan.hidden == NO) {
                            [self alertStatus:@"" :alertString];
                        } else {
                            FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
                            nmvc.jsonData = jsonDataSubmit;
                            nmvc.planID = planID;
                            nmvc.urlData = urlData;
                            nmvc.phonesArray = phonesArray;
                            nmvc.amountMBB = amountMBB;
                            [self.navigationController setNavigationBarHidden:YES];
                            [self.navigationController pushViewController:nmvc animated:YES];
                        }
                    } else {
                        NSLog(@"Current Plan");
                    }
                } else {
                    if (pending_fkbundleid != cuurentID){
                        FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
                        nmvc.jsonData = jsonDataSubmit;
                        nmvc.planID = planID;
                        nmvc.urlData = urlData;
                        nmvc.phonesArray = phonesArray;
                        nmvc.amountMBB = amountMBB;
                        [self.navigationController setNavigationBarHidden:YES];
                        [self.navigationController pushViewController:nmvc animated:YES];
                    } else {
                        NSLog(@"Current Plan");
                        if (cell.viewCurrentPlan.hidden == NO) {
                            [self alertStatus:@"" :alertString];
                        }
                    }
                }
            }
            
            //            FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
            //            nmvc.jsonData = jsonData;
            //            nmvc.planID = planID;
            //            nmvc.urlData = urlData;
            //            nmvc.phonesArray = phonesArray;
            //            nmvc.amountMBB = amountMBB;
            //            [self.navigationController setNavigationBarHidden:YES];
            //            [self.navigationController pushViewController:nmvc animated:YES];
            
            //            if (isUnliPlan == 0) {
            //                FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
            //                nmvc.jsonData = jsonData;
            //                nmvc.planID = planID;
            //                nmvc.urlData = urlData;
            //                nmvc.phonesArray = phonesArray;
            //                nmvc.amountMBB = amountMBB;
            //                [self.navigationController setNavigationBarHidden:YES];
            //                [self.navigationController pushViewController:nmvc animated:YES];
            //            } else {
            //                if (selectedIndex == 0){
            //                    FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
            //                    nmvc.jsonData = jsonData;
            //                    nmvc.planID = planID;
            //                    nmvc.urlData = urlData;
            //                    nmvc.phonesArray = phonesArray;
            //                    nmvc.amountMBB = amountMBB;
            //                    [self.navigationController setNavigationBarHidden:YES];
            //                    [self.navigationController pushViewController:nmvc animated:YES];
            //                }
            //            }
//        }
//        else {
//            FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
//            nmvc.jsonData = jsonData;
//            nmvc.planID = planID;
//            nmvc.urlData = urlData;
//            nmvc.phonesArray = phonesArray;
//            nmvc.amountMBB = amountMBB;
//            [self.navigationController setNavigationBarHidden:YES];
//            [self.navigationController pushViewController:nmvc animated:YES];
//        }
    } else {
        NSLog(@"Current plan not selling");
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        [self moveToFinalizedPage];
    }
}

- (void) moveToFinalizedPage{
    FinalizedChangePlanViewController *nmvc= [[FinalizedChangePlanViewController alloc] initWithNibName:@"FinalizedChangePlanViewController" bundle:[NSBundle mainBundle]];
    nmvc.jsonData = jsonDataSubmit;
    nmvc.planID = planID;
    nmvc.urlData = urlData;
    nmvc.phonesArray = phonesArray;
    nmvc.amountMBB = amountMBB;
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:nmvc animated:YES];
}

@end
