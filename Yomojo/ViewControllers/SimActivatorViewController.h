//
//  SimActivatorViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 05/11/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimActivatorViewController : UIViewController
{
    MBProgressHUD *HUB;
    int phoneID;
    NSString *clientId;
    IBOutlet UILabel *lblServiceName;
    IBOutlet UILabel *lblMSN;
    IBOutlet UILabel *lblSimNo;
    IBOutlet UILabel *lblLabel;
    int alertInt;
}
@property (nonatomic)int alertInt;
@property (nonatomic)int phoneID;
@property (nonatomic, strong) NSString *clientId;
@property (strong, nonatomic) IBOutlet UILabel *lblServiceName;
@property (strong, nonatomic) IBOutlet UILabel *lblMSN;
@property (strong, nonatomic) IBOutlet UILabel *lblSimNo;
@property (strong, nonatomic) IBOutlet UILabel *lblLabel;

- (IBAction)btnBack:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnSubmit:(id)sender;




@end




NS_ASSUME_NONNULL_END
