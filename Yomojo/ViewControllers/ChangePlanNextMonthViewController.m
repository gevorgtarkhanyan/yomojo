//
//  ChangePlanNextMonthViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 23/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "ChangePlanNextMonthViewController.h"
#import "ChangePlanNextMonthTableViewCell.h"
#import <PKRevealController/PKRevealController.h>

#define LEFT_OFFSET                         25
#define RIGHT_OFFSET                        25
#define TITLE_SELECTED_DISTANCE             5
#define TITLE_FADE_ALPHA                    .5f

#define KNOB_HEIGHT                         55
#define KNOB_WIDTH                          35


@interface ChangePlanNextMonthViewController ()

@end

@implementation ChangePlanNextMonthViewController
@synthesize urlData,phonesArray,segmentControl,personalizedView,unlimitedView,imgProgressVoice,imgBG,imgBGSMS,imgProgressSMS,imgBGData,imgProgressData,imgBGIntl,imgProgressIntl,tableViewNextMonth,productplans;
@synthesize amountVoice,amountSMS, amountData, amountIntl, amountUnli, selectedSMS,selectedData,selectedIntl,selectedVoice,selectedUnli,imgProgressUnli,imgBGUnli,imgBGIntlUnli,imgProgressIntlUnli;
@synthesize smsPlanArray,voicePlanArray,dataPlanArray,intlPlanArray,newTotalPrice,bundlesPlans,tableViewUnli,arrayUnliBundles,billingType,lblMobileBroadband;
@synthesize unliData, unliIntl, unliTopup, personVoice, personSMS, personData, personIntl, personTopup,planID,imgLine, imgProgressMBB,imgBGMBB,tableViewMBB, mbbPlanArray,selectedMBB,amountMBB,mbbBundle;
@synthesize  productPlan, productPlanArray,accountUnli, mbbPlans, missingID, initalLoadUnli, initialLoadIntl, missingIDMBB, initialLoadMBB, initialLoadPersonal,plans3G_4G, pending_fkbundleid;
@synthesize amountUnliPending, unliDataPending, selectedUnliPending, pendingProduct, pendingPlansService, mbbThisMonthTotal, textView, thisMonthAmountUnli;

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    newTotalPrice = 0.0;
    missingID = @"";
    missingIDMBB =@"";
    initalLoadUnli = 0;
    initialLoadIntl = 0;
    initialLoadMBB = 0;
    initialLoadPersonal = 0;
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictData = [userLogin objectForKey:@"getPhoneDetails"];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    
    billingType = [[resultData objectForKey:@"billing_type"]intValue];
    
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    planID = [phoneDetails objectForKey:@"planid"];
    
    [self checkPendingPlans:dictData];

    if ([planID  isEqual: @"5"]) {
        segmentControl.hidden = YES;
        imgLine.hidden = YES;
        lblMobileBroadband.hidden = NO;
        tableViewMBB.hidden = NO;
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(processMBBPlans) onTarget:self withObject:nil animated:YES];
        [tableViewMBB reloadData];
    }
    else {
        segmentControl.hidden = YES;
        imgLine.hidden = NO;
        lblMobileBroadband.hidden = YES;
        tableViewMBB.hidden = YES;
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(processAllPlan) onTarget:self withObject:nil animated:YES];
    }
    [self htmStringTextView];
}

- (void) htmStringTextView{
    NSString *htmlString = @"<p style=\"font-family:'helvetica';font-size:1.1em\">Need help with your plan? You can <a style=\"color:#ff4505;\" href=\"https://yomojo.com.au/chat\">chat</a> with us or call us on 1300 966 656.</font></p>";

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    textView.attributedText = attributedString;
}

- (void) processAllPlan{
    [self getProductPlans]; //get list of personliazed plan including Intl
    [self getBundlePlans];  //get bundle list unlimited
    [self processAllData];  // get current plan of user
    [self checkIfOldBundleExist]; // compare if current plan exist in current bundles
    [self getCurrentPlanPriceUnli]; // get this month price unlimited
    [self getCurrentPlanPriceIntl]; // get this month price international
    if (isUnliPlan != 1){
        [self getCurrentPlanPrice]; // get this month price personalized
    }
    [tableViewUnli reloadData];
    [self processPrice];
    [segmentControl setSelectedSegmentIndex:1];
    tableViewUnli.hidden = NO;
}

- (void) processMBBPlans{
    [self getMBBPlans];
    [self processAllData];
    [self checkIfOldBundleExistMBB];
    [self getCurrentPlanPrice];
    [tableViewMBB reloadData];
    [self processPrice];
}

-(NSString*) getThisMonthPriceForMBB {
    NSString * strTotalPrice = @"";
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            //NSString *name = [jsonData objectForKey:@"name"];
            NSString *pending_text =[jsonData objectForKey:@"pending"];
            NSString *expiry_real = [jsonData objectForKey:@"expiry_real"];
            int pendingExist = 0;
            if ([planID  isEqual: @"5"]) {
                NSString *name_text =[jsonData objectForKey:@"name_text"];
                for (int j=0; [mbbPlanArray count] > j; j++) {
                    NSString * dataID = [[mbbPlanArray objectAtIndex:j] objectForKey:@"id"];
                    if (([dataID isEqualToString:planId])  && (![pending_text isEqual: @""])) {
                        if (![expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                            strTotalPrice = [[mbbPlanArray objectAtIndex:j] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[strTotalPrice floatValue]);
                            pendingExist = 1;
                        }
                    }
                    else if (([dataID isEqualToString:planId]) && (pendingExist < 1)) {
                        strTotalPrice = [[mbbPlanArray objectAtIndex:j] objectForKey:@"planamount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[strTotalPrice floatValue]);
                    }
                }
            }
        }
    }
    return strTotalPrice;
}

-(NSString *) getThisMonthPriceForIntl {
    NSString *strAmountIntl = @"";
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            NSString *name_text =[jsonData objectForKey:@"name_text"];
            NSString *pending_text =[jsonData objectForKey:@"pending"];
            NSString *expiry_real = [jsonData objectForKey:@"expiry_real"];
            int pendingExist = 0;
            if ([name_text isEqualToString:@"Intl Voice"]){
                for (int z=0; [intlPlanArray count] > z; z++) {
                    NSString * intlID = [[intlPlanArray objectAtIndex:z] objectForKey:@"id"];
                    if (([intlID isEqualToString:planId]) && (![pending_text  isEqual: @""])){
                        if (![expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                            NSString * amount = [[intlPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:z];
                            strAmountIntl = [dictValue objectForKey:@"planamount"];
                            pendingExist = 1;
                        }
                    }
                    else if (([intlID isEqualToString:planId]) && (pendingExist < 1)) {
                        NSString * amount = [[intlPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:z];
                        strAmountIntl = [dictValue objectForKey:@"planamount"];
                    }
                }
            }
        }
    }
    return strAmountIntl;
}


-(void) checkPendingPlans: (NSMutableDictionary*) dictData{
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    pending_fkbundleid = [[resultData objectForKey:@"pending_fkbundleid"] intValue];
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
        }
        else{
            if (pending_fkbundleid > 0) {
                if (![pending  isEqual: @""]) {
                    if ([expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                        [pendingProduct addObject:productplanDict];
                    }
                }
                pendingPlansService = @"unlimited";
            }
            else if (![pending  isEqual: @""]) {
                if ([expiry_real  isEqual: @"{ts '1970-01-01 00:00:00'}"]) {
                    [pendingProduct addObject:productplanDict];
                }
                pendingPlansService = @"personalized";
            }
        }
    }
}

-(void) processPrice {
    if ([planID  isEqual: @"5"]){
        NSIndexPath *a = nil;
        a = [NSIndexPath indexPathForRow:0 inSection:0];
        ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:a];
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountMBB];
        float totalPrice = 0.0;
        totalPrice = [amountMBB floatValue];
        NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", totalPrice];
        NSIndexPath *b = nil;
        b = [NSIndexPath indexPathForRow:0 inSection:1];
        cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:b];
        cell.lblNextMonthTotal.text = strTotalPrice;
        //cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", mbbThisMonthTotal];
        cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"$%.02f*", [[self getThisMonthPriceForMBB]floatValue] ];
    }
    else{
        if (segmentControl.selectedSegmentIndex == 0){
            [self getCurrentPlanPrice];
            [tableViewNextMonth reloadData];
            
            NSIndexPath *a = nil;
            a = [NSIndexPath indexPathForRow:0 inSection:1];
            ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:a];
            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountUnli];
            float totalPrice = 0.0;
            totalPrice = [amountUnli floatValue] + [amountIntl floatValue];
            NSString *strTotalPrice = [NSString stringWithFormat:@"$%.02f*", totalPrice];
            
            NSIndexPath *b = nil;
            b = [NSIndexPath indexPathForRow:0 inSection:3];
            cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:b];
            cell.lblNextMonthTotal.text = strTotalPrice;
            cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%.02f*", newTotalPrice];
        }
        else{
            thisMonthAmountUnli = @"";
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
                    NSString *fkbundleid = [jsonData objectForKey:@"fkbundleid"];
                    if ([name_text isEqualToString:@"Data"]){
                        NSString *strGB = [planname stringByReplacingOccurrencesOfString:@"National Data " withString:@""];
                        strGB = [NSString stringWithFormat:@"Unlimited Voice & SMS & %@ Data",strGB];
                        for (int i=0; [arrayUnliBundles count] > i; i++) {
                            NSString * strID = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"id"];
                            if ([fkbundleid isEqualToString:strID]) {
                                if (i == 0) {
                                    NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                                    thisMonthAmountUnli = [dictValue objectForKey:@"amount"];
                                }
                                else{
                                    NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                                    thisMonthAmountUnli = [dictValue objectForKey:@"amount"];
                                }
                            }
                        }
                    }
                    else{
                        
                    }
                }
            }

            NSIndexPath *a = nil;
            a = [NSIndexPath indexPathForRow:0 inSection:1];
            ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:a];
            //cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountUnli];
            float totalPrice = 0.0;
            totalPrice = [thisMonthAmountUnli floatValue] + [amountIntl floatValue] + [amountVoice floatValue] + [amountSMS floatValue] + [amountData floatValue];
            NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f", totalPrice];
            
            NSIndexPath *b = nil;
            b = [NSIndexPath indexPathForRow:0 inSection:3];
            cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:b];
            
            
            float floatThisMonthtotalPrice = [thisMonthAmountUnli floatValue] + [[self getThisMonthPriceForIntl] floatValue] + [amountVoice floatValue] + [amountSMS floatValue] + [amountData floatValue];
            strTotalPrice = [NSString stringWithFormat:@"$%.02f", floatThisMonthtotalPrice];
            cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", strTotalPrice];
            
            //NSIndexPath *c = nil;
            //c = [NSIndexPath indexPathForRow:0 inSection:4];
            //cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:c];
            //cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", strTotalPrice];
        }
    }
}

- (void) processAllData{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictDataPhoneDetails = [userLogin objectForKey:@"getPhoneDetails"];
    [self processDictData:dictDataPhoneDetails];
}

- (NSString*) checkIfOldBundleExist{
    int unli = 0;
    missingID = @"";
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            NSString *planCode = [jsonData objectForKey:@"code"];
            NSString *name = [jsonData objectForKey:@"name"];
            if (unli == 0) {
                if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
                    unli = 0;
                    isUnliPlan = 0;
                }
                else {
                    unli = 1;
                    isUnliPlan = 1;
                }
            }
            if (unli == 1) {
                NSMutableDictionary *resultRP = [productplans objectForKey:planCode];
                NSMutableDictionary *planDetails = [resultRP objectForKey:planId];
                NSString *planname = [planDetails objectForKey:@"planname"];
                NSString *name_text =[jsonData objectForKey:@"name_text"];
                NSString *fkbundleid = [jsonData objectForKey:@"fkbundleid"];
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
                        [self getBundlePlans];
                        return fkbundleid;
                    }
                }
            }
        }
    }
    return @"";
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
                    [self getMBBPlans];
                    return planId;
                }
            }
        }
    }
    return @"";
}


-(NSString *) getCurrentPlanPriceUnli{
    NSString * strTotalPrice = @"";
    float newTotalPriceCurrent = 0.0;
    //int unli = 0;
    for (int i=0; i < [productPlanArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [productPlanArray objectAtIndex:i];
        if (![jsonData  isEqual: @"temp"]) {
            NSString *planId = [jsonData objectForKey:@"id"];
            NSString *planCode = [jsonData objectForKey:@"code"];
            //NSString *name = [jsonData objectForKey:@"name"];
            NSMutableDictionary *resultRP = [productplans objectForKey:planCode];
            NSMutableDictionary *planDetails = [resultRP objectForKey:planId];
            NSString *planname = [planDetails objectForKey:@"planname"];
            NSString *name_text =[jsonData objectForKey:@"name_text"];
            NSString *fkbundleid = [jsonData objectForKey:@"fkbundleid"];
            if ([name_text isEqualToString:@"Data"]){
                NSString *strGB = [planname stringByReplacingOccurrencesOfString:@"National Data " withString:@""];
                strGB = [NSString stringWithFormat:@"Unlimited Voice & SMS & %@ Data",strGB];
                int withPendingData = 0;
                for (int i=0; [arrayUnliBundles count] > i; i++) {
                    if (i > 0){
                        NSString * strID = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"id"];
                        if (pending_fkbundleid == [strID intValue]) {
                            NSString * amount = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"amount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            newTotalPriceCurrent = newTotalPriceCurrent + [amount floatValue];
                            strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPriceCurrent];
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[arrayUnliBundles count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGUnli.frame))/(itemCount - 1);
                            imgProgressUnli.frame = CGRectMake(imgProgressUnli.frame.origin.x, imgProgressUnli.frame.origin.y, oneSlotSize*i, 15);
                            NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                            amountUnliPending = [dictValue objectForKey:@"amount"];
                            unliDataPending = [[dictValue objectForKey:@"id"] intValue];
                            selectedUnli = i;
                            withPendingData = 1;
                        }
                        else if (([fkbundleid isEqualToString:strID]) && (withPendingData < 1)) {
                            NSString * amount = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"amount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            newTotalPriceCurrent = newTotalPriceCurrent + [amount floatValue];
                            strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPriceCurrent];
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[arrayUnliBundles count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGUnli.frame))/(itemCount - 1);
                            if (i == 0) {
                                imgProgressUnli.frame = CGRectMake(imgProgressUnli.frame.origin.x, imgProgressUnli.frame.origin.y, oneSlotSize*(i +1), 15);
                                NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:(i + 1)];
                                amountUnli = [dictValue objectForKey:@"amount"];
                                unliData = [[dictValue objectForKey:@"id"] intValue];
                                selectedUnli = i + 1;
                            }
                            else{
                                imgProgressUnli.frame = CGRectMake(imgProgressUnli.frame.origin.x, imgProgressUnli.frame.origin.y, oneSlotSize*i, 15);
                                NSMutableDictionary *dictValue = [arrayUnliBundles objectAtIndex:i];
                                amountUnli = [dictValue objectForKey:@"amount"];
                                unliData = [[dictValue objectForKey:@"id"] intValue];
                                selectedUnli = i ;
                            }
                        }
                    }
                }
            }
        }
    }
    return strTotalPrice;
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
    return strTotalPrice;
}

-(NSString *) getCurrentPlanPrice{
    NSString * strTotalPrice = @"";
    int unli = 0;
    if ([pendingProduct count] > 0) {
        for (int x=0; x < [pendingProduct count]; x++) {
            NSDictionary *jsonData = [[NSDictionary alloc]init];
            jsonData = [pendingProduct objectAtIndex:x];
            NSString *planId = [jsonData objectForKey:@"id"];
            if ([planID  isEqual: @"5"]) {
                NSString *name_text =[jsonData objectForKey:@"name_text"];
                for (int j=0; [mbbPlanArray count] > j; j++) {
                    NSString * dataID = [[mbbPlanArray objectAtIndex:j] objectForKey:@"id"];
                    if ([dataID isEqualToString:planId]) {
                        NSString * amount = [[mbbPlanArray objectAtIndex:j] objectForKey:@"planamount"];
                        NSLog(@"Name: %@",name_text);
                        NSLog(@"$%.02f",[amount floatValue]);
                        int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[mbbPlanArray count]] intValue];
                        float oneSlotSize = (CGRectGetWidth(imgBGMBB.frame))/(itemCount);
                        imgProgressMBB.frame = CGRectMake(imgProgressData.frame.origin.x, imgProgressData.frame.origin.y, oneSlotSize*(j+1), 15);
                        NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:j];
                        amountMBB = [dictValue objectForKey:@"planamount"];
                        mbbBundle = [[dictValue objectForKey:@"id"] intValue];
                        selectedMBB = j+1;
                        if (initialLoadMBB <= 0){
                            NSIndexPath *b = nil;
                            b = [NSIndexPath indexPathForRow:0 inSection:1];
                            ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:b];
                            cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:b];
                            //cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"$%.02f*",[amount floatValue]];
                            initialLoadMBB = initialLoadMBB + 1;
                            mbbThisMonthTotal = [NSString stringWithFormat:@"$%.02f",[amount floatValue]];
                        }
                        
                    }
                }
            }
            else{
                NSString *name_text =[jsonData objectForKey:@"name_text"];
                if ([name_text isEqualToString:@"Voice"]){
                    for (int z=0; [voicePlanArray count] > z; z++) {
                        NSString * voiceID = [[voicePlanArray objectAtIndex:z] objectForKey:@"id"];
                        if ([voiceID isEqualToString:planId]) {
                            NSString * amount = [[voicePlanArray objectAtIndex:z] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[voicePlanArray count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBG.frame))/(itemCount);
                            imgProgressVoice.frame = CGRectMake(imgProgressVoice.frame.origin.x, imgProgressVoice.frame.origin.y, oneSlotSize*(z+1), 15);
                            NSMutableDictionary *dictValue = [voicePlanArray objectAtIndex:z];
                            amountVoice = [dictValue objectForKey:@"planamount"];
                            personVoice = [[dictValue objectForKey:@"id"] intValue];
                            selectedVoice = z + 1;
                        }
                    }
                }
                else if ([name_text isEqualToString:@"SMS"]){
                    for (int z=0; [smsPlanArray count] > z; z++) {
                        NSString * smsID = [[smsPlanArray objectAtIndex:z] objectForKey:@"id"];
                        if ([smsID isEqualToString:planId]) {
                            NSString * amount = [[smsPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[smsPlanArray count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGSMS.frame))/(itemCount);
                            imgProgressSMS.frame = CGRectMake(imgProgressSMS.frame.origin.x, imgProgressSMS.frame.origin.y, oneSlotSize*(z+1), 15);
                            NSMutableDictionary *dictValue = [smsPlanArray objectAtIndex:z];
                            amountSMS = [dictValue objectForKey:@"planamount"];
                            personSMS = [[dictValue objectForKey:@"id"] intValue];
                            selectedSMS = z+1;
                        }
                    }
                }
                else if ([name_text isEqualToString:@"Data"]){
                    for (int z=0; [dataPlanArray count] > z; z++) {
                        NSString * dataID = [[dataPlanArray objectAtIndex:z] objectForKey:@"id"];
                        if ([dataID isEqualToString:planId]) {
                            NSString * amount = [[dataPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[dataPlanArray count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGData.frame))/(itemCount);
                            imgProgressData.frame = CGRectMake(imgProgressData.frame.origin.x, imgProgressData.frame.origin.y, oneSlotSize*(z+1), 15);
                            NSMutableDictionary *dictValue = [dataPlanArray objectAtIndex:z];
                            amountData = [dictValue objectForKey:@"planamount"];
                            personData = [[dictValue objectForKey:@"id"] intValue];
                            selectedData = z+1;
                        }
                    }
                }
                else if ([name_text isEqualToString:@"Intl Voice"]){
                        for (int z=0; [intlPlanArray count] > z; z++) {
                            NSString * intlID = [[intlPlanArray objectAtIndex:z] objectForKey:@"id"];
                            if ([intlID isEqualToString:planId]) {
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
    else{
        for (int i=0; i < [productPlanArray count]; i++) {
            NSDictionary *jsonData = [[NSDictionary alloc]init];
            jsonData = [productPlanArray objectAtIndex:i];
            if (![jsonData  isEqual: @"temp"]) {
                NSString *name = [jsonData objectForKey:@"name"];
                if (unli == 0) {
                    if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
                        unli = 0;
                    }
                    else {
                        unli = 1;
                    }
                }
                NSString *planId = [jsonData objectForKey:@"id"];
                if ([planID  isEqual: @"5"]) {
                    NSString *name_text =[jsonData objectForKey:@"name_text"];
                    for (int j=0; [mbbPlanArray count] > j; j++) {
                        NSString * dataID = [[mbbPlanArray objectAtIndex:j] objectForKey:@"id"];
                        if ([dataID isEqualToString:planId]) {
                            NSString * amount = [[mbbPlanArray objectAtIndex:j] objectForKey:@"planamount"];
                            NSLog(@"Name: %@",name_text);
                            NSLog(@"$%.02f",[amount floatValue]);
                            int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[mbbPlanArray count]] intValue];
                            float oneSlotSize = (CGRectGetWidth(imgBGMBB.frame))/(itemCount);
                            imgProgressMBB.frame = CGRectMake(imgProgressData.frame.origin.x, imgProgressData.frame.origin.y, oneSlotSize*(j+1), 15);
                            NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:j];
                            amountMBB = [dictValue objectForKey:@"planamount"];
                            mbbBundle = [[dictValue objectForKey:@"id"] intValue];
                            selectedMBB = j+1;
                            
                            if (initialLoadMBB <= 0){
                                NSIndexPath *b = nil;
                                b = [NSIndexPath indexPathForRow:0 inSection:1];
                                ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:b];
                                cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:b];
                                //cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"$%.02f*",[amount floatValue]];
                                initialLoadMBB = initialLoadMBB + 1;
                                mbbThisMonthTotal = [NSString stringWithFormat:@"$%.02f",[amount floatValue]];
                            }
                        }
                    }
                }
                else{
                    if (unli == 1) {
                        NSLog(@"Unlimited");
                    }
                    else{
                        NSString *name_text =[jsonData objectForKey:@"name_text"];
                        if ([name_text isEqualToString:@"Voice"]){
                            for (int z=0; [voicePlanArray count] > z; z++) {
                                NSString * voiceID = [[voicePlanArray objectAtIndex:z] objectForKey:@"id"];
                                if ([voiceID isEqualToString:planId]) {
                                    NSString * amount = [[voicePlanArray objectAtIndex:z] objectForKey:@"planamount"];
                                    NSLog(@"Name: %@",name_text);
                                    NSLog(@"$%.02f",[amount floatValue]);
                                    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[voicePlanArray count]] intValue];
                                    float oneSlotSize = (CGRectGetWidth(imgBG.frame))/(itemCount);
                                    imgProgressVoice.frame = CGRectMake(imgProgressVoice.frame.origin.x, imgProgressVoice.frame.origin.y, oneSlotSize*(z+1), 15);
                                    NSMutableDictionary *dictValue = [voicePlanArray objectAtIndex:z];
                                    amountVoice = [dictValue objectForKey:@"planamount"];
                                    personVoice = [[dictValue objectForKey:@"id"] intValue];
                                    selectedVoice = z + 1;
                                }
                            }
                        }
                        else if ([name_text isEqualToString:@"SMS"]){
                            for (int z=0; [smsPlanArray count] > z; z++) {
                                NSString * smsID = [[smsPlanArray objectAtIndex:z] objectForKey:@"id"];
                                if ([smsID isEqualToString:planId]) {
                                    NSString * amount = [[smsPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                                    NSLog(@"Name: %@",name_text);
                                    NSLog(@"$%.02f",[amount floatValue]);
                                    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[smsPlanArray count]] intValue];
                                    float oneSlotSize = (CGRectGetWidth(imgBGSMS.frame))/(itemCount);
                                    imgProgressSMS.frame = CGRectMake(imgProgressSMS.frame.origin.x, imgProgressSMS.frame.origin.y, oneSlotSize*(z+1), 15);
                                    NSMutableDictionary *dictValue = [smsPlanArray objectAtIndex:z];
                                    amountSMS = [dictValue objectForKey:@"planamount"];
                                    personSMS = [[dictValue objectForKey:@"id"] intValue];
                                    selectedSMS = z+1;
                                }
                            }
                        }
                        else if ([name_text isEqualToString:@"Data"]){
                            for (int z=0; [dataPlanArray count] > z; z++) {
                                NSString * dataID = [[dataPlanArray objectAtIndex:z] objectForKey:@"id"];
                                if ([dataID isEqualToString:planId]) {
                                    NSString * amount = [[dataPlanArray objectAtIndex:z] objectForKey:@"planamount"];
                                    NSLog(@"Name: %@",name_text);
                                    NSLog(@"$%.02f",[amount floatValue]);
                                    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[dataPlanArray count]] intValue];
                                    float oneSlotSize = (CGRectGetWidth(imgBGData.frame))/(itemCount);
                                    imgProgressData.frame = CGRectMake(imgProgressData.frame.origin.x, imgProgressData.frame.origin.y, oneSlotSize*(z+1), 15);
                                    NSMutableDictionary *dictValue = [dataPlanArray objectAtIndex:z];
                                    amountData = [dictValue objectForKey:@"planamount"];
                                    personData = [[dictValue objectForKey:@"id"] intValue];
                                    selectedData = z+1;
                                }
                            }
                        }
                        else if ([name_text isEqualToString:@"Intl Voice"]){
                            if (pending_fkbundleid < 1){
                                for (int z=0; [intlPlanArray count] > z; z++) {
                                    NSString * intlID = [[intlPlanArray objectAtIndex:z] objectForKey:@"id"];
                                    if ([intlID isEqualToString:planId]) {
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
            }
        }
        return strTotalPrice;
    }
    return @"";
}

- (void) getBundlePlans {
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api_dev/getbundles2/%@",missingID];
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
        NSMutableArray *arrayBundles = [dictData objectForKey:@"bundles"];
        arrayUnliBundles = [[NSMutableArray alloc]init];
        for (int i=0; [arrayBundles count] > i; i++) {
            [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
        }
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setValue:@"0.0" forKey:@"amount"];
        [tempDict setValue:@"0GB" forKey:@"description"];
        [tempDict setValue:@"4G" forKey:@"sim_type"];
        [arrayUnliBundles insertObject:tempDict atIndex:0];
        
        [segmentControl setSelectedSegmentIndex:1];
        newTotalPrice = [amountUnli floatValue] + [amountIntl floatValue];
    }
}

-(void) getMBBPlans{
    //NSString * strPortalURL = @"https://yomojo.com.au/dev/api/getbroadbandplans2";
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api_dev/getbroadbandplans2/%@",missingIDMBB];
    
    if (pending_fkbundleid >= 0) {
        strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api_dev/getbroadbandplans2/%d",pending_fkbundleid];
    }
    else{
        strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api_dev/getbroadbandplans2/%@",missingID];
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
        [self getCurrentPlanPrice];
    }
}

-(void) getProductPlans{
    //NSString * strPortalURL = @"https://yomojo.com.au/dev/api/getproductplans/0";
    NSString * strPortalURL = @"https://yomojo.com.au/api_dev/getproductplans2";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
    if (!error) {
        //NSString *responseData = [[NSString alloc]initWithData:dataFromURL encoding:NSUTF8StringEncoding];
        //NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        productplans = [[NSMutableDictionary alloc] init];
        productplans = [dictData objectForKey:@"productplans"];
        
        //voicePlanArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *resultRP9 = [productplans objectForKey:@"RP9"];
        NSArray *voicePlanID = [resultRP9 allKeys];
        NSMutableArray* voicePlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [voicePlanID count]; i++) {
            NSMutableDictionary * rp9IDValue = [[NSMutableDictionary alloc] init];
            rp9IDValue = [resultRP9 objectForKey:[voicePlanID objectAtIndex:i]];
            [voicePlanArrayMutable addObject:rp9IDValue];
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"slider"  ascending:YES];
        voicePlanArray = [voicePlanArrayMutable sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        smsPlanArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *resultRP13 = [productplans objectForKey:@"RP13"];
        NSArray *smsPlanID = [resultRP13 allKeys];
        NSMutableArray* smsPlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [smsPlanID count]; i++) {
            NSMutableDictionary * rp13IDValue = [[NSMutableDictionary alloc] init];
            rp13IDValue = [resultRP13 objectForKey:[smsPlanID objectAtIndex:i]];
            [smsPlanArrayMutable addObject:rp13IDValue];
        }
        smsPlanArray = [smsPlanArrayMutable sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        dataPlanArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *resultRP12 = [productplans objectForKey:@"RP12"];
        NSArray *dataPlanID = [resultRP12 allKeys];
        NSMutableArray* dataPlanArrayMutable = [[NSMutableArray alloc]init];
        for (int i=0; i < [dataPlanID count]; i++) {
            NSMutableDictionary * rp12IDValue = [[NSMutableDictionary alloc] init];
            rp12IDValue = [resultRP12 objectForKey:[dataPlanID objectAtIndex:i]];
            [dataPlanArrayMutable addObject:rp12IDValue];
        }
        dataPlanArray = [dataPlanArrayMutable sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
        
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
    //NSString *name_text = [productDict objectForKey:@"name_text"];
    //NSDate *productplanexpiry = [dateFormatter dateFromString:productExpiry];
    
    NSDate *currDate = [NSDate date];
    NSString *strCurrDate = [dateFormatter stringFromDate:currDate];
    //NSDate *dateCurrDate = [dateFormatter dateFromString:strCurrDate];
    
    [productPlanArray addObject:productDict];
    
//    for (int i=0; i < [productPlanArray count]; i++) {
//        NSMutableDictionary *arrayContent = [productPlanArray objectAtIndex:i];
//        //NSString *Pid = [arrayContent objectForKey:@"id"];
//        NSString *nameText = [arrayContent objectForKey:@"name_text"];
//        NSString *strExpiry = [arrayContent objectForKey:@"expiry"];
//        NSString *strPending = [arrayContent objectForKey:@"pending"];
//        NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
//        dateFormatter1.dateFormat = @"dd-MM-yyyy";
//        NSDate *expiry = [dateFormatter1 dateFromString:strExpiry];
//        if ([name_text isEqualToString: nameText]) {
//            if ([productplanexpiry compare:expiry] == NSOrderedDescending) {
////                if (![strPending  isEqual: @""]){
////                    //[productPlanArray removeObjectAtIndex: i];
////                    [productPlanArray insertObject:productDict atIndex:i];
////                }
////                else{
//                    [productPlanArray removeObjectAtIndex: i];
//                    [productPlanArray insertObject:productDict atIndex:i];
////                }
//                num = 1;
//            }
//            if ([productplanexpiry compare:expiry] == NSOrderedAscending) {
//                num = 1;
//            }
//            if ([productplanexpiry compare:expiry] == NSOrderedSame) {
//                num = 1;
//            }
//        }
//    }
//    if (num == 0){
//        if ([productplanexpiry compare:dateCurrDate] == NSOrderedDescending) {
//            [productPlanArray addObject:productDict];
//        }
//    }
    NSLog(@"productPlanArray: %@",productPlanArray);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)segmentSelected:(id)sender {
    if (segmentControl.selectedSegmentIndex == 0) {
        tableViewUnli.hidden = YES;
        tableViewNextMonth.hidden = NO;
        newTotalPrice = 0.0;
        newTotalPrice = [amountVoice floatValue] + [amountSMS floatValue] + [amountIntl floatValue] + [amountData floatValue];
       // [tableViewNextMonth reloadData];
    }
    else if(segmentControl.selectedSegmentIndex == 1) {
        tableViewUnli.hidden = NO;
        tableViewNextMonth.hidden = YES;
        newTotalPrice = 0.0;
        newTotalPrice = [amountUnli floatValue] + [amountIntl floatValue];
        //[tableViewUnli reloadData];
    }
}

- (UIImage*) drawTextName:(NSString*) text inImage:(UIImage*) myImage atPoint:(CGPoint) point {
    UIGraphicsBeginImageContext(myImage.size);
    [myImage drawInRect:CGRectMake(0, 10, 100, 50)];
    UITextView *myText = [[UITextView alloc] init];
    myText.frame = CGRectMake(0,10,100,50);
    myText.text = text;
    myText.font = [UIFont fontWithName:@"Arial" size:20.0f];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName: myText.font,NSParagraphStyleAttributeName: paragraphStyle};
    [myText.text drawInRect:myText.frame withAttributes:attributes];
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    return myNewImage;
}

- (void) btnCancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnMenu:(id)sender {
    //[self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnChat:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yomojo.com.au/chat"]];
}

- (IBAction)btnCallNumber:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:1300966656"]];
}

- (IBAction)actionSliderVoice:(SEFilterControl *) sender{
    if (sender.selectedIndex == 0){
        amountVoice = @"0";
        personVoice = 0;
    }
    else{
        NSMutableDictionary *dictValue = [voicePlanArray objectAtIndex:sender.selectedIndex - 1];
        amountVoice = [dictValue objectForKey:@"planamount"];
        personVoice = [[dictValue objectForKey:@"id"] intValue];
    }

    selectedVoice = sender.selectedIndex;
    NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:0];
    ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountVoice];
    
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[voicePlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    float oneSlotSize = (CGRectGetWidth(imgBG.frame))/ itemCount;
    imgProgressVoice.frame = CGRectMake(imgProgressVoice.frame.origin.x, imgProgressVoice.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
    
    newTotalPrice = [amountVoice floatValue] + [amountSMS floatValue] + [amountIntl floatValue] + [amountData floatValue];
    NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
    a = [NSIndexPath indexPathForRow:0 inSection:4];
    cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblNextMonthTotal.text = strTotalPrice;
    //cell.lblThisMonthTotal.text = [self getCurrentPlanPrice];
}


- (IBAction)actionSliderSMS:(SEFilterControl *) sender{
    if (sender.selectedIndex == 0){
        amountSMS = @"0";
        personSMS =0;
    }
    else{
        NSMutableDictionary *dictValue = [smsPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountSMS = [dictValue objectForKey:@"planamount"];
        personSMS = [[dictValue objectForKey:@"id"] intValue];
    }
    selectedSMS = sender.selectedIndex;
    
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[smsPlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    float oneSlotSize = (CGRectGetWidth(imgBGSMS.frame))/itemCount;
    imgProgressSMS.frame = CGRectMake(imgProgressSMS.frame.origin.x, imgProgressSMS.frame.origin.y, oneSlotSize *selectedSMS, 15);
    
    NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:1];
    ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountSMS];;
    newTotalPrice = [amountVoice floatValue] + [amountSMS floatValue] + [amountIntl floatValue] + [amountData floatValue];
    
    NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
    a = [NSIndexPath indexPathForRow:0 inSection:4];
    cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblNextMonthTotal.text = strTotalPrice;
    //cell.lblThisMonthTotal.text = [self getCurrentPlanPrice];
}

- (IBAction)actionSliderData:(SEFilterControl *) sender{
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[dataPlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    float oneSlotSize = (CGRectGetWidth(imgBGData.frame))/itemCount;
    imgProgressData.frame = CGRectMake(imgProgressData.frame.origin.x, imgProgressData.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
    
    if (sender.selectedIndex == 0){
        amountData = @"0";
        personData = 0;
    }
    else{
        NSMutableDictionary *dictValue = [dataPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountData = [dictValue objectForKey:@"planamount"];
        personData = [[dictValue objectForKey:@"id"] intValue];
    }
    selectedData = sender.selectedIndex;
    NSIndexPath *a = nil;
    a = [NSIndexPath indexPathForRow:0 inSection:2];
    ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountData];;
    newTotalPrice = [amountVoice floatValue] + [amountSMS floatValue] + [amountIntl floatValue] + [amountData floatValue];
    NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
    
    a = [NSIndexPath indexPathForRow:0 inSection:4];
    cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
    cell.lblNextMonthTotal.text = strTotalPrice;
    //cell.lblThisMonthTotal.text = [self getCurrentPlanPrice];
}

- (IBAction)actionSliderIntl:(SEFilterControl *) sender{
//    if (segmentControl.selectedSegmentIndex == 0){
//        int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
//        if (itemCount == 0)
//            itemCount = 5;
//
//        float oneSlotSize = (CGRectGetWidth(imgBGIntl.frame))/itemCount;
//        imgProgressIntl.frame = CGRectMake(imgProgressIntl.frame.origin.x, imgProgressIntl.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
//
//        if (sender.selectedIndex == 0){
//            amountIntl = @"0";
//            personIntl = 0;
//        }
//        else{
//            NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:sender.selectedIndex - 1];
//            amountIntl = [dictValue objectForKey:@"planamount"];
//            personIntl = [[dictValue objectForKey:@"id"] intValue];
//        }
//        selectedIntl = sender.selectedIndex;
//
//        NSIndexPath *a = nil;
//        a = [NSIndexPath indexPathForRow:0 inSection:3];
//        ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
//        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountIntl];
//        newTotalPrice = [amountVoice floatValue] + [amountSMS floatValue] + [amountIntl floatValue] + [amountData floatValue];
//
//        NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
//        a = [NSIndexPath indexPathForRow:0 inSection:4];
//        cell = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:a];
//        cell.lblNextMonthTotal.text = strTotalPrice;
//        //cell.lblThisMonthTotal.text = [self getCurrentPlanPrice];
//    }
//    else if (segmentControl.selectedSegmentIndex == 1){
        int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
        if (itemCount == 0)
            itemCount = 5;
        
        //float oneSlotSize = (CGRectGetWidth(imgBGIntlUnli.frame))/itemCount;
        //imgProgressIntlUnli.frame = CGRectMake(imgProgressIntlUnli.frame.origin.x, imgProgressIntlUnli.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
        
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
        
        NSIndexPath *a = nil;
        a = [NSIndexPath indexPathForRow:0 inSection:2];
        ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:a];
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountIntl];
        
        float totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
        
        if ((pending_fkbundleid > 0) && (initialLoadIntl < 2)) {
            totalPrice  = [amountIntl floatValue] + [amountUnliPending floatValue];
        }
        else{
            totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
        }
    
        initialLoadIntl =  initialLoadIntl + 1;
        
        NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", totalPrice];
        NSIndexPath *b = nil;
        b = [NSIndexPath indexPathForRow:0 inSection:3];
        cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:b];
        cell.lblNextMonthTotal.text = strTotalPrice;
    //}
}

- (IBAction)actionSliderUnli:(SEFilterControl *) sender{
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[arrayUnliBundles count]] intValue];
    float oneSlotSize = (CGRectGetWidth(imgBGUnli.frame))/(itemCount - 1);

        if (sender.selectedIndex == 0) {
            imgProgressUnli.frame = CGRectMake(imgProgressUnli.frame.origin.x, imgProgressUnli.frame.origin.y, oneSlotSize*(sender.selectedIndex +1), 15);
            NSMutableDictionary *dictValue = [[NSMutableDictionary alloc]init];
            dictValue = [arrayUnliBundles objectAtIndex:(sender.selectedIndex + 1)];
            amountUnli = [dictValue objectForKey:@"amount"];
            unliData = [[dictValue objectForKey:@"id"] intValue];
            selectedUnli = sender.selectedIndex + 1;
            [sender setSelectedIndex:selectedUnli animated:YES];
        }
        else{
            imgProgressUnli.frame = CGRectMake(imgProgressUnli.frame.origin.x, imgProgressUnli.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
            NSMutableDictionary *dictValue = [[NSMutableDictionary alloc]init];
            dictValue = [arrayUnliBundles objectAtIndex:sender.selectedIndex];
            amountUnli = [dictValue objectForKey:@"amount"];
            unliData = [[dictValue objectForKey:@"id"] intValue];
            selectedUnli = sender.selectedIndex;
           // [sender setSelectedIndex:selectedUnli animated:YES];
        }
    
        NSIndexPath *a = nil;
        a = [NSIndexPath indexPathForRow:0 inSection:1];
        ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:a];
        cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f",[amountUnli floatValue]];
    
        float totalPrice = [amountUnli floatValue] + [amountIntl floatValue];
    
        if ((pending_fkbundleid >=0) && (initalLoadUnli <= 1)){
            totalPrice  = [amountIntl floatValue] + [amountUnliPending floatValue];
            initalLoadUnli = initalLoadUnli + 1;
        }
        else{
            totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
        }
    
        NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", totalPrice];
        NSIndexPath *b = nil;
        b = [NSIndexPath indexPathForRow:0 inSection:3];
        cell = (ChangePlanNextMonthTableViewCell *)[tableViewUnli cellForRowAtIndexPath:b];
        cell.lblNextMonthTotal.text = strTotalPrice;
        cell.lbl3GLabel.hidden = [self checkIf4G:selectedUnli];
        cell.lblFullPrice.hidden = NO;
}

- (BOOL) checkIf4G:(NSInteger)selectedIndex {
    NSMutableDictionary* jsonRes = [arrayUnliBundles objectAtIndex:selectedIndex];
    NSString * sim_type = [jsonRes objectForKey:@"sim_type"];
    if (sim_type) {
        if ([sim_type isEqual: @"3G"]) {
            return 0;
        }
    }
    return 1;
}


- (IBAction)actionSliderMBB:(SEFilterControl *) sender{
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[mbbPlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    
    if (sender.selectedIndex == 0) {
        float oneSlotSize = (CGRectGetWidth(imgBGMBB.frame))/itemCount;
        imgProgressMBB.frame = CGRectMake(imgProgressMBB.frame.origin.x, imgProgressMBB.frame.origin.y, oneSlotSize*(sender.selectedIndex  + 1), 15);
        NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:(sender.selectedIndex)] ;
        amountMBB = [dictValue objectForKey:@"planamount"];
        mbbBundle = [[dictValue objectForKey:@"id"] intValue];
        selectedMBB = sender.selectedIndex + 1;
        [sender setSelectedIndex:selectedMBB animated:YES];
    }
    else{
        float oneSlotSize = (CGRectGetWidth(imgBGMBB.frame))/itemCount;
        imgProgressMBB.frame = CGRectMake(imgProgressMBB.frame.origin.x, imgProgressMBB.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
        NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountMBB = [dictValue objectForKey:@"planamount"];
        mbbBundle = [[dictValue objectForKey:@"id"] intValue];
        selectedMBB = sender.selectedIndex;
    }

//    if (sender.selectedIndex == 0){
//        amountMBB = @"0";
//        mbbBundle = 0;
//    }
//    else{
//        NSMutableDictionary *dictValue = [mbbPlanArray objectAtIndex:sender.selectedIndex - 1];
//        amountMBB = [dictValue objectForKey:@"planamount"];
//        mbbBundle = [[dictValue objectForKey:@"id"] intValue];
//    }
    //selectedMBB = sender.selectedIndex;
    NSIndexPath *a = [NSIndexPath indexPathForRow:0 inSection:0];
    ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:a];
    newTotalPrice = [amountMBB floatValue];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f",newTotalPrice];

    a = [NSIndexPath indexPathForRow:0 inSection:1];
    cell = (ChangePlanNextMonthTableViewCell *)[tableViewMBB cellForRowAtIndexPath:a];
    cell.lblNextMonthTotal.text = [NSString stringWithFormat:@"$%.02f*",newTotalPrice];
    //cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", mbbThisMonthTotal];
}

-(void) btnSavePlan:(id)sender{
    //    [15/06/2016, 2:40:33 PM] Ederley Ting-o: https://yomojo.com.au/api/computeplan/$plantype/$clientid/$phoneid/$unlidata/$unliintl/$unlitopup/$personvoice/$personsms/$persondata/$personintl/$persontopup/$session_var
    //    [15/06/2016, 2:41:05 PM] Ederley Ting-o: https://yomojo.com.au/api/getproductplans
    //    [15/06/2016, 2:41:16 PM] Ederley Ting-o: https://yomojo.com.au/api/getbundles
    //      https://yomojo.com.au/dev/api/getbroadbandplans
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
    
    NSString * planType = @"unlimited";
    float baseAmountUnli = 19.90;

    if ([planID  isEqual: @"5"]) {
        unliData = -1;
        unliIntl = -1;
        unliTopup = -1;
        personVoice = -1;
        personSMS = -1;
        personData = -1;
        personTopup = -1;
        personIntl = -1;
        //amountMBB = @"-1";
        planType = @"broadband";
    }
    else {
        amountMBB = @"-1";
        personVoice = -1;
        personSMS = -1;
        personData = -1;
        personTopup = -1;
        personIntl = -1;
        //amountIntl = @"0";
        amountVoice = @"-1";
        amountSMS = @"-1";
        amountData = @"-1";
        amountMBB = @"-1";
        float totalPriceUnli = [amountUnli floatValue] - baseAmountUnli;
        amountUnli = [NSString stringWithFormat:@"%.02f",totalPriceUnli];
        planType = @"unlimited";
    }
    
    unliTopup = -1;
    personTopup = -1;
    
    if ([amountUnli isEqual: @"0"] || [amountUnli isEqual: @"(null)"])
        amountUnli = @"-1";
    
    if ([amountIntl isEqual: @"0"])
        amountIntl = @"-1";
    
    if (unliTopup == 0)
        unliTopup = -1;

    if ([amountVoice  isEqual: @"0"])
        amountVoice = @"-1";
    
    if ([amountSMS  isEqual: @"0"])
        amountSMS = @"-1";
    
    if ([amountData  isEqual: @"0"])
        amountData = @"-1";
    
    if ([amountIntl  isEqual: @"0"])
        amountIntl = @"-1";
    
    if (personTopup == 0)
        personTopup = -1;
    
    if ([amountMBB  isEqual: @"0"] || [amountMBB isEqual: @"(null)"])
        amountMBB = @"-1";
    
    if (!amountMBB){
        amountMBB = @"-1";
    }
    
    personIntl = -1;
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api_dev/computeplan2?unlibundleid=%d&plantype=%@&phoneid=%@&clientid=%@&unlidata=%@&unliintl=%@&unlitopup=%d&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=-1&broadbanddata=%@&session_var=%@",unliData, planType, phoneID, clientID, amountUnli, amountIntl, unliTopup, amountMBB, sessionID];
    
    //https://yomojo.com.au/api_dev/computeplan2?unlibundleid=27&plantype=unlimited&phoneid=68869&clientid=660614&unlidata=10.00&unliintl=10.00&unlitopup=-1&personvoice=-1&personsms=-1&persondata=-1&personintl=-1&persontopup=-1&broadbanddata=-1&session_var=2B9ED7E9BA204F163FFE06BC40D4CF18D442CA7686189569506D1CECFB25801EDE7EDA587BB160C8876510CBDE1FB7B5
    
    
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
            [self callURLGetPhoneDetails];
            [self alertStatus:@"Change Plan successful!" : @"Success"];
        }
    }
}

- (void) callURLGetPhoneDetails {
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    NSString *clientID = [responseDict objectForKey:@"CLIENTID"];
    NSString *sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    int phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
    NSString *phoneID = [phoneDetails objectForKey:@"id"];
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/get_phone_details/%@/%@/%@",phoneID, clientID,sessionID];
    NSLog(@"urlString:%@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSMutableDictionary *dictDataNew = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        [userLogin setObject:dictDataNew forKey:@"getPhoneDetails"];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == tableViewNextMonth) {
        return 6;
    }
    else if (tableView == tableViewUnli) {
        return 5;
    }
    else if (tableView == tableViewMBB){
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    ChangePlanNextMonthTableViewCell *cell = (ChangePlanNextMonthTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChangePlanNextMonthTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (tableView == tableViewNextMonth) {
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
//        if (indexPath.section == 0){
//            NSMutableArray *valueSelectionVoice = [[NSMutableArray alloc]init];
//            for (int i=0; [voicePlanArray count] > i; i++) {
//                if (i == 0) {
//                    [valueSelectionVoice addObject: @"0"];
//                }
//                NSString * titleLabel = [[voicePlanArray objectAtIndex:i] objectForKey:@"planname"];
//                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"National Voice " withString:@""];
//                [valueSelectionVoice addObject: titleLabel];
//            }
//            imgBG =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
//            [imgBG setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
//            imgProgressVoice =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
//            [imgProgressVoice setBackgroundColor:[self colorFromHexString:@"#E1044F"]];
//            SEFilterControl* filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionVoice];
//            [filter addTarget:self action:@selector(actionSliderVoice:) forControlEvents:UIControlEventValueChanged];
//            //filter.progressColor = [UIColor grayColor];
//            filter.progressColor = [self colorFromHexString:@"#E1044F"];
//            [filter setSelectedIndex:selectedVoice animated:YES];
//            [cell addSubview:imgBG];
//            [cell addSubview:imgProgressVoice];
//            [cell addSubview:filter];
//
//            cell.lblPackName.text = @"Voice pack";
//            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_voice"]];
//            cell.lblUnit.text = @"Minutes";
//            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountVoice];
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = YES;
//            cell.btnCancel.hidden = YES;
//        }
//        else if (indexPath.section ==  1){
//            NSMutableArray *valueSelectionSMS = [[NSMutableArray alloc]init];
//            for (int i=0; [smsPlanArray count] > i; i++) {
//                if (i == 0) {
//                    [valueSelectionSMS addObject: @"0"];
//                }
//                NSString * titleLabel = [[smsPlanArray objectAtIndex:i] objectForKey:@"planname"];
//                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"National SMS " withString:@""];
//                [valueSelectionSMS addObject: titleLabel];
//            }
//            imgBGSMS =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
//            [imgBGSMS setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
//            imgProgressSMS =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
//            [imgProgressSMS setBackgroundColor:[self colorFromHexString:@"#FF4505"]];
//            SEFilterControl* filterSMS = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionSMS];
//            [filterSMS addTarget:self action:@selector(actionSliderSMS:) forControlEvents:UIControlEventValueChanged];
//            filterSMS.progressColor = [self colorFromHexString:@"#FF4505"];
//            [filterSMS setSelectedIndex:selectedSMS animated:YES];
//            [cell addSubview:imgBGSMS];
//            [cell addSubview:imgProgressSMS];
//            [cell addSubview:filterSMS];
//            cell.lblPackName.text = @"SMS pack";
//            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_sms"]];
//            cell.lblUnit.text = @"SMS";
//            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountSMS];
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = YES;
//            cell.btnCancel.hidden = YES;
//        }
//        else if (indexPath.section == 2){
//            NSMutableArray *valueSelectionData = [[NSMutableArray alloc]init];
//            for (int i=0; [dataPlanArray count] > i; i++) {
//                if (i == 0) {
//                    [valueSelectionData addObject: @"0"];
//                }
//                NSString * titleLabel = [[dataPlanArray objectAtIndex:i] objectForKey:@"planname"];
//                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"National Data " withString:@""];
//                [valueSelectionData addObject: titleLabel];
//            }
//            imgBGData =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
//            [imgBGData setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
//            imgProgressData =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
//            [imgProgressData setBackgroundColor:[self colorFromHexString:@"#FF9005"]];
//            SEFilterControl* filterData = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionData];
//            [filterData addTarget:self action:@selector(actionSliderData:) forControlEvents:UIControlEventValueChanged];
//            filterData.progressColor = [self colorFromHexString:@"#FF9005"];
//            [filterData setSelectedIndex:selectedData animated:YES];
//            [cell addSubview:imgBGData];
//            [cell addSubview:imgProgressData];
//            [cell addSubview:filterData];
//            cell.lblPackName.text = @"Data pack";
//            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_data"]];
//            cell.lblUnit.text = @"GB";
//            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountData];
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = YES;
//            cell.btnCancel.hidden = YES;
//        }
//        else if (indexPath.section == 3){
//            NSMutableArray *valueSelectionIntl = [[NSMutableArray alloc]init];
//            for (int i=0; [intlPlanArray count] > i; i++) {
//                if (i == 0) {
//                    [valueSelectionIntl addObject: @"0"];
//                }
//                NSString * titleLabel = [[intlPlanArray objectAtIndex:i] objectForKey:@"planname"];
//                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"International Voice " withString:@""];
//                [valueSelectionIntl addObject: titleLabel];
//            }
//            imgBGIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
//            [imgBGIntl setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
//            imgProgressIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
//            [imgProgressIntl setBackgroundColor:[self colorFromHexString:@"#888888"]];
//            SEFilterControl* filterIntl = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionIntl];
//            [filterIntl addTarget:self action:@selector(actionSliderIntl:) forControlEvents:UIControlEventValueChanged];
//            filterIntl.progressColor = [self colorFromHexString:@"#888888"];
//            [filterIntl setSelectedIndex:selectedIntl animated:YES];
//            [cell addSubview:imgBGIntl];
//            [cell addSubview:imgProgressIntl];
//            [cell addSubview:filterIntl];
//            cell.lblPackName.text = @"Intl pack";
//            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_intl"]];
//            cell.lblUnit.text = @"Minutes";
//            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountIntl];
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = YES;
//            cell.btnCancel.hidden = YES;
//        }
//        else if (indexPath.section == 4){
//            cell.lblPackName.text = @"";
//            [cell.imgIcon setImage:nil];
//            cell.lblUnit.text = @"";
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = YES;
//            cell.btnCancel.hidden = YES;
//            cell.viewPrice.hidden = NO;
//            NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
//            cell.lblNextMonthTotal.text = strTotalPrice;
//
//            if (initialLoadPersonal <= 2) {
//                //cell.lblThisMonthTotal.text = strTotalPrice;
//                cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", strTotalPrice];
//                initialLoadPersonal = initialLoadPersonal + 1;
//
//                NSIndexPath *c = nil;
//                c = [NSIndexPath indexPathForRow:0 inSection:4];
//                ChangePlanNextMonthTableViewCell *cellC = (ChangePlanNextMonthTableViewCell *)[tableViewNextMonth cellForRowAtIndexPath:c];
//                //cellC.lblThisMonthTotal.text = strTotalPrice;
//                cellC.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", strTotalPrice];
//            }
//        }
//        else if (indexPath.section == 5){
//            cell.lblPackName.text = @"";
//            [cell.imgIcon setImage:nil];
//            cell.lblUnit.text = @"";
//            cell.imgUnliVoiceSMS.hidden = YES;
//            cell.btnSaveAndContinue.hidden = NO;
//            cell.btnCancel.hidden = NO;
//            cell.lblPrice.text = @"";
//            cell.viewPrice.hidden = YES;
//            [cell.btnSaveAndContinue addTarget:self action:@selector(btnSavePlan:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.btnCancel addTarget:self action:@selector(btnCancel:) forControlEvents:UIControlEventTouchUpInside];
//        }
    }
    else if (tableView == tableViewUnli) {
        NSString *unliPrice = @"0";
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        if (indexPath.section == 0){
            cell.imgUnliVoiceSMS.hidden = NO;
            cell.btnSaveAndContinue.hidden = YES;
            cell.lbl3GLabel.hidden = YES;
            cell.lblFullPrice.hidden = YES;
        }
        if (indexPath.section == 1){
            NSMutableArray *valueSelectionData = [[NSMutableArray alloc]init];
            for (int i=0; [arrayUnliBundles count] > i; i++) {
                NSString * titleLabel = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"description"];
                NSString * sim_type = [[arrayUnliBundles objectAtIndex:i] objectForKey:@"sim_type"];
                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"Unlimited Voice & SMS & " withString:@""];
                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @" Data" withString:@""];
                if (sim_type) {
                    if ([sim_type isEqual: @"3G"]) {
                        titleLabel = [NSString stringWithFormat:@"%@#",titleLabel];
                    }
                }
                [valueSelectionData addObject: titleLabel];
            }
            imgBGUnli =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
            [imgBGUnli setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
            imgProgressUnli =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
            [imgProgressUnli setBackgroundColor:[self colorFromHexString:@"#FF9005"]];
            SEFilterControl* filterData = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionData];
            [filterData addTarget:self action:@selector(actionSliderUnli:) forControlEvents:UIControlEventValueChanged];
            filterData.progressColor = [self colorFromHexString:@"#FF9005"];
            [filterData setSelectedIndex:selectedUnli animated:YES];
            [cell addSubview:imgBGUnli];
            [cell addSubview:imgProgressUnli];
            [cell addSubview:filterData];
            cell.lblPackName.text = @"Data pack";
            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_data"]];
            cell.lblUnit.text = @"GB";

            if (pending_fkbundleid > 0)  {
                unliPrice = [NSString stringWithFormat:@"%.02f",[amountUnliPending floatValue]];
            }
            else{
                unliPrice = [NSString stringWithFormat:@"%.02f",[amountUnli floatValue]];
            }
            
            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",unliPrice];
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = YES;
            cell.btnCancel.hidden = YES;
            cell.lbl3GLabel.hidden = YES;
            cell.lblFullPrice.hidden = YES;
        }
        if (indexPath.section == 2){
            NSMutableArray *valueSelectionIntl = [[NSMutableArray alloc]init];
            for (int i=0; [intlPlanArray count] > i; i++) {
                if (i == 0) {
                    [valueSelectionIntl addObject: @"0"];
                }
                NSString * titleLabel = [[intlPlanArray objectAtIndex:i] objectForKey:@"planname"];
                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"International Voice " withString:@""];
                [valueSelectionIntl addObject: titleLabel];
            }
            imgBGIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
            [imgBGIntl setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
            imgProgressIntl =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
            [imgProgressIntl setBackgroundColor:[self colorFromHexString:@"#888888"]];
            SEFilterControl* filterIntl = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth, 50) titles:valueSelectionIntl];
            [filterIntl addTarget:self action:@selector(actionSliderIntl:) forControlEvents:UIControlEventValueChanged];
            filterIntl.progressColor = [self colorFromHexString:@"#888888"];
            [filterIntl setSelectedIndex:selectedIntl animated:YES];
            [cell addSubview:imgBGIntl];
            [cell addSubview:imgProgressIntl];
            [cell addSubview:filterIntl];
            cell.lblPackName.text = @"Intl pack";
            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_intl"]];
            cell.lblUnit.text = @"Minutes";
            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountIntl];
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = YES;
            cell.btnCancel.hidden = YES;
            cell.lbl3GLabel.hidden = YES;
            cell.lblFullPrice.hidden = YES;
        }
        if (indexPath.section == 3){
            cell.lblPackName.text = @"";
            [cell.imgIcon setImage:nil];
            cell.lblUnit.text = @"";
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = YES;
            cell.btnCancel.hidden = YES;
            cell.viewPrice.hidden = NO;
            float strTotalPrice = 0.0;
            if (pending_fkbundleid > 0) {
                strTotalPrice = [amountUnliPending floatValue] + [amountIntl floatValue];
            }
            else{
                strTotalPrice = [amountUnli floatValue] + [amountIntl floatValue];
            }
            cell.lblNextMonthTotal.text = [NSString stringWithFormat:@"$%.02f*",strTotalPrice];
            cell.lblFullPrice.hidden = NO;
            
            float floatThisMonthtotalPrice = [thisMonthAmountUnli floatValue] + [[self getThisMonthPriceForIntl] floatValue] + [amountVoice floatValue] + [amountSMS floatValue] + [amountData floatValue];
            NSString *strFullTotalPrice = [NSString stringWithFormat:@"$%.02f", floatThisMonthtotalPrice];
            cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"%@*", strFullTotalPrice];
            
        }
        if (indexPath.section == 4){
            cell.lblPackName.text = @"";
            [cell.imgIcon setImage:nil];
            cell.lblUnit.text = @"";
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = NO;
            cell.btnCancel.hidden = NO;
            cell.lblPrice.text = @"";
            //cell.lbl3GLabel.hidden = YES;
            cell.lbl3GLabel.hidden = [self checkIf4G:selectedUnli];
            cell.lblFullPrice.hidden = NO;
            [cell.btnSaveAndContinue addTarget:self action:@selector(btnSavePlan:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(btnCancel:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    if (tableView == tableViewMBB){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        if (indexPath.section == 0){
            NSMutableArray *valueSelectionMBB = [[NSMutableArray alloc]init];
            for (int i=0; [mbbPlanArray count] > i; i++) {
                if (i == 0) {
                    [valueSelectionMBB addObject: @"0"];
                }
                NSString * titleLabel = [[mbbPlanArray objectAtIndex:i] objectForKey:@"planname"];
                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @"MBB Data " withString:@""];
                titleLabel =[titleLabel stringByReplacingOccurrencesOfString: @" High" withString:@""];
                [valueSelectionMBB addObject: titleLabel];
            }
            
            imgBGMBB =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, screenWidth-45, 16)];
            [imgBGMBB setBackgroundColor:[self colorFromHexString:@"#E7E7E7"]];
            
            imgProgressMBB =[[UIImageView alloc] initWithFrame:CGRectMake(20, 77, 0, 16)];
            [imgProgressMBB setBackgroundColor:[self colorFromHexString:@"#888888"]];
            
            SEFilterControl* filterMBB = [[SEFilterControl alloc]initWithFrame:CGRectMake(5, 50, screenWidth -5, 50) titles:valueSelectionMBB];
            [filterMBB addTarget:self action:@selector(actionSliderMBB:) forControlEvents:UIControlEventValueChanged];
            
            filterMBB.progressColor = [self colorFromHexString:@"#888888"];
            [filterMBB setSelectedIndex:selectedMBB animated:YES];

            [cell addSubview:imgBGMBB];
            [cell addSubview:imgProgressMBB];
            [cell addSubview:filterMBB];

            cell.lblPackName.text = @"Data pack";
            [cell.imgIcon setImage:[UIImage imageNamed:@"icon_data"]];
            cell.lblUnit.text = @"GB";
            cell.lblPrice.text = [NSString stringWithFormat:@"$%@",amountMBB];
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = YES;
            cell.btnCancel.hidden = YES;
        }
        else if (indexPath.section == 1){
            cell.lblPackName.text = @"";
            [cell.imgIcon setImage:nil];
            cell.lblUnit.text = @"";
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = YES;
            cell.btnCancel.hidden = YES;
            cell.viewPrice.hidden = NO;
            NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f*", newTotalPrice];
            cell.lblNextMonthTotal.text = strTotalPrice;
            cell.lblFullPrice.hidden = NO;
            cell.lblThisMonthTotal.text = [NSString stringWithFormat:@"$%.02f*", [[self getThisMonthPriceForMBB]floatValue]];
        }
        else if (indexPath.section == 2){
            cell.lblPackName.text = @"";
            [cell.imgIcon setImage:nil];
            cell.lblUnit.text = @"";
            cell.imgUnliVoiceSMS.hidden = YES;
            cell.btnSaveAndContinue.hidden = NO;
            cell.btnCancel.hidden = NO;
            cell.lblPrice.text = @"";
            cell.viewPrice.hidden = YES;
            [cell.btnSaveAndContinue addTarget:self action:@selector(btnSavePlan:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(btnCancel:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

@end
