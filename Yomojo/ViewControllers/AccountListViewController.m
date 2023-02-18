//
//  AccountListViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 02/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "AccountListViewController.h"
#import "AccountViewItemCell.h"
#import <PKRevealController/PKRevealController.h>
#import "MainViewController.h"
#import "SideMenuViewController.h"

@interface AccountListViewController ()

@end

@implementation AccountListViewController
@synthesize urlData, phonesArray,MIMtableView,withFamily;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [MIMtableView reloadData];
    
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

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [phonesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *jsonData = [[NSDictionary alloc]init];
    jsonData = [phonesArray objectAtIndex:indexPath.section];
    
    static NSString *simpleTableIdentifier = @"Cell";
    
    AccountViewItemCell *cell = (AccountViewItemCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AccountViewItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //cell.backgroundColor = [UIColor clearColor];
    cell.lblName.text = [jsonData objectForKey:@"label"];
    
    NSMutableArray *arrayPhoneNum =[self numberToArray:[jsonData objectForKey:@"number"]];
    cell.lblNumber.text = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
    
    //cell.lblNumber.text = [jsonData objectForKey:@"number"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *jsonData = [[NSDictionary alloc]init];
    jsonData = [phonesArray objectAtIndex:indexPath.section];
    
    MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:[NSBundle mainBundle]];
    mvc.urlData = urlData;
    mvc.phonesArray = phonesArray;
    NSString *indexNum = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    mvc.phonesArrayIndex = [indexNum intValue];
    
    SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
    smvc.urlData = urlData;
    smvc.phonesArray = phonesArray;
    smvc.phonesArrayIndex = [indexNum intValue];
    smvc.withFamily = withFamily;
    
    UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
    UIViewController *rightViewController = smvc;

    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:rightViewController];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:revealController animated:YES];
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
