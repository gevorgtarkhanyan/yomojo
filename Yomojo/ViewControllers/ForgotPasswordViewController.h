//
//  ForgotPasswordViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 10/03/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ForgotPasswordViewController : UIViewController <UIAlertViewDelegate>
{
    MBProgressHUD *HUB;
    IBOutlet UITextField *txtEmail;
    int alertError;
}
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)btnBack:(id)sender;
- (IBAction)btnResetPass:(id)sender;

@end
