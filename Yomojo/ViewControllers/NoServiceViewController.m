//
//  NoServiceViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 04/07/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "NoServiceViewController.h"
#import <PKRevealController/PKRevealController.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Constants.h"
#import "LoginViewController.h"

@interface NoServiceViewController ()

@end

@implementation NoServiceViewController
@synthesize urlData, phonesArray, withFamily, fromFB,  btnLabelGotoFamily, btnLabelAddService;
@synthesize viewAds, imgAdsImage, viewAdsHolder, adsURL_link, fromLogin, clientID, imgResizeImg;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    clientID = [responseDict objectForKey:@"CLIENTID"];
    
    UIView *adsSubView = [[[NSBundle mainBundle] loadNibNamed:@"NoServiceViewController" owner:self options:nil] objectAtIndex:1];
    adsSubView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGFloat borderWidth = 3.0f;
    viewAds.frame = CGRectInset(viewAds.frame, -borderWidth, -borderWidth);
    viewAds.layer.borderWidth = borderWidth;
    viewAds.layer.cornerRadius = 20;
    viewAds.layer.masksToBounds = true;
    viewAds.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.view addSubview:adsSubView];
    viewAdsHolder.hidden = YES;

    if (fromLogin == YES) {
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(showAdds) onTarget:self withObject:nil animated:YES];
    }
}

- (void)viewWillAppear: (BOOL)animated{
    if ([withFamily  isEqual: @"YES"]) {
        [btnLabelGotoFamily setTitle:@"Go to FamilyEye Home" forState:UIControlStateNormal];
        [imgResizeImg setImage:[UIImage imageNamed:@"resize-8-512_03"]];
    }
    else{
        [btnLabelGotoFamily setTitle:@"Add FamilyEye Profile" forState:UIControlStateNormal];
        [imgResizeImg setImage:[UIImage imageNamed:@"plus-4-512"]];
    }
}

- (void) showAdds {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/advertisement_details?status=On-going&mode=dev&cid=%@&media_type=ios", PORTAL_URL, clientID];
    
    NSLog(@"urlCall: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:dataFromURL options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *arrayAds = [dictData objectForKey:@"result"];
        NSLog(@"%lu",(unsigned long)[arrayAds count]);
        
        if (((unsigned long)[arrayAds count]) != 0) {
            NSString *txtImgName = [[arrayAds objectAtIndex:0] objectForKey:@"mobile_image_url"];
            NSString *txtImgURL = [NSString stringWithFormat:@"https://yomojo.com.au/yomojo_admin/assets/img/advertisement/mobile/%@",txtImgName];
            adsID = [[arrayAds objectAtIndex:0] objectForKey:@"id"];
            
            adsURL_link = [[arrayAds objectAtIndex:0] objectForKey:@"link_url"];
            
            NSURL* url = [NSURL URLWithString:txtImgURL];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = @"GET";
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse * response,
                                                       NSData * data,
                                                       NSError * error) {
                                       if (!error){
                                           imgAdsImage.image = [UIImage imageWithData:data];
                                       }
                                   }];
            viewAdsHolder.hidden = NO;
            [self sendReadAds:adsID];
        }
        else{
            viewAdsHolder.hidden = YES;
        }
    }
}

-(void) sendReadAds: (NSString*) adsID{

    NSString * strPortalURL = [NSString stringWithFormat:@"%@/add_fta?cid=%@&ads_id=%@&mode=dev&media_type=ios", PORTAL_URL, clientID, adsID];
    
    NSLog(@"urlCall: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataFromURL = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        
    }
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

- (IBAction)adsExit:(id)sender {
    viewAdsHolder.hidden = YES;
}

- (IBAction)adsTap:(id)sender {
    viewAdsHolder.hidden = YES;
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(callAdsURLLink) onTarget:self withObject:nil animated:YES];
}

- (IBAction)btnAddService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yomojo.com.au/login"]];
    
    [self appLogout];
}

- (IBAction)btnGotoFamily:(id)sender {
    if ([btnLabelGotoFamily.titleLabel.text  isEqual: @"Go to FamilyEye Home"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://family.yomojo.com.au/dashboard/entries"]];
    }
    else{
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://family.yomojo.com.au/intro"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yomojo.com.au/login"]];
    }
    
    [self appLogout];
}

-(void) appLogout{
    [[FBSDKLoginManager new] logOut];
    LoginViewController *mvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (IBAction)btnMenu:(id)sender {
    [self showRightView:sender];
}

- (IBAction)btnAddMobileService:(id)sender {
}

- (void)showRightView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}


@end
