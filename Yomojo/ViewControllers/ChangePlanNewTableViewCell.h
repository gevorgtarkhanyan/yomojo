//
//  ChangePlanNewTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 11/04/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePlanNewTableViewCell : UITableViewCell
{
    IBOutlet UILabel *lbl4G3G;
    IBOutlet UILabel *lblData;
    IBOutlet UILabel *lblDescription;
    IBOutlet UIImageView *img4G3G;
    IBOutlet UIView *viewBoxPlan;
    IBOutlet UILabel *lblPrice;
    IBOutlet UILabel *lblDataLabel;
    IBOutlet UIView *viewCurrentPlan;
    IBOutlet UILabel *lblCurrentNetMont;
    IBOutlet UIImageView *imgBannerImage;
}

@property (strong, nonatomic) IBOutlet UILabel *lbl4G3G;
@property (strong, nonatomic) IBOutlet UILabel *lblData;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIView *viewBoxPlan;
@property (strong, nonatomic) IBOutlet UIImageView *img4G3G;

@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblDataLabel;
@property (strong, nonatomic) IBOutlet UIView *viewCurrentPlan;

@property (strong, nonatomic) IBOutlet UILabel *lblCurrentNetMont;

@property (strong, nonatomic) IBOutlet UIImageView *imgBannerImage;



@end
