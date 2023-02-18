//
//  AddChildViewController.m
//  Yomojo
//
//  Created by Suren Poghosyan on 3/21/19.
//  Copyright © 2019 AcquireBPO. All rights reserved.
//

#import "AddChildViewController.h"
#import "AddChildsPinViewController.h"
@interface AddChildViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *childNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation AddChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:240/255.0f green:64/255.0f blue:56/255.0f alpha:1.0f].CGColor, (id)[UIColor colorWithRed:252/255.0f green:130/255.0f blue:35/255.0f alpha:1.0f].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.calendarButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.calendarButton.layer.borderWidth = 0.4;
}

#pragma mark - Actions

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)calendarButtonAction:(id)sender {
    
}

- (IBAction)nextButtonAction:(id)sender {
    AddChildsPinViewController *vc = [[AddChildsPinViewController alloc]initWithNibName:@"AddChildsPinViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
