//
//  SideMenuViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 01/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "SideMenuViewController.h"
#import <PKRevealController/PKRevealController.h>
#import "AccountListViewController.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "ContactUsViewController.h"
#import "AddServiceViewController.h"
#import "UsageHistoryViewController.h"
#import "LoginViewController.h"
#import "AccountSettingsViewController.h"
#import "SimsAndDevicesViewController.h"
#import "LMMenuCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ChangePlanNextMonthViewController.h"
#import "ChildLocationViewController.h"
#import "EnableQuickGlanceViewController.h"
#import "MenuListTableViewCell.h"
#import "NotificationsViewController.h"
#import "AdderviceChooseViewController.h"
#import "NoServiceViewController.h"
#import "Constants.h"

@interface SideMenuViewController () 

@end

@implementation SideMenuViewController
@synthesize phonesArray,urlData,phonesArrayIndex,fromFB,strUserName,strPassword,lblName,lblNumber,phoneID,lblVersion;
@synthesize arrayAccountList,dropdownView,menuTableView,viewHolder,imgNavBar,productPlans, withFamily,arrayMenuList,tblMenuList,phonesArrayNew, showChildMenuOnly, noActiveService;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    showChildMenuOnly = [userLogin objectForKey:@"showChildMenuOnly"];
    withFamily = [userLogin objectForKey:@"withFamily"];
    
    if ([phonesArray count] == 0) {
        noActiveService = @"YES";
    }
    
    if ([noActiveService isEqual: @"YES"]) {
        if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        } else {
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        }
    } else {
        if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        } else if ([showChildMenuOnly isEqual: @"NO"] && [withFamily isEqual: @"YES"]) {
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"SIM Settings"];
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Quick Glance"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        } else {
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"SIM Settings"];
            [arrayMenuList addObject:@"Quick Glance"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        }
    }
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
   
    lblVersion.text = [NSString stringWithFormat:@"%@ (%@)",appVersionString, appBuildString];
    
    NSString *string = PORTAL_URL;
    if ([string rangeOfString:@"/dev/"].location == NSNotFound) {
        lblVersion.text = [NSString stringWithFormat:@"%@ (%@)",appVersionString, appBuildString];
    } else {
        lblVersion.text = [NSString stringWithFormat:@"%@ (%@) - DEV",appVersionString, appBuildString];
    }
    
    phonesArrayIndex = [[userLogin objectForKey:@"phonesArrayIndex"] intValue];
    
    if (!phonesArrayIndex) {
        if ([phonesArray count] > 0) {
            NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:0];
            phoneID = [phoneDetails objectForKey:@"id"];
            lblName.text = [phoneDetails objectForKey:@"label"];
            lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
            NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
            
            if ([arrayPhoneNum count] <= 1) {
                lblNumber.text = [phoneDetails objectForKey:@"number"];
            } else {
                lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
            }
            phonesArrayIndex = 0;
        }
    } else {
        NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
        phoneID = [phoneDetails objectForKey:@"id"];
        lblName.text = [phoneDetails objectForKey:@"label"];
        lblName.text = [lblName.text stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
        NSMutableArray *arrayPhoneNum =[self numberToArray:[phoneDetails objectForKey:@"number"]];
        
        if ([arrayPhoneNum count] <= 1) {
            lblNumber.text = [phoneDetails objectForKey:@"number"];
        } else {
            lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
        }
    }
    
    arrayAccountList = [[NSMutableArray alloc]init];
    phonesArrayNew = [[NSMutableArray alloc]init];
    for (int i = 0; i < [phonesArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [phonesArray objectAtIndex:i];
        
        NSString *phoneLabel = [jsonData objectForKey:@"label"];
        NSString *number = [jsonData objectForKey:@"number"];
        NSString *phoneNumber = @"0";

        if (![number  isEqual: @"0"]) {
            NSMutableArray *arrayPhoneNum =[self numberToArray:number];
            phoneNumber = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
        }
        phoneLabel = [phoneLabel stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
        NSString *strPhoneLabel = [NSString stringWithFormat:@"%@\n%@",phoneLabel,phoneNumber];
        
        [arrayAccountList addObject:strPhoneLabel];
        [phonesArrayNew addObject:[phonesArray objectAtIndex:i]];

    }

    NSString *strChatWithUs = @"Chat with us";
    [arrayAccountList addObject:strChatWithUs];
    
    [tblMenuList reloadData];
}

- (void) viewDidAppear:(BOOL)animated{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    showChildMenuOnly = [userLogin objectForKey:@"showChildMenuOnly"];
    withFamily = [userLogin objectForKey:@"withFamily"];
    
    if ([phonesArray count] == 0){
        noActiveService = @"YES";
    } else {
        NSDictionary *phone = phonesArray[phonesArrayIndex];
        if (![[phone valueForKey:@"phone_status"] isEqualToString:@"Active"]) {
            noActiveService = @"YES";
        } else {
            noActiveService = @"NO";
        }
    }
    
    if ([noActiveService  isEqual: @"YES"]) {
        if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        } else {
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        }
    } else {
        if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        } else if ([showChildMenuOnly isEqual: @"NO"] && [withFamily isEqual: @"YES"]) {
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Child Location"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"SIM Settings"];
            [arrayMenuList addObject:@"Notifications"];
            [arrayMenuList addObject:@"Quick Glance"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        }
        else{
            arrayMenuList = [[NSMutableArray alloc] init];
            [arrayMenuList addObject:@"Home"];
            [arrayMenuList addObject:@"Account Settings"];
            //            [arrayMenuList addObject:@"Add Service"]; // added
            [arrayMenuList addObject:@"SIM Settings"];
            [arrayMenuList addObject:@"Quick Glance"];
            [arrayMenuList addObject:@"Contact Us"];
            [arrayMenuList addObject:@"Logout"];
        }
    }
    [menuTableView reloadData];
    [tblMenuList reloadData];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    menuTableView.frame = CGRectMake(CGRectGetMinX(menuTableView.frame) ,
                                     CGRectGetMinY(menuTableView.frame),
                                     CGRectGetWidth(self.view.bounds),
                                     MIN(CGRectGetHeight(self.view.bounds) - 70, arrayAccountList.count * 70));
}

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}

- (void) btnNotificationList {
    NotificationsViewController *mvc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:[NSBundle mainBundle]];
    mvc.urlData = urlData;
    mvc.phonesArrayNew = phonesArrayNew;
    mvc.withFamily = withFamily;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [revealController setRecognizesPanningOnFrontView:NO];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void) btnAccountList {
    SimsAndDevicesViewController *mvc = [[SimsAndDevicesViewController alloc] initWithNibName:@"SimsAndDevicesViewController" bundle:[NSBundle mainBundle]];
    mvc.phonesArray = phonesArrayNew;
    mvc.urlData = urlData;
    mvc.withFamily = withFamily;

    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        NSLog(@"NO");
    } else if(buttonIndex == 1) {
        [[FBSDKLoginManager new] logOut];
        LoginViewController *mvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:mvc animated:YES];
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:nil forKey:@"dateWithTimer"];
        [userLogin setObject:nil forKey:@"loginCode"];
        [userLogin removeObjectForKey:@"bannerState"];
    }
}

- (void)btnLogout {
    [self alertStatus:@"Are you sure?" :@"Logout"];
}

- (void) btnContactUs {
    ContactUsViewController *VC = [[ContactUsViewController alloc]initWithNibName:@"ContactUsViewController" bundle:[NSBundle mainBundle]];
    VC.phonesArray = phonesArrayNew;
    VC.urlData = urlData;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:VC];
    UIViewController *leftViewController = smvc;
    
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void)btnAccountSettings {
    AccountSettingsViewController *VC = [[AccountSettingsViewController alloc]initWithNibName:@"AccountSettingsViewController" bundle:[NSBundle mainBundle]];
    VC.phonesArray = phonesArrayNew;
    VC.urlData = urlData;
    VC.phonesArrayIndex = phonesArrayIndex;
    VC.fromFB = fromFB;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:VC];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void)btnAddService {
    AddServiceViewController *VC = [[AddServiceViewController alloc]initWithNibName:@"AddServiceViewController" bundle:[NSBundle mainBundle]];
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:VC];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void)btnHome {
    if ([noActiveService isEqual:@"NO"]) {
        NSDictionary *phone = phonesArray[phonesArrayIndex];
        
        if ([self->showChildMenuOnly isEqualToString:@"NO"] || ([phone valueForKey:@"phone_status"] && [[phone valueForKey:@"phone_status"] isEqualToString:@"Active"])) {
            
            MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
            mvc.urlData = urlData;
            mvc.phonesArray = phonesArrayNew;
            mvc.phonesArrayIndex = phonesArrayIndex;
            mvc.withFamily = withFamily;
            mvc.fromFB = fromFB;
            mvc.fromLogin = NO;
            
            SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
            smvc.urlData = urlData;
            smvc.phonesArray = phonesArrayNew;
            smvc.fromFB = fromFB;
            smvc.withFamily = withFamily;
            smvc.showChildMenuOnly = showChildMenuOnly;
            
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
        } else {
            [self showNoServiceVC];
        }
    } else {
        [self showNoServiceVC];
    }
}

- (void)btnChildLocation {
    ChildLocationViewController *clvc = [[ChildLocationViewController alloc] initWithNibName:@"ChildLocationViewController" bundle:[NSBundle mainBundle]];
    clvc.urlData = urlData;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:clvc];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void)btnQuickGlance {
    EnableQuickGlanceViewController *eqgvc = [[EnableQuickGlanceViewController alloc] initWithNibName:@"EnableQuickGlanceViewController" bundle:[NSBundle mainBundle]];
    eqgvc.phonesArray = phonesArrayNew;
    eqgvc.urlData = urlData;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:eqgvc];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (IBAction)btnMenu:(id)sender {
    [menuTableView reloadData];
    [self showDropDownViewFromDirection:LMDropdownViewDirectionTop];
}

//MARK: - Open VC
- (void) showMainPage {
    MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    mvc.urlData = urlData;
    mvc.phonesArray = phonesArrayNew;
    mvc.fromLogin = NO;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArrayNew;
    smvc.fromFB = fromFB;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
    UIViewController *leftViewController = smvc;
    
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void) showNoServiceVC {
    NoServiceViewController *mvc = [[NoServiceViewController alloc] initWithNibName:@"NoServiceViewController" bundle:[NSBundle mainBundle]];
    mvc.urlData = urlData;
    mvc.phonesArray = phonesArray;
    mvc.withFamily = withFamily;
    mvc.fromFB = NO;
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArray;
    smvc.fromFB = NO;
    smvc.withFamily = withFamily;
    smvc.showChildMenuOnly = showChildMenuOnly;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
    UIViewController *leftViewController = smvc;
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (void)showRightView {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark - DROPDOWN VIEW
- (void)showDropDownViewFromDirection:(LMDropdownViewDirection)direction
{
    // Init dropdown view
    if (!dropdownView) {
        dropdownView = [LMDropdownView dropdownView];
        dropdownView.delegate = self;
        
        // Customize Dropdown style
        dropdownView.closedScale = 1;
        dropdownView.blurRadius = 5;
        dropdownView.blackMaskAlpha = 0;
        dropdownView.animationDuration = 0.5;
        dropdownView.animationBounceHeight = 20;
    }
    dropdownView.direction = direction;
    
    // Show/hide dropdown view
    if ([dropdownView isOpen]) {
        [dropdownView hide];
    } else {
        [dropdownView showInView:viewHolder withContentView:menuTableView atOrigin:CGPointMake(0, 0)];
    }
}

- (void)dropdownViewWillShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will show");
}

- (void)dropdownViewDidShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view did show");
}

- (void)dropdownViewWillHide:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will hide");
}

- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view did hide");
    switch (phonesArrayIndex) {
        case 0:
            //self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            //self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            //self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

#pragma mark - MENU TABLE VIEW
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblMenuList) {
        return [arrayMenuList count];
    }
    return [arrayAccountList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tblMenuList) {
        MenuListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.lblMenuTitle.text = [arrayMenuList objectAtIndex:indexPath.row];
        
        NSString *menuName = [arrayMenuList objectAtIndex:indexPath.row];
        if ([menuName  isEqualToString: @"Notifications"]) {
            NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayRemoteNotifiInfo = [[NSMutableArray alloc]init];
            NSString *clientID = [userLogin objectForKey:@"clientID"];
            NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
            arrayRemoteNotifiInfo = [[userLogin objectForKey:keyName] mutableCopy];
            
            int countUnread = 0;
            for (int i = 0; [arrayRemoteNotifiInfo count] > i; i++) {
                NSMutableDictionary *jsonData = [[arrayRemoteNotifiInfo objectAtIndex:i] mutableCopy];
                NSString * strRead = [jsonData objectForKey:@"read"];
                if ([strRead  isEqualToString: @"NO"]) {
                    countUnread = countUnread + 1;
                }
            }
            if (countUnread > 0) {
                cell.lblUnreadNotif.text = [NSString stringWithFormat:@"%@", @(countUnread)];
                cell.lblUnreadNotif.layer.masksToBounds = YES;
                cell.lblUnreadNotif.layer.cornerRadius = cell.lblUnreadNotif.frame.size.width/2.0;
                cell.lblUnreadNotif.hidden = NO;
            } else {
                cell.lblUnreadNotif.hidden = YES;
            }
        }
        return cell;
    }
    
    LMMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LMMenuCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.menuItemLabel.text = [arrayAccountList objectAtIndex:indexPath.row];
    cell.selectedMarkView.hidden = (indexPath.row != phonesArrayIndex);
    return cell;
}

//MARK: - didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblMenuList){
        
        if ([noActiveService isEqual:@"YES"]) {
            
            if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
                if (indexPath.row == 0) {
                    [self btnHome];
                } else if (indexPath.row == 1) {
                    [self btnChildLocation];
                } else if (indexPath.row == 2) {
                    [self btnAccountSettings];
                } else if (indexPath.row == 3) {
                    [self btnNotificationList];
                } else if (indexPath.row == 4) {
                    [self btnContactUs];
                } else if (indexPath.row == 5) {
                    [self btnLogout];
                }
            } else {
                if (indexPath.row == 0) {
                    [self btnHome];
                } else if (indexPath.row == 1) {
                    [self btnAccountSettings];
                } else if (indexPath.row == 2) {
                    [self btnContactUs];
                } else if (indexPath.row == 3) {
                    [self btnLogout];
                }
            }
        } else {
            if ([showChildMenuOnly isEqual: @"YES"] && [withFamily isEqual: @"YES"]){
                if (indexPath.row == 0) {
                    [self btnHome];
                } else if (indexPath.row == 1) {
                    [self btnChildLocation];
                } else if (indexPath.row == 2) {
                    [self btnAccountSettings];
                } else if (indexPath.row == 3) {
                    [self btnNotificationList];
                } else if (indexPath.row == 4) {
                    [self btnContactUs];

                } else if (indexPath.row == 5) {
                    [self btnLogout];
                }
            } else if ([showChildMenuOnly isEqual: @"NO"] && [withFamily  isEqual: @"YES"]) {
                if (indexPath.row == 0) {
                    [self btnHome];
                } else if (indexPath.row == 1) {
                    [self btnChildLocation];
                } else if (indexPath.row == 2) {
                    [self btnAccountSettings];
                } else if (indexPath.row == 3) {
                    [self btnAccountList];
                } else if (indexPath.row == 4) {
                    [self btnNotificationList];
                } else if (indexPath.row == 5) {
                    [self btnQuickGlance];
                } else if (indexPath.row == 6) {
                    [self btnContactUs];
                } else if (indexPath.row == 7) {
                    [self btnLogout];
                }
            } else {
                if (indexPath.row == 0) {
                    [self btnHome];
                } else if (indexPath.row == 1) {
                    [self btnAccountSettings];
                } else if (indexPath.row == 2) {
                    [self btnAccountList];
                } else if (indexPath.row == 3) {
                    [self btnQuickGlance];
                } else if (indexPath.row == 4) {
                    [self btnContactUs];
                } else if (indexPath.row == 5) {
                    [self btnLogout];
                }
            }
        }
    } else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSString *strIndex = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [dropdownView hide];
        
        if (([strIndex intValue] + 1) == [arrayAccountList count]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yomojo.com.au/chat"]];
        } else {
            phonesArrayIndex = [strIndex intValue];
            NSString *txtPhoneArrayIndex = [NSString stringWithFormat:@"%d",phonesArrayIndex];
            NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
            [userLogin setObject:txtPhoneArrayIndex forKey:@"phonesArrayIndex"];
            
            MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
            mvc.urlData = urlData;
            mvc.phonesArray = phonesArrayNew;
            mvc.phonesArrayIndex = phonesArrayIndex;
            mvc.withFamily = withFamily;
            mvc.fromLogin = NO;
            
            SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
            smvc.urlData = urlData;
            smvc.phonesArray = phonesArrayNew;
            smvc.fromFB = fromFB;
            smvc.withFamily = withFamily;
            smvc.showChildMenuOnly = showChildMenuOnly;
            
            UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
            UIViewController *leftViewController = smvc;
            PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
            [self.navigationController pushViewController:revealController animated:YES];
        }
    }
}

@end
