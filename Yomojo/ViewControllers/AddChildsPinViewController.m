//
//  AddChildsPinViewController.m
//  Yomojo
//
//  Created by Suren Poghosyan on 3/21/19.
//  Copyright © 2019 AcquireBPO. All rights reserved.
//

#import "AddChildsPinViewController.h"

@interface AddChildsPinViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField_1;
@property (weak, nonatomic) IBOutlet UITextField *textField_2;
@property (weak, nonatomic) IBOutlet UITextField *textField_3;
@property (weak, nonatomic) IBOutlet UITextField *textField_4;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation AddChildsPinViewController

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

#pragma mark - Actions

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonAction:(id)sender {
    
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {

    if (textField == self.textField_1) {
        [self.textField_2 becomeFirstResponder];
    } else if (textField == self.textField_2) {
        [self.textField_3 becomeFirstResponder];
    } else if (textField == self.textField_3) {
        [self.textField_4 becomeFirstResponder];
    } else if (textField == self.textField_4) {
        [self.textField_4 resignFirstResponder];
    }
    
    return YES;
}

@end
