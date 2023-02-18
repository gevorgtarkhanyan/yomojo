//
//  UpdatePasswordViewController.h
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface UpdatePasswordViewController : UIViewController <UIAlertViewDelegate>
{
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *clientID;
    NSString *sessionID;
    int phonesArrayIndex;
    MBProgressHUD *HUB;
    IBOutlet UITextField *txtExistingPassword;
    IBOutlet UITextField *txtNewPassword;
    IBOutlet UITextField *txtConfirmPassword;
    int alertError;
    BOOL showPassCheckbox;
    IBOutlet UIButton *btnShowPass;

}
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (nonatomic) int phonesArrayIndex;
@property (strong, nonatomic) IBOutlet UITextField *txtExistingPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnShowPass;

- (IBAction)btnSave:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnShowPass:(id)sender;


@end
