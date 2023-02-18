//
//  CreditCardDetailsViewController.h
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import "NTMonthYearPicker.h"

@interface CreditCardDetailsViewController : UIViewController <UIAlertViewDelegate,UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    TSPopoverController *popoverController;
    MBProgressHUD *HUB;
   
    NSString *clientID;
    NSString *sessionID;
    NSString *strUserName;
    NSString *strPassword;
    
    NSMutableArray *yearsArray;
    NSMutableArray *monthsArray;
    NSMutableArray *cardExpMMData;
    NSMutableArray *cardExpYYyData;
    NSMutableArray *cardTypeArrayData;

    UIPickerView *pickerExpMM;
    UIPickerView *pickerExpYY;
    UIPickerView *pickerCardType;
    UIPickerView *monthPicker;
    UIPickerView *expiryDatePicker;
    
    IBOutlet UITextField *cardCCV;
    IBOutlet UITextField *cardExpYY;
    IBOutlet UITextField *cardExpMM;
    IBOutlet UITextField *txtCarNum1;
    IBOutlet UITextField *txtCardType;
    IBOutlet UITextField *txtCardName;

    IBOutlet UILabel *lblValidThru;
    IBOutlet UILabel *lblExpiryDate;
    IBOutlet UILabel *lblCardExpiry;
    IBOutlet UILabel *lblCardNumber;

    IBOutlet UIButton *btnSave;
    IBOutlet UIButton *btnCardType;
    IBOutlet UIButton *btnExpiryDateMonth;
    IBOutlet UIButton *btnExpiryDateYear;

    IBOutlet UIView *viewEditCard;
    IBOutlet UIImageView *imgCreditCardLogo;
    
    UIView *viewHolder;
        
    NTMonthYearPicker *yearPicker;
}

@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString * strUserName;
@property (strong, nonatomic) NSString * strPassword;

@property (strong, nonatomic) IBOutlet UILabel *lblValidThru;
@property (strong, nonatomic) IBOutlet UILabel *lblCardNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblCardExpiry;
@property (strong, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (strong, nonatomic) IBOutlet UILabel *lblCreditCardNum;

@property (strong, nonatomic) IBOutlet UITextField *cardCCV;
@property (strong, nonatomic) IBOutlet UITextField *cardExpMM;
@property (strong, nonatomic) IBOutlet UITextField *cardExpYY;
@property (strong, nonatomic) IBOutlet UITextField *txtCarNum1;
@property (strong, nonatomic) IBOutlet UITextField *txtCardType;
@property (strong, nonatomic) IBOutlet UITextField *txtCardName;
@property (strong, nonatomic) IBOutlet UITextField *txtExpiryDate;

@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIButton *btnYear;
@property (strong, nonatomic) IBOutlet UIButton *btnMonth;
@property (strong, nonatomic) IBOutlet UIButton *btnCardType;
@property (strong, nonatomic) IBOutlet UIButton *btnExpiryDateMonth;
@property (strong, nonatomic) IBOutlet UIButton *btnExpiryDateYear;


@property (strong, nonatomic) IBOutlet UIImageView *imgCreditCardLogo;

@property (strong, nonatomic) IBOutlet UIView *viewEditCard;

@property (strong, nonatomic) NTMonthYearPicker *yearPicker;

- (IBAction)btnSave:(id)sender;
- (IBAction)btnEdit:(id)sender;

@end
