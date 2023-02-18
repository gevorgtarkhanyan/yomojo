//
//  AddServicePlansViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 01/06/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "AddServicePlansViewController.h"
#import "ChangePlanNewTableViewCell.h"
#import "AddServiceFinalizeViewController.h"
#import "Constants.h"
#import "UIColor+Yomojo.h"

@interface AddServicePlansViewController ()

@end

@implementation AddServicePlansViewController
@synthesize tblPacks, arrayUnliBundles, mbbPlanArray, planID, simNickName, packUnli, portMobile, lblPleaseSelectPlan, mbbPlans, urlData;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblPleaseSelectPlan.text = [NSString stringWithFormat:@"Please select plan for %@",simNickName];
    
    if ([packUnli  isEqual: @"broadband"]){
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(getMBBPlans) onTarget:self withObject:nil animated:YES];
    } else {
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(getBundlePlans) onTarget:self withObject:nil animated:YES];
    }
}

- (void) getBundlePlans {
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbundles2",PORTAL_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    arrayUnliBundles = [[NSMutableArray alloc] init];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *arrayBundles = [dictData objectForKey:@"bundles"];
        for (int i=0; [arrayBundles count] > i; i++) {
            [arrayUnliBundles addObject:[arrayBundles objectAtIndex:i]];
        }
        [tblPacks reloadData];
    }
}

-(void) getMBBPlans{
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/getbundles2",PORTAL_URL];
    
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
        
        [tblPacks reloadData];
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([packUnli  isEqual: @"broadband"]){
        return [mbbPlanArray count];
    }
    return [arrayUnliBundles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"Cell";
    ChangePlanNewTableViewCell *cell = (ChangePlanNewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChangePlanNewTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    
    if ([packUnli  isEqual: @"broadband"]){
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
    } else {
        jsonData = [arrayUnliBundles objectAtIndex:indexPath.section];
        NSString * titleLabel = [jsonData objectForKey:@"description"];
        NSString * sim_type = [jsonData objectForKey:@"sim_type"];
        if (sim_type) {
            if ([sim_type isEqual: @"3G"]) {
                cell.img4G3G.backgroundColor = [UIColor YomoOrangeColor];
                cell.lblData.textColor = [UIColor YomoOrangeColor];
                cell.lblPrice.textColor = [UIColor YomoOrangeColor];
                cell.viewBoxPlan.layer.borderColor = [UIColor YomoOrangeColor].CGColor;
                cell.lblCurrentNetMont.textColor = [UIColor YomoOrangeColor];
            } else {
                cell.img4G3G.backgroundColor = [UIColor YomoPinkColor];
                cell.lblData.textColor = [UIColor YomoPinkColor];
                cell.lblPrice.textColor = [UIColor YomoPinkColor];
                cell.viewBoxPlan.layer.borderColor = [UIColor YomoPinkColor].CGColor;
                cell.lblCurrentNetMont.textColor = [UIColor YomoPinkColor];
            }
        }
        if ([titleLabel  isEqual: @"Kids Plan"]) {
            cell.lblData.text = @"1GB";
            cell.lblDescription.text = @"200 mins talk & unlimited text";
        } else {
            NSArray* arrayDescription = [titleLabel componentsSeparatedByString: @"&"];
            NSString *strDescription = [NSString stringWithFormat:@"%@ & %@",[arrayDescription objectAtIndex:0], [arrayDescription objectAtIndex:1]];
            strDescription = [strDescription lowercaseString];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"voice" withString:@"talk"];
            
            NSArray *arrayDataValue = [[arrayDescription objectAtIndex:2] componentsSeparatedByString: @"Data"];
            cell.lblData.text = [NSString stringWithFormat:@"%@",[arrayDataValue objectAtIndex:0]];
            cell.lblDescription.text = [strDescription stringByReplacingOccurrencesOfString:@"sms" withString:@"text"];
        }
        cell.lbl4G3G.text = [NSString stringWithFormat:@"%@",sim_type];
        cell.lbl4G3G.textColor = [UIColor whiteColor];
        CGFloat borderWidth = 2.0f;
        cell.viewBoxPlan.frame = CGRectInset(cell.viewBoxPlan.frame, -borderWidth, -borderWidth);
        cell.viewBoxPlan.layer.borderWidth = borderWidth;
        cell.viewBoxPlan.layer.cornerRadius = 15;
        cell.viewBoxPlan.layer.masksToBounds = true;
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@", [jsonData objectForKey:@"amount"]];

        cell.imgBannerImage.hidden = YES;
        if ([sim_type isEqual: @"3G"])
            cell.imgBannerImage.image = [UIImage imageNamed:@"NextMonthSash3G"];
        else
            cell.imgBannerImage.image = [UIImage imageNamed:@"nextMonth4G"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];

    if ([packUnli  isEqual: @"broadband"]){
         jsonData = [mbbPlanArray objectAtIndex:indexPath.section];
    } else {
         jsonData = [arrayUnliBundles objectAtIndex:indexPath.section];
    }
    
    AddServiceFinalizeViewController *aspvc = [[AddServiceFinalizeViewController alloc]initWithNibName:@"AddServiceFinalizeViewController" bundle:nil];
    aspvc.jsonData = jsonData;
    aspvc.simNickName = simNickName;
    aspvc.packUnli = packUnli;
    aspvc.urlData = urlData;
    
    [self.navigationController pushViewController:aspvc animated:YES];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
