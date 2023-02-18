//
//  ContactUsViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 09/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface ContactUsViewController : UIViewController <UIAlertViewDelegate,UITextViewDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUB;
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *clientID;
    NSString *sessionID;
    NSString *emailAdd;
    NSMutableArray *arrayEnquiry;
    int alertInt;
    
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtEmailAdd;
    IBOutlet UITextField *txtmobileNum;
    IBOutlet UITextView *txtMessage;
    IBOutlet UITextField *txtEnquiryType;
}
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;

@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmailAdd;
@property (strong, nonatomic) IBOutlet UITextField *txtmobileNum;
@property (strong, nonatomic) IBOutlet UITextView *txtMessage;
@property (strong, nonatomic) IBOutlet UITextField *txtEnquiryType;
@property (strong, nonatomic) IBOutlet UIButton *btnEnquiry;


- (IBAction)btnBack:(id)sender;
- (IBAction)btnSubmit:(id)sender;
- (IBAction)btnChat:(id)sender;

- (IBAction)btnCallLocal:(id)sender;
- (IBAction)btnCallIntl:(id)sender;


@end
