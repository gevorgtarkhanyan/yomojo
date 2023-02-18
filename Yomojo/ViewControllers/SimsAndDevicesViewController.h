//
//  SimsAndDevicesViewController.h
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 11/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SimsAndDevicesViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate,UIPickerViewDelegate>
{
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *clientID;
    NSString *sessionID;
    NSString *phoneID;
    int phonesArrayIndex;
    MBProgressHUD *HUB;
    
    IBOutlet UILabel *lblNumber;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblNickName;
    IBOutlet UILabel *simNickname;
    IBOutlet UILabel *lblDevice;

//    UIAlertController *alertIntRoaming;
//    UIAlertController *alertSMSLimit;
//    UIAlertController *alertVoiceMail;
//    UIAlertController *alertCallWaiting;
//    UIAlertController *alertCallDiverts;
//    UIAlertController *alertCalerID;
//    UIAlertController *alertAutoTopUp;
//    UIAlertController *alertCancelSim;
//    UIAlertController *alertgetNewSim;

    UIAlertView *alertIntRoaming;
    UIAlertView *alertVoiceMail;
    UIAlertView *alertCallWaiting;
    UIAlertView *alertCallDiverts;
    UIAlertView *alertCalerID;
    UIAlertView *alertAutoTopUp;
    UIAlertView *alertCancelSim;
    UIAlertView *alertgetNewSim;
    UIAlertView *alertSetPrimary;
    UIAlertView *alertSetPrimaryConfirm;
    
    IBOutlet UIView *reportView;
    IBOutlet UIView *insideReportView;
    IBOutlet UIView *callDivertView;
    IBOutlet UIView *autoTopUpView;
    IBOutlet UITextField *callDivertTxtField;
    
    IBOutlet UIButton *primaryAccBtn;
    IBOutlet UIButton *activatedBtn;
    
    IBOutlet UIButton *autoTopUpAmountBtn;
    NSString *withFamily;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UILabel *lblDevice;
@property (nonatomic) int phonesArrayIndex;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;

@property (nonatomic, strong) IBOutlet UISwitch *oneSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *twoSwitch;
@property (nonatomic, strong) IBOutlet UIScrollView *myScrollView;
//@property (nonatomic, strong) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *lblNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblNickName;

@property (strong, nonatomic) IBOutlet UISwitch *switchIntRoaming;
@property (strong, nonatomic) IBOutlet UISwitch *switchVoiceMail;
@property (strong, nonatomic) IBOutlet UISwitch *switchCallWaiting;
@property (strong, nonatomic) IBOutlet UISwitch *switchCallerID;
@property (strong, nonatomic) IBOutlet UISwitch *switchCallDiverts;
@property (strong, nonatomic) IBOutlet UISwitch *switchAutoTopUp;

@property (strong, nonatomic) IBOutlet UILabel *lblAutoTopup;
@property (strong, nonatomic) IBOutlet UISwitch *switchBar;
@property (strong, nonatomic) NSString *withFamily;

- (IBAction)primaryAccBtn:(id)sender;
- (IBAction)switchAutoTopUpAction:(id)sender;

@end
