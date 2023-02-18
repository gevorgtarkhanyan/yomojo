//
//  EnableQuickGlanceViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 12/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSPopoverController.h"
#import "TSActionSheet.h"

@interface EnableQuickGlanceViewController : UIViewController <UIGestureRecognizerDelegate>
{
    TSPopoverController *popoverController;
    IBOutlet UIButton *btnSelectAccount;
    UIPickerView *pickerAccountList;
    NSMutableArray *arrayAccountList;
    NSMutableArray *phonesArray;
    IBOutlet UITextField *txtSelectedAccount;
    NSString* selectedPhonesArrayIndex;
    IBOutlet UISwitch *switchQuickGlance;
    NSData *urlData;
    IBOutlet UILabel *lblShowQG;
    BOOL fromPickerTAP;
}
@property (strong, nonatomic) IBOutlet UILabel *lblShowQG;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectAccount;
@property (strong, nonatomic) NSMutableArray *arrayAccountList;
@property (strong, nonatomic) UIPickerView *pickerAccountList;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) IBOutlet UITextField *txtSelectedAccount;
@property (nonatomic) NSString* selectedPhonesArrayIndex;
@property (strong, nonatomic) IBOutlet UISwitch *switchQuickGlance;

- (IBAction)switchQuickGlanceAction:(id)sender;

- (IBAction)btnBack:(id)sender;
- (IBAction)btnSubmit:(id)sender;
- (IBAction)btnShowMenu:(id)sender;



@end
