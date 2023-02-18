//
//  AddServiceFinalizeViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 01/06/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "AddServiceFinalizeViewController.h"
#import "Constants.h"
#import "UIColor+Yomojo.h"

@interface AddServiceFinalizeViewController ()

@end

@implementation AddServiceFinalizeViewController
@synthesize viewPlanHolder, lbl4G3G, img4G3G, lblData, lblPrice, lblDescription, viewIntlPackHolder, lblTotalPrice, lblIntlPackPrice, jsonData, packUnli, productplans, intlPlanArray, imgBGIntl, imgProgressIntl, selectedIntl, amountIntl, amountUnli, lblSimNick, simNickName, urlData, intlID, dataID;

- (void)viewDidLoad {
    [super viewDidLoad];
    intlID = 0;
    lblSimNick.text = [NSString stringWithFormat:@"SIM Nickname: %@",simNickName];
    
    if ([packUnli  isEqual: @"broadband"]){
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
    } else {
        NSString * sim_type = [jsonData objectForKey:@"sim_type"];
        if (sim_type) {
            if ([sim_type isEqual: @"3G"]) {
                img4G3G.backgroundColor = [UIColor YomoOrangeColor];
                lblData.textColor = [UIColor YomoOrangeColor];
                lblPrice.textColor = [UIColor YomoOrangeColor];
                viewPlanHolder.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
                lbl4G3G.text = @"3G";
            } else {
                img4G3G.backgroundColor = [UIColor YomoPinkColor];
                lblData.textColor = [UIColor YomoPinkColor];
                lblPrice.textColor = [UIColor YomoPinkColor];
                viewPlanHolder.layer.borderColor = [UIColor YomoPinkColor].CGColor;
                lbl4G3G.text = @"4G";
            }
        }
        NSString * titleLabel = [jsonData objectForKey:@"description"];
        if ([titleLabel  isEqual: @"Kids Plan"]) {
            lblDescription.text = titleLabel;
            lblData.text = @"1GB";
            lblDescription.text = @"200 mins talk & unlimited text";
        } else {
            NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
            NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
            strDescription = [strDescription lowercaseString];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
            lblDescription.text = strDescription;
            NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
            lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
            lblDescription.text = [strDescription stringByReplacingOccurrencesOfString:@"sms" withString:@"text"];
        }
        lbl4G3G.textColor = [UIColor whiteColor];
        CGFloat borderWidth = 2.0f;
        viewPlanHolder.frame = CGRectInset(viewPlanHolder.frame, -borderWidth, -borderWidth);
        viewPlanHolder.layer.borderWidth = borderWidth;
        viewPlanHolder.layer.cornerRadius = 15;
        viewPlanHolder.layer.masksToBounds = true;
        
        lblPrice.text = [NSString stringWithFormat:@"$%@*", [jsonData objectForKey:@"amount"]];
        amountUnli = [NSString stringWithFormat:@"%@", [jsonData objectForKey:@"amount"]];
        float totalPrice = 0.0;
        totalPrice  = [amountIntl floatValue] + [amountUnli floatValue];
        lblTotalPrice.text = [NSString stringWithFormat:@"$%.02f*", totalPrice];
        
        if ([sim_type isEqual: @"3G"]) {
            img4G3G.backgroundColor = [UIColor YomoOrangeColor];
            lblData.textColor = [UIColor YomoOrangeColor];
            lblPrice.textColor = [UIColor YomoOrangeColor];
            viewPlanHolder.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
        } else {
            img4G3G.backgroundColor = [UIColor YomoPinkColor];
            lblData.textColor = [UIColor YomoPinkColor];
            lblPrice.textColor = [UIColor YomoPinkColor];
            viewPlanHolder.layer.borderColor = [UIColor YomoPinkColor].CGColor;
        }
        
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(getProductPlans) onTarget:self withObject:nil animated:YES];
        
    }
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
        
        [self sliderIntlPack];
    }
}

- (void) sliderIntlPack {
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

- (IBAction)actionSliderIntl:(SEFilterControl *) sender{
    int itemCount = [[NSString stringWithFormat:@"%lu",(unsigned long)[intlPlanArray count]] intValue];
    if (itemCount == 0)
        itemCount = 5;
    
    float oneSlotSize = (CGRectGetWidth(imgBGIntl.frame))/itemCount;
    imgProgressIntl.frame = CGRectMake(imgProgressIntl.frame.origin.x, imgProgressIntl.frame.origin.y, oneSlotSize*sender.selectedIndex, 15);
    
    if (sender.selectedIndex == 0){
        amountIntl = @"0";
    } else {
        NSMutableDictionary *dictValue = [intlPlanArray objectAtIndex:sender.selectedIndex - 1];
        amountIntl = [dictValue objectForKey:@"planamount"];
        intlID = [dictValue objectForKey:@"id"];
    }
    selectedIntl = sender.selectedIndex;
    float totalPrice = 0.0;
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

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callAddServiceURL) onTarget:self withObject:nil animated:YES];
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

-(void) callAddServiceURL{
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    NSString *clientID = [responseDict objectForKey:@"CLIENTID"];
    NSMutableArray *arrayPersonDetails = [responseDict objectForKey:@"PERSONDETAILS"];
    NSString *emailAddress = [[arrayPersonDetails objectAtIndex:0] objectForKey:@"EMAILADDRESS"];
    NSString *bundleID = [jsonData objectForKey:@"id"];
    
    NSString * strPortalURL = @"";
    
    if ([packUnli  isEqual: @"broadband"]){
        bundleID = @"0";
        intlID = @"0";
        strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/dev/api/single_phone_order_bulk?voiceid=0&smsid=0&dataid=%@&client_id=%@&emailaddress=%@&bundleid=%@&intlid=%@&label=%@&ported=0&mobileno=&serviceprovider=&spname=&accountno=&promocode=&dateofbirth=",dataID, clientID, emailAddress, bundleID, intlID, simNickName];
    } else {
        dataID = @"0";
        strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/dev/api/single_phone_order_bulk?voiceid=0&smsid=0&dataid=%@&client_id=%@&emailaddress=%@&bundleid=%@&intlid=%@&label=%@&ported=0&mobileno=&serviceprovider=&spname=&accountno=&promocode=&dateofbirth=",dataID ,clientID, emailAddress, bundleID, intlID, simNickName];
    }
    
    strPortalURL = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlDataRes = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:urlDataRes encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dictDataRes = [NSJSONSerialization JSONObjectWithData:urlDataRes options:NSJSONReadingMutableContainers error:nil];

        NSMutableDictionary *attrib = [dictDataRes objectForKey:@"@attributes"];
        NSString *resultText = [attrib objectForKey:@"RESULTTEXT"];
        
        if ([resultText  isEqual: @"Success"]) {
            NSString *message = [dictDataRes objectForKey:@"message2"];
            NSString *newPhoneNumber = [dictDataRes objectForKey:@"phonenumber"];
            NSString *strMessage = [NSString stringWithFormat:@"%@ \n %@",message, newPhoneNumber];
            [self alertStatus:strMessage :simNickName];
        } else {
            NSString *message = [dictDataRes objectForKey:@"RESULTTEXT"];
            [self alertStatus:message :@""];
        }
    } else {
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
        [self alertStatus:strError:@"Error"];
    }
}

@end
