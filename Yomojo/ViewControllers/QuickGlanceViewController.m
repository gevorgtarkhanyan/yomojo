//
//  QuickGlanceViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 11/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "QuickGlanceViewController.h"
#import "LoginViewController.h"
#import "XmlReader.h"
#import "QuickGlanceTableViewCell.h"
#import "Constants.h"

@interface QuickGlanceViewController ()

@end

@implementation QuickGlanceViewController
@synthesize urlData,phonesArray,lblNumber,phoneID,lblName,lblDueDate,productPlanArray, productPlan, MIMtableView, payg, pagingControl, validbolton, totalBoltON, resource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(doLogin) onTarget:self withObject:nil animated:YES];
}


-(BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currrentStatus = [reachability currentReachabilityStatus];
    return currrentStatus;
}

-(void) doLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        //NSString* username = [userLogin objectForKey:@"quickGlanceUsername"];
        //NSString* password = [userLogin objectForKey:@"quickGlancePassword"];
        int phonesArrayIndex = [[userLogin objectForKey:@"quickGlanceIndex"] intValue];
        
        if (phonesArrayIndex < 0) {
            phonesArrayIndex = 0;
        }
        self->phonesArray = [userLogin objectForKey:@"quickGlancePhoneArray"];
        self->urlData = [userLogin objectForKey:@"quickGlanceURLData"];
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:self->urlData options:NSJSONReadingMutableContainers error:nil];
        NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
        NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
        
        NSString *clientDetailsXML = [responseDict objectForKey:@"CLIENTDETAILS"];
        NSDictionary *XMLdict = [XMLReader dictionaryForXMLString:clientDetailsXML error:nil];
        NSDictionary *clientDict = [XMLdict objectForKey:@"client"];
        self->billday = [[clientDict objectForKey:@"billday"]objectForKey:@"text"];
        self->billday = [self->billday stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
        
        self->clientID = [responseDict objectForKey:@"CLIENTID"];
        self->sessionID = [responseDict objectForKey:@"SESSION_VAR"];
        
        
        NSString *strID = [userLogin objectForKey:@"quickGlanceStrID"];
        for (int i = 0; i < [self->phonesArray count]; i++) {
            NSDictionary *jsonData = [[NSDictionary alloc]init];
            jsonData = [self->phonesArray objectAtIndex:i];
            NSString *strIDFromPhonesArray = [jsonData objectForKey:@"id"];
            if ([strID intValue] == [strIDFromPhonesArray intValue]) {
                phonesArrayIndex = i;
            }
        }
        
        NSMutableDictionary *phoneDetails = [self->phonesArray objectAtIndex:phonesArrayIndex];
        
        self->phoneID = [phoneDetails objectForKey:@"id"];
        self->lblName.text = [phoneDetails objectForKey:@"label"];
        self->lblName.text = [self->lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
        
        NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
        
        if ([arrayPhoneNum count] <= 1) {
            self->lblNumber.text = [phoneDetails objectForKey:@"number"];
        } else {
            self->lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",
                                    [arrayPhoneNum objectAtIndex:0],
                                    [arrayPhoneNum objectAtIndex:1],
                                    [arrayPhoneNum objectAtIndex:2],
                                    [arrayPhoneNum objectAtIndex:3],
                                    [arrayPhoneNum objectAtIndex:4],
                                    [arrayPhoneNum objectAtIndex:5],
                                    [arrayPhoneNum objectAtIndex:6],
                                    [arrayPhoneNum objectAtIndex:7],
                                    [arrayPhoneNum objectAtIndex:8]];
        }
        
        NSString *expiry = [NSString stringWithFormat:@"%@",[phoneDetails objectForKey:@"expirydate"]];
        expiry = [expiry stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        expiry = [expiry stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dateFormatter.dateFormat = @"dd MMM yyyy";
        
        self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:self->HUB];
        [self->HUB showWhileExecuting:@selector(getPhoneDetails) onTarget:self withObject:nil animated:YES];
    });
}

- (void) getPhoneDetails {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/get_phone_details_v2/%@/%@/%@",PORTAL_URL, phoneID, clientID, sessionID];

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    __block NSMutableDictionary *resultData = [[NSMutableDictionary alloc]init];
    dispatch_async(dispatch_get_main_queue(), ^{
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        resultData = [dictData objectForKey:@"result"];
        
        self->validbolton = [resultData objectForKey:@"validbolton"];
        
        self->payg = [resultData objectForKey:@"payg"];
        int billingType = [[resultData objectForKey:@"billing_type"]intValue];
        
        //resource = [resultData objectForKey:@"resource"];
        
        if (billingType == 1) {
            self->lblDueDate.hidden = YES;
        }
        else{
            self->lblDueDate.hidden = NO;
        }
        self->lblDueDate.hidden = YES;

        if (billingType == 1) {
            self->lblDueDate.text = [NSString stringWithFormat:@"Prepaid Top-Up Credit: $%.02f",[[resultData objectForKey:@"balance"] floatValue]];
        }
        
        self->productPlan = [resultData objectForKey:@"productplan"];
        self->productPlanArray = [[NSMutableArray alloc]init];
        for (int i=0; i < [self->productPlan count]; i++) {
            NSMutableDictionary *productplanDict = [self->productPlan objectAtIndex:i];
            NSString *name_text = [productplanDict objectForKey:@"name_text"];
            if ([name_text  isEqual: @"Yomojo Voice"]) {
                NSLog(@"name_text: %@",name_text);
            } else{
                [self addToArray:productplanDict];
            }
        }
        
        NSMutableArray *bolton = [resultData objectForKey:@"bolton"];

        self->resource = [[NSMutableDictionary alloc] init];
        self->resource = [resultData objectForKey:@"resource"];
        
        float intBoltTotal = 0.0;
        for (int i=0; i < [bolton count]; i++) {
            NSMutableDictionary *boltOnData = [bolton objectAtIndex:i];
            NSString *RPCode =[boltOnData objectForKey:@"code"];
            if ([RPCode  isEqual: @"RP1"]) {
                int partition_incl_text = [[boltOnData objectForKey:@"partition_incl_text"] intValue];
                intBoltTotal = intBoltTotal + partition_incl_text;
            }
        }
        self->totalBoltON = intBoltTotal;
        
        [self sortArray];
        [self->MIMtableView reloadData];
        
        self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:self->HUB];
        [self->HUB showWhileExecuting:@selector(showQuickGlance) onTarget:self withObject:nil animated:YES];
    }
    });
}

- (void) showQuickGlance{

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

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}

- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender {
    [self showLoginView];
}

- (void)showLoginView {
    pagingControl.hidden = YES;
    LoginViewController *mvc = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToViewController:mvc animated:NO];
}


- (IBAction)btnLogin:(id)sender {
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) sortArray {
    NSMutableArray * tempPlanArray = [[NSMutableArray alloc] init];
    for (int i=0; i < [productPlanArray count]; i++) {
        NSMutableDictionary *jsonData = [productPlanArray objectAtIndex:i];
        NSString *name_text = [jsonData objectForKey:@"name_text"];
        if ([name_text  isEqual: @"Voice"]){
            [jsonData setObject:@"1" forKey:@"sortID"];
        }
        else if ([name_text  isEqual: @"SMS"]) {
            [jsonData setObject:@"2" forKey:@"sortID"];
        }
        else if ([name_text  isEqual: @"Intl Voice"]) {
            [jsonData setObject:@"3" forKey:@"sortID"];
        }
        else if ([name_text  isEqual: @"Data"]) {
            [jsonData setObject:@"4" forKey:@"sortID"];
        }
        else{
            [jsonData setObject:@"5" forKey:@"sortID"];
        }
        [tempPlanArray addObject:jsonData];
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortID" ascending:YES];
    NSArray *sortedArray=[tempPlanArray sortedArrayUsingDescriptors:@[sort]];
    productPlanArray = [sortedArray mutableCopy];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [productPlanArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *jsonData = [[NSDictionary alloc]init];
    jsonData = [productPlanArray objectAtIndex:indexPath.section];
    
    static NSString *simpleTableIdentifier = @"Cell";
    QuickGlanceTableViewCell *cell = (QuickGlanceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QuickGlanceTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (![jsonData  isEqual: @"temp"]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        NSString *expiry = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"expiry"]];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
        NSDate *yourDate = [dateFormatter dateFromString:expiry];
        dateFormatter.dateFormat = @"dd MMM yyyy";
        cell.lblExpiry.text = [NSString stringWithFormat:@"Your pack will expire on %@",[dateFormatter stringFromDate:yourDate]];
        
        cell.lblNameText.text = [NSString stringWithFormat:@"%@ %@",[jsonData objectForKey:@"name_text"],@"pack"];
    
        float currentUsage = [[jsonData objectForKey:@"usage"]floatValue];
        
        int unli = 0;
        NSString *name = [jsonData objectForKey:@"name"];
        if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
            unli = 0;
        }
        else {
            unli = 1;
        }
        
        NSString *name_text =[jsonData objectForKey:@"name_text"];
        if ([name_text isEqualToString:@"Data"]) {
            float allocateddata = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
            float totalData = (allocateddata + totalBoltON);
            float res12 = [[resource objectForKey:@"12"]floatValue];
            float res1 = [[resource objectForKey:@"1"]floatValue];
            float usedData = (totalData - (res12 + res1));
            float remainingData = totalData - usedData;
            
            if ((totalData/1024) < 0.99) {
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.2f MB",remainingData];
            }
            else{
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.2f GB",remainingData/1024];
            }
            cell.lblRemaining.hidden = NO;
        }
        else if ([name_text isEqualToString:@"SMS"]){
            if (unli == 1) {
                cell.lblRemainingValue.text = @"unlimited";
                cell.lblRemaining.hidden = YES;
            }
            else{
                float totalSMS = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
                float remainingSMS = (totalSMS - currentUsage);
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.0f SMS",remainingSMS];
                cell.lblRemaining.hidden = NO;
            }
        }
        else if ([name_text isEqualToString:@"Voice"]){
            if (unli == 1) {
                cell.lblRemainingValue.text = @"unlimited";
                cell.lblRemaining.hidden = YES;
            }
            else{
                float totalVoice = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
                float remainingVoice = (totalVoice - currentUsage);
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.0f Min",remainingVoice];
                cell.lblRemaining.hidden = NO;
            }
        }
        else if ([name_text isEqualToString:@"Intl Voice"]){
            if (unli == 1) {
                cell.lblRemainingValue.text = @"unlimited";
                cell.lblRemaining.hidden = YES;
            }
            else{
                float totalIntVoice = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
                float remainingIntVoice = (totalIntVoice - currentUsage);
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.0f Min",remainingIntVoice];
                cell.lblRemaining.hidden = NO;
            }
        }
        else if ([name_text isEqualToString:@"Yomojo Voice"]){
            if (unli == 1) {
                cell.lblRemainingValue.text = @"unlimited";
                cell.lblRemaining.hidden = YES;
            }
            else{
                float totalYomojoVoice = [[jsonData objectForKey:@"partition_incl_text"]floatValue];
                float remainingYomojoVoice = (totalYomojoVoice - currentUsage);
                cell.lblRemainingValue.text = [NSString stringWithFormat:@"%.0f Min",remainingYomojoVoice];
                cell.lblRemaining.hidden = NO;
            }
        }
        else if ([name_text isEqualToString:@"PAYG Spend"]){
            cell.lblRemainingValue.text = [NSString stringWithFormat:@"%@",payg];
            cell.lblRemaining.hidden = YES;
        }
        else{
            
        }
        return cell;
    }
    return nil;
}

@end
