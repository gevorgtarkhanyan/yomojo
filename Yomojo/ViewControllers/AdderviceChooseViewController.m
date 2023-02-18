//
//  AdderviceChooseViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 29/05/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import "AdderviceChooseViewController.h"
#import "AddServicePlansViewController.h"


@interface AdderviceChooseViewController ()

@end

@implementation AdderviceChooseViewController
@synthesize viewServiceHolder, myCheckBoxUnli, myCheckBoxBroadband,viewYourMobileNum, myCheckBoxNewMobileNum, myCheckBoxBringMobile, txtSimNickName, viewPortNumber, lblYourMobileNumber, lblYouWantToPort, urlData, btnSelectProvider, arrayProvider;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    myCheckBoxUnli = [[BEMCheckBox alloc] init];
    myCheckBoxUnli.frame = CGRectMake(0, 0, 25, 25);
    myCheckBoxUnli.tintColor = [UIColor darkGrayColor];
    myCheckBoxUnli.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxUnli.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxUnli.onAnimationType = BEMAnimationTypeBounce;
    myCheckBoxUnli.animationDuration = 0.2;
    myCheckBoxUnli.onCheckColor = [UIColor whiteColor];
    myCheckBoxUnli.tag = 0;
    myCheckBoxUnli.on = YES;
    myCheckBoxUnli.delegate = self;
    
    myCheckBoxBroadband = [[BEMCheckBox alloc] init];
    myCheckBoxBroadband.frame = CGRectMake(0, 50, 25, 25);
    myCheckBoxBroadband.tintColor = [UIColor darkGrayColor];
    myCheckBoxBroadband.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxBroadband.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxBroadband.onAnimationType = BEMAnimationTypeBounce;
    myCheckBoxBroadband.animationDuration = 0.2;
    myCheckBoxBroadband.onCheckColor = [UIColor whiteColor];
    myCheckBoxBroadband.delegate = self;
    myCheckBoxBroadband.tag = 1;
    
    [viewServiceHolder addSubview:myCheckBoxUnli];
    [viewServiceHolder addSubview:myCheckBoxBroadband];
    
    myCheckBoxNewMobileNum = [[BEMCheckBox alloc] init];
    myCheckBoxNewMobileNum.frame = CGRectMake(10, 10, 20, 20);
    myCheckBoxNewMobileNum.tintColor = [UIColor darkGrayColor];
    myCheckBoxNewMobileNum.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxNewMobileNum.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxNewMobileNum.onAnimationType = BEMAnimationTypeBounce;
    myCheckBoxNewMobileNum.animationDuration = 0.2;
    myCheckBoxNewMobileNum.onCheckColor = [UIColor whiteColor];
    myCheckBoxNewMobileNum.delegate = self;
    myCheckBoxNewMobileNum.tag = 2;
    myCheckBoxNewMobileNum.on = YES;
    
    myCheckBoxBringMobile = [[BEMCheckBox alloc] init];
    myCheckBoxBringMobile.frame = CGRectMake(10, 40, 20, 20);
    myCheckBoxBringMobile.tintColor = [UIColor darkGrayColor];
    myCheckBoxBringMobile.onFillColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxBringMobile.onTintColor = [UIColor colorWithRed:255/255.f green:69/255.f blue:5/255.f alpha:1];
    myCheckBoxBringMobile.onAnimationType = BEMAnimationTypeBounce;
    myCheckBoxBringMobile.animationDuration = 0.2;
    myCheckBoxBringMobile.onCheckColor = [UIColor whiteColor];
    myCheckBoxBringMobile.delegate = self;
    myCheckBoxBringMobile.tag = 3;
    
    [viewYourMobileNum addSubview:myCheckBoxNewMobileNum];
    [viewYourMobileNum addSubview:myCheckBoxBringMobile];
    
    
    [btnSelectProvider addTarget:self action:@selector(showProviderList:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getProviderList) onTarget:self withObject:nil animated:YES];
    

}

- (void) alertStatus:(NSString *)msg :(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void) getProviderList{
    
}

-(void)showProviderList:(id)sender forEvent:(UIEvent*)event{
    [self dismissKeyboard];
    UIViewController *prodNameView = [[UIViewController alloc]init];
    prodNameView.view.frame = CGRectMake(0,0, 320, 100);
    pickerProviderList = [[UIPickerView alloc] init];
    pickerProviderList.delegate = self;
    pickerProviderList.dataSource = self;
    pickerProviderList.frame  = CGRectMake(0,0, 320, 120);
    pickerProviderList.showsSelectionIndicator = YES;
    [prodNameView.view addSubview:pickerProviderList];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:prodNameView];
    popoverController.cornerRadius = 5;
    popoverController.titleText = @"Select provider";
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

-(void)dismissKeyboard {
    [txtSimNickName resignFirstResponder];
}

- (IBAction)btnNext:(id)sender {
    if (![txtSimNickName.text  isEqual: @""]) {
        NSString *packUnli = @"unlimited";
        NSString *portMobile = @"";
        
        if (myCheckBoxUnli.on == YES){
            packUnli = @"unlimited";
            if (myCheckBoxNewMobileNum.on == YES) {
                portMobile = @"newNumber";
            }
            if (myCheckBoxBringMobile.on == YES) {
                portMobile = @"portNumber";
            }
        }
        if (myCheckBoxBroadband.on == YES){
            packUnli = @"broadband";
            portMobile = @"";
        }
        
        AddServicePlansViewController *aspvc = [[AddServicePlansViewController alloc]initWithNibName:@"AddServicePlansViewController" bundle:nil];
        aspvc.urlData = urlData;
        aspvc.simNickName = txtSimNickName.text;
        aspvc.packUnli = packUnli;
        [self.navigationController pushViewController:aspvc animated:YES];
    } else {
        [self alertStatus:@"SIM Nickname is required" :@"Notification"];
    }
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox {
    if (checkBox.tag == 0) {
        if (myCheckBoxUnli.on == YES) {
            [myCheckBoxBroadband setOn:NO animated:YES];
            viewPortNumber.hidden = NO;
            lblYourMobileNumber.hidden = NO;
            lblYouWantToPort.hidden = NO;
        } else {
            [myCheckBoxUnli setOn:YES animated:YES];
            viewPortNumber.hidden = NO;
            lblYourMobileNumber.hidden = NO;
            lblYouWantToPort.hidden = NO;
        }
    }
    if (checkBox.tag == 1) {
        if (myCheckBoxBroadband.on == YES) {
            [myCheckBoxUnli setOn:NO animated:YES];
            viewPortNumber.hidden = YES;
            lblYourMobileNumber.hidden = YES;
            lblYouWantToPort.hidden = YES;
        } else {
            [myCheckBoxBroadband setOn:YES animated:YES];
            viewPortNumber.hidden = YES;
            lblYourMobileNumber.hidden = YES;
            lblYouWantToPort.hidden = YES;
        }
    }
    if (checkBox.tag == 2) {
        if (myCheckBoxNewMobileNum.on == YES) {
            [myCheckBoxBringMobile setOn:NO animated:YES];
        } else {
            [myCheckBoxNewMobileNum setOn:YES animated:YES];
        }
    }
    if (checkBox.tag == 3) {
        if (myCheckBoxBringMobile.on == YES) {
            [myCheckBoxNewMobileNum setOn:NO animated:YES];
        } else {
            [myCheckBoxBringMobile setOn:YES animated:YES];
        }
        
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayProvider count];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
        [popoverController dismissPopoverAnimatd:YES];
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
    }
    [tView setFont:[UIFont fontWithName:@"Helvetica" size:18.5]];
    [tView setTextColor:[UIColor darkGrayColor]];
    [tView setTextAlignment:NSTextAlignmentCenter];
    tView.text = [arrayProvider objectAtIndex:row];
    return tView;
}


@end
