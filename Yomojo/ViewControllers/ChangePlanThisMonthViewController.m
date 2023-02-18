//
//  ChangePlanThisMonthViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 23/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "ChangePlanThisMonthViewController.h"
#import "ChangePlanThisMonthTableViewCell.h"
#import <PKRevealController/PKRevealController.h>

@interface ChangePlanThisMonthViewController ()

@end

@implementation ChangePlanThisMonthViewController
@synthesize urlData, phonesArray,bolton,boltonHistoryArray,tblViewThisMonthData,productPlan,productPlanArray,productplans,newTotalPrice;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    newTotalPrice = 0.0;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getProductPlans) onTarget:self withObject:nil animated:YES];
    
    NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPrice];
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
    UIImage *bgimg = [UIImage imageNamed:@"tabBarImg"];
    UIImage *img = [self drawTextName:strTotalPrice inImage:bgimg atPoint:CGPointMake(0, 0)];
    item.image = img;
    [item setSelectedImage:img];

    UITabBarItem *item1 = [self.tabBarController.tabBar.items objectAtIndex:1];
    UIImage *img2 = [self drawTextName:strTotalPrice inImage:bgimg atPoint:CGPointMake(0, 0)];
    item1.image = img2;
    [item1 setSelectedImage:img2];

}

-(void) getProductPlans{
    NSString * strPortalURL = @"https://yomojo.com.au/dev/api/getproductplans/0";
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
        productplans = [[NSMutableDictionary alloc] init];
        productplans = [dictData objectForKey:@"productplans"];
    }
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictData = [userLogin objectForKey:@"getPhoneDetails"];
    [self processDictData:dictData];
}

-(void) processDictData: (NSMutableDictionary*) dictData{
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    //NSString * payg = [resultData objectForKey:@"payg"];
    //int billingType = [[resultData objectForKey:@"billing_type"]intValue];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:[resultData objectForKey:@"billing_type"] forKey:@"billingType"];
    [userLogin setObject:dictData forKey:@"getPhoneDetails"];
    
   //NSMutableDictionary *resource = [resultData objectForKey:@"resource"];

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
    [tblViewThisMonthData reloadData];
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return [productPlanArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *jsonData = [[NSDictionary alloc]init];
    jsonData = [productPlanArray objectAtIndex:indexPath.section];
    static NSString *simpleTableIdentifier = @"Cell";
    ChangePlanThisMonthTableViewCell *cell = (ChangePlanThisMonthTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChangePlanThisMonthTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (![jsonData  isEqual: @"temp"]) {
        NSString *expiry = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"expiry"]];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
        NSDate *yourDate = [dateFormatter dateFromString:expiry];
        dateFormatter.dateFormat = @"dd MMM yyyy";
        
        NSString *planId = [jsonData objectForKey:@"id"];
        NSString *planCode = [jsonData objectForKey:@"code"];
        
        NSMutableDictionary *resultRP = [productplans objectForKey:planCode];
        NSMutableDictionary *planDetails = [resultRP objectForKey:planId];
        NSString *planAmount = [planDetails objectForKey:@"planamount"];
        
        cell.lblExpiry.text = [NSString stringWithFormat:@"Your pack will expire on %@",[dateFormatter stringFromDate:yourDate]];
        cell.lblTitle.text = [NSString stringWithFormat:@"%@ %@",[jsonData objectForKey:@"name_text"],@"pack"];
        cell.lblPlaneName.text = [[jsonData objectForKey:@"name"] stringByReplacingOccurrencesOfString: @"National " withString:@""];
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",planAmount];
        //float currentUsage = [[jsonData objectForKey:@"usage"]floatValue];
        NSString *denomination =[jsonData objectForKey:@"denomination_text"];
        
        int unli = 0;
        NSString *name = [jsonData objectForKey:@"name"];
        if ([name rangeOfString:@"Unlimited"].location == NSNotFound) {
            unli = 0;
        }
        else {
            unli = 1;
        }
        NSString *name_text =[jsonData objectForKey:@"name_text"];
        NSString *imageIconName = @"sms_icon";
        NSString *progressColor = @"#FE4505";
        
        if ([name_text isEqualToString:@"Data"]) {
            imageIconName = @"icon_data";
            denomination = @"GB";
            progressColor = @"#FF8F05";
        }
        else if ([name_text isEqualToString:@"Voice"]){
            imageIconName = @"icon_voice";
            progressColor = @"#E1054F";
        }
        else if ([name_text isEqualToString:@"Intl Voice"]){
            imageIconName = @"icon_intl";
            progressColor = @"#939498";
        }
        else if ([name_text isEqualToString:@"SMS"]){
            imageIconName = @"icon_sms";
            denomination = @"SMS";
            progressColor = @"#FE4505";
        }
        else if ([name_text isEqualToString:@"Yomojo Voice"]){
            imageIconName = @"icon_voice";
            progressColor = @"#E1054F";
        }
        else if ([name_text isEqualToString:@"PAYG Spend"]){
            imageIconName = @"icon_unli";
            progressColor = @"";
        }
        [cell.iconImg setImage:[UIImage imageNamed:imageIconName]];

        newTotalPrice = newTotalPrice + [planAmount floatValue];
        
        NSString * strTotalPrice = [NSString stringWithFormat:@"$%.02f", newTotalPrice];
        
        
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
        UIImage *bgimg = [UIImage imageNamed:@"tabBarImg"];
        UIImage *img = [self drawTextName:strTotalPrice inImage:bgimg atPoint:CGPointMake(0, 0)];
        item.image = img;
        [item setSelectedImage:img];
    }
    return cell;
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


- (IBAction)btnMenu:(id)sender {
    //[self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
