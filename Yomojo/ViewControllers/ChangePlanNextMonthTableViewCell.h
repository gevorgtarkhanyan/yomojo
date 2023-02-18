//
//  ChangePlanNextMonthTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 30/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePlanNextMonthTableViewCell : UITableViewCell
{
    IBOutlet UIButton *btnSaveAndContinue;
    IBOutlet UIImageView *imgUnliVoiceSMS;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIView *viewPrice;
    IBOutlet UILabel *lblNextMonthTotal;
    IBOutlet UILabel *lblThisMonthTotal;
    IBOutlet UILabel *lbl3GLabel;
    IBOutlet UILabel *lblFullPrice;
}

@property (strong, nonatomic) IBOutlet UIView *viewPrice;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblPackName;
@property (strong, nonatomic) IBOutlet UILabel *lblUnit;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UIButton *btnSaveAndContinue;

@property (strong, nonatomic) IBOutlet UIImageView *imgUnliVoiceSMS;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UILabel *lblNextMonthTotal;
@property (strong, nonatomic) IBOutlet UILabel *lblThisMonthTotal;

@property (strong, nonatomic) IBOutlet UILabel *lbl3GLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblFullPrice;

@end
