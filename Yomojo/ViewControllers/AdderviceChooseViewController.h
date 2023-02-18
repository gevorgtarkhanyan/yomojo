//
//  AdderviceChooseViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 29/05/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import "MBProgressHUD.h"
#import "BEMCheckBox.h"

@interface AdderviceChooseViewController : UIViewController <BEMCheckBoxDelegate>
{
    MBProgressHUD *HUB;
    BEMCheckBox *myCheckBoxUnli;
    BEMCheckBox *myCheckBoxBroadband;
    BEMCheckBox *myCheckBoxNewMobileNum;
    BEMCheckBox *myCheckBoxBringMobile;
    IBOutlet UIView *viewServiceHolder;
    IBOutlet UIView *viewYourMobileNum;
    IBOutlet UITextField *txtSimNickName;
    IBOutlet UIView *viewPortNumber;
    IBOutlet UILabel *lblYourMobileNumber;
    IBOutlet UILabel *lblYouWantToPort;
    NSData *urlData;
    IBOutlet UIButton *btnSelectProvider;
    UIPickerView *pickerProviderList;
    TSPopoverController *popoverController;
    NSMutableArray *arrayProvider;
}
@property (strong, nonatomic) NSData *urlData;
@property (nonatomic) BEMCheckBox *myCheckBoxUnli;
@property (nonatomic) BEMCheckBox *myCheckBoxBroadband;
@property (nonatomic) BEMCheckBox *myCheckBoxNewMobileNum;
@property (nonatomic) BEMCheckBox *myCheckBoxBringMobile;
@property (strong, nonatomic) NSMutableArray *arrayProvider;
@property (strong, nonatomic) IBOutlet UIView *viewServiceHolder;
@property (strong, nonatomic) IBOutlet UIView *viewYourMobileNum;

@property (strong, nonatomic) IBOutlet UITextField *txtSimNickName;
@property (strong, nonatomic) IBOutlet UIView *viewPortNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblYourMobileNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblYouWantToPort;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectProvider;


- (IBAction)btnNext:(id)sender;
- (IBAction)btnBack:(id)sender;


@end
