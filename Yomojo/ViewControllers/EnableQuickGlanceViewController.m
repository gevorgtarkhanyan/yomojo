//
//  EnableQuickGlanceViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 12/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "EnableQuickGlanceViewController.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import <PKRevealController/PKRevealController.h>

@interface EnableQuickGlanceViewController ()

@end

@implementation EnableQuickGlanceViewController
@synthesize btnSelectAccount, arrayAccountList, phonesArray, pickerAccountList, txtSelectedAccount, switchQuickGlance, selectedPhonesArrayIndex, urlData, lblShowQG;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    }
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString *quickGlanceEnable = [userLogin objectForKey:@"quickGlanceEnable"];

    if ([quickGlanceEnable  isEqual: @"YES"]) {
        [switchQuickGlance setOn:YES];
        txtSelectedAccount.enabled = YES;
        btnSelectAccount.enabled = YES;
        txtSelectedAccount.hidden = NO;
        btnSelectAccount.hidden = NO;
        lblShowQG.hidden = NO;
    }
    else{
        [switchQuickGlance setOn:NO];
        txtSelectedAccount.enabled = NO;
        btnSelectAccount.enabled = NO;
        txtSelectedAccount.hidden = YES;
        btnSelectAccount.hidden = YES;
        lblShowQG.hidden = YES;
    }
    [switchQuickGlance addTarget:self action:@selector(switchState:) forControlEvents:UIControlEventValueChanged];
    
    [self getAccountList];
    
    [btnSelectAccount addTarget:self action:@selector(showAccountList:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [pickerAccountList reloadAllComponents];
}

-(void) viewWillAppear: (BOOL) animated{
    
}

- (void)switchState:(id)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];

    if ([switchQuickGlance isOn]) {
        [userLogin setObject:@"YES" forKey:@"quickGlanceEnable"];
        [userLogin setObject:urlData forKey:@"quickGlanceURLData"];
        [userLogin setObject:phonesArray forKey:@"quickGlancePhoneArray"];
        NSMutableDictionary *jsonData = [phonesArray objectAtIndex:[selectedPhonesArrayIndex intValue]];
        NSString *strID = [jsonData objectForKey:@"id"];
        [userLogin setObject:strID forKey:@"quickGlanceStrID"];
        
        txtSelectedAccount.enabled = YES;
        btnSelectAccount.enabled = YES;
        txtSelectedAccount.hidden = NO;
        btnSelectAccount.hidden = NO;
        lblShowQG.hidden = NO;
    }
    else{
        [userLogin setObject:@"NO" forKey:@"quickGlanceEnable"];
        txtSelectedAccount.enabled = NO;
        btnSelectAccount.enabled = NO;
        txtSelectedAccount.hidden = YES;
        btnSelectAccount.hidden = YES;
        lblShowQG.hidden = YES;
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void) getAccountList{
    arrayAccountList = [[NSMutableArray alloc]init];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    int quickGlanceIndex = 0;
    for (int i = 0; i < [phonesArray count]; i++) {
        NSDictionary *jsonData = [[NSDictionary alloc]init];
        jsonData = [phonesArray objectAtIndex:i];
        NSString *phoneLabel = [jsonData objectForKey:@"label"];
        NSString *strID = [jsonData objectForKey:@"id"];
        NSString *planID = [jsonData objectForKey:@"planid"];
        NSString *number = [jsonData objectForKey:@"number"];
        NSString *phoneNumber = @"0";
        if (![planID  isEqual: @"40"]) {
            if (![number  isEqual: @"0"]) {
                NSMutableArray *arrayPhoneNum =[self numberToArray:number];
                phoneNumber = [NSString stringWithFormat:@"0%@%@%@ %@%@%@ %@%@%@",[arrayPhoneNum objectAtIndex:0],[arrayPhoneNum objectAtIndex:1],[arrayPhoneNum objectAtIndex:2],[arrayPhoneNum objectAtIndex:3],[arrayPhoneNum objectAtIndex:4],[arrayPhoneNum objectAtIndex:5],[arrayPhoneNum objectAtIndex:6],[arrayPhoneNum objectAtIndex:7],[arrayPhoneNum objectAtIndex:8]];
            }
            phoneLabel = [phoneLabel stringByReplacingOccurrencesOfString: @"%20" withString:@" "];
            NSString *strPhoneLabel = [NSString stringWithFormat:@"%@ - %@",phoneLabel,phoneNumber];
            [arrayAccountList addObject:strPhoneLabel];
        }
        
        NSString *storedStrID = [userLogin objectForKey:@"quickGlanceStrID"];
        if (storedStrID == strID) {
            quickGlanceIndex = i;
            selectedPhonesArrayIndex = [NSString stringWithFormat:@"%d",quickGlanceIndex];
            [userLogin setObject:selectedPhonesArrayIndex forKey:@"quickGlanceIndex"];
        }
    }
    if (quickGlanceIndex < 0)
        txtSelectedAccount.text = @"- SELECT -";
    else
        txtSelectedAccount.text = [arrayAccountList objectAtIndex:quickGlanceIndex];
}

-(NSMutableArray*)numberToArray:(NSString*) phoneNumber{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [phoneNumber length]; i++) {
        NSString *ch = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    return array;
}


-(void)showAccountList:(id)sender forEvent:(UIEvent*)event{
    UIViewController *prodNameView = [[UIViewController alloc]init];
    prodNameView.view.frame = CGRectMake(0,0, 320, 100);
    pickerAccountList = [[UIPickerView alloc] init];
    pickerAccountList.delegate = self;
    pickerAccountList.dataSource = self;
    pickerAccountList.frame  = CGRectMake(0,0, 320, 120);
    pickerAccountList.showsSelectionIndicator = YES;
    
    UITapGestureRecognizer *tapToSelect = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                    action:@selector(tappedToSelectRow:)];
    tapToSelect.delegate = self;
    [pickerAccountList addGestureRecognizer:tapToSelect];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];

    int quickGlanceIndex = [[userLogin objectForKey:@"quickGlanceIndex"] intValue];
    if (quickGlanceIndex <=0)
        [pickerAccountList selectRow:0 inComponent:0 animated:YES];
    else
        [pickerAccountList selectRow:quickGlanceIndex inComponent:0 animated:YES];
    
    [prodNameView.view addSubview:pickerAccountList];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:prodNameView];
    popoverController.cornerRadius = 5;
    popoverController.titleText = @"Select account";
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

- (IBAction)switchQuickGlanceAction:(id)sender {

}

- (IBAction)btnBack:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSubmit:(id)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:selectedPhonesArrayIndex forKey:@"quickGlanceIndex"];
    [userLogin setObject:urlData forKey:@"quickGlanceURLData"];
    [userLogin setObject:phonesArray forKey:@"quickGlancePhoneArray"];

    if ([switchQuickGlance isOn]) {
        [userLogin setObject:@"YES" forKey:@"quickGlanceEnable"];
    } else {
        [userLogin setObject:@"NO" forKey:@"quickGlanceEnable"];
    }
}

- (IBAction)btnShowMenu:(id)sender {
    [self showRightView:sender];
}

- (void)showRightView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else{
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (IBAction)tappedToSelectRow:(UITapGestureRecognizer *)tapRecognizer{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat rowHeight = [pickerAccountList rowSizeForComponent:0].height;
        CGRect selectedRowFrame = CGRectInset(pickerAccountList.bounds, 0.0, (CGRectGetHeight(pickerAccountList.frame) - rowHeight) / 2.0 );
        BOOL userTappedOnSelectedRow = (CGRectContainsPoint(selectedRowFrame, [tapRecognizer locationInView:pickerAccountList]));
        if (userTappedOnSelectedRow) {
            fromPickerTAP = YES;
            NSInteger selectedRow = [pickerAccountList selectedRowInComponent:0];
            [self pickerView:pickerAccountList didSelectRow:selectedRow inComponent:0];
        }
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

#pragma mark - PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayAccountList count];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (fromPickerTAP == YES) {
        txtSelectedAccount.text = [arrayAccountList objectAtIndex:row];
        selectedPhonesArrayIndex = [NSString stringWithFormat:@"%ld",(long)row];
        
        NSMutableDictionary *jsonData = [phonesArray objectAtIndex:[selectedPhonesArrayIndex intValue]];
        NSString *strID = [jsonData objectForKey:@"id"];
        
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:selectedPhonesArrayIndex forKey:@"quickGlanceIndex"];
        [userLogin setObject:urlData forKey:@"quickGlanceURLData"];
        [userLogin setObject:phonesArray forKey:@"quickGlancePhoneArray"];
        [userLogin setObject:strID forKey:@"quickGlanceStrID"];
        [popoverController dismissPopoverAnimatd:YES];
        fromPickerTAP = NO;
    }
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
    }

    [tView setFont:[UIFont fontWithName:@"Helvetica" size:18.5]];
    [tView setTextColor:[UIColor darkGrayColor]];
    [tView setTextAlignment:NSTextAlignmentCenter];
    [tView setNumberOfLines:0];
    tView.lineBreakMode = NSLineBreakByWordWrapping;

    tView.text = [arrayAccountList objectAtIndex:row];
    
    return tView;
}


@end
