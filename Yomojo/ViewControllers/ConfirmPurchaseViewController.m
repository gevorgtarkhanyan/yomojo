//
//  ConfirmPurchaseViewController.m
//  Yomojo
//
//  Created by Suren Poghosyan on 3/20/19.
//  Copyright © 2019 AcquireBPO. All rights reserved.
//

#import "ConfirmPurchaseViewController.h"
#import "AddChildViewController.h"
@interface ConfirmPurchaseViewController ()

@end

@implementation ConfirmPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:240/255.0f green:64/255.0f blue:56/255.0f alpha:1.0f].CGColor, (id)[UIColor colorWithRed:252/255.0f green:130/255.0f blue:35/255.0f alpha:1.0f].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)purchaseButtonAction:(id)sender {
    AddChildViewController *vc = [[AddChildViewController alloc]initWithNibName:@"AddChildViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)cancelButtonAction:(id)sender {
    
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
