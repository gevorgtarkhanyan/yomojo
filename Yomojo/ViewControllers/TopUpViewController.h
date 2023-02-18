//
//  TopUpViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 15/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface TopUpViewController : UIViewController
{
    MBProgressHUD *HUB;
    NSData *urlData;
    NSString *phoneID;
    NSString *sessionID;
    IBOutlet UILabel *lblEmail;
    IBOutlet UILabel *lblAmountSlider;
    IBOutlet UILabel *lblTotalAmount;
    IBOutlet UISlider *SliderTopUp;

}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSData *urlData;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnConfirm:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblEmail;

@property (strong, nonatomic) IBOutlet UILabel *lblAmountSlider;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalAmount;
@property (strong, nonatomic) IBOutlet UISlider *SliderTopUp;
@property (strong, nonatomic) NSString * phoneID;

- (IBAction)sliderValueChange:(id)sender;
- (IBAction)btnBack:(id)sender;


@end
