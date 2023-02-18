//
//  AccountSettingsViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 17/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import <PKRevealController/PKRevealController.h>
#import "QuickGlanceViewController.h"
//#import <Google/Analytics.h>


@interface AccountSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tableData;
@end

@implementation AccountSettingsViewController
@synthesize urlData,phonesArray,txtEmailAdd,txtDummy,phonesArrayIndex,tableData,contactDetailsViewController,creditCardDetailsViewController,updatePasswordViewController,simsAndDevicesViewController,fromFB,quickGlanceViewController;

static NSString *identifier = @"MenuSectionHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"AccountSettings Page"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    }
    
    if (fromFB == YES) {
         tableData = [NSArray arrayWithObjects:@"Contact Details",@"Credit Card Details",  nil];
    }
    else{
         tableData = [NSArray arrayWithObjects:@"Contact Details",@"Credit Card Details",@"Update Password", nil];
    }
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    if ([phonesArray count] > 0) {
        NSMutableDictionary *phoneDetails = [phonesArray objectAtIndex:phonesArrayIndex];
        NSString *phoneID = [phoneDetails objectForKey:@"id"];
    }
}


-(void)dismissKeyboard {
    [txtDummy resignFirstResponder];
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
 return [tableData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"Contact Details"]) {
    
        contactDetailsViewController = [[ContactDetailsViewController alloc]initWithNibName:@"ContactDetailsViewController" bundle:nil];
        
        contactDetailsViewController.urlData = urlData;
        contactDetailsViewController.phonesArray = phonesArray;
        contactDetailsViewController.phonesArrayIndex = phonesArrayIndex;
        contactDetailsViewController.fromFB = fromFB;
        
        [self.navigationController pushViewController:contactDetailsViewController animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Credit Card Details"]){
        
        creditCardDetailsViewController = [[CreditCardDetailsViewController alloc]initWithNibName:@"CreditCardDetailsViewController" bundle:nil];
        
        creditCardDetailsViewController.clientID = clientID;
        creditCardDetailsViewController.sessionID = sessionID;
        [self.navigationController pushViewController:creditCardDetailsViewController animated:YES];
        
    }
    else if ([cell.textLabel.text isEqualToString:@"Update Password"]){
        updatePasswordViewController = [[UpdatePasswordViewController alloc]initWithNibName:@"UpdatePasswordViewController" bundle:nil];
        updatePasswordViewController.urlData = urlData;
        updatePasswordViewController.phonesArray = phonesArray;
        updatePasswordViewController.phonesArrayIndex = phonesArrayIndex;
        [self.navigationController pushViewController:updatePasswordViewController animated:YES];
    }
    else if ([cell.textLabel.text isEqualToString:@"Sims and Devices"]){
        
        simsAndDevicesViewController = [[SimsAndDevicesViewController alloc]initWithNibName:@"SimsAndDevicesViewController" bundle:nil];
        
        simsAndDevicesViewController.phonesArray = phonesArray;
        simsAndDevicesViewController.urlData = urlData;
        simsAndDevicesViewController.phonesArrayIndex = phonesArrayIndex;
        
        [self.navigationController pushViewController:simsAndDevicesViewController animated:YES];
        
    }
    else if ([cell.textLabel.text isEqualToString:@"Enable Quick Glance"]){
         quickGlanceViewController = [[EnableQuickGlanceViewController alloc]initWithNibName:@"EnableQuickGlanceViewController" bundle:nil];
        quickGlanceViewController.phonesArray = phonesArray;
        quickGlanceViewController.urlData = urlData;
        [self.navigationController pushViewController:quickGlanceViewController animated:YES];
    }
}

- (void)showRightView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBack:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self showRightView:sender];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
