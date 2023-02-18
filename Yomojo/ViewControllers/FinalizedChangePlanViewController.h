//
//  FinalizedChangePlanViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 19/04/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEFilterControl.h"
#import "MBProgressHUD.h"

@interface FinalizedChangePlanViewController : UIViewController
{
    MBProgressHUD *HUB;
    IBOutlet UIView *viewPlanHolder;
    IBOutlet UILabel *lbl4G3G;
    IBOutlet UIImageView *img4G3G;
    IBOutlet UILabel *lblData;
    IBOutlet UILabel *lblPrice;
    IBOutlet UILabel *lblDescription;
    NSString *sim_type;
    NSMutableDictionary *jsonData;
    NSArray *intlPlanArray;
    NSMutableDictionary *productplans;
    NSMutableArray *productPlan;
    NSMutableArray *productPlanArray;
    UIImageView *imgBGIntl;
    UIImageView *imgProgressIntl;
    NSString *amountIntl;
    int personIntl;
    NSInteger selectedIntl;
    IBOutlet UIView *viewIntlPackHolder;
    IBOutlet UILabel *lblTotalPrice;
     NSString *amountUnli;
    int pending_fkbundleid;
    IBOutlet UILabel *lblIntlPackPrice;
     NSString *planID;
     NSData *urlData;
     NSMutableArray *phonesArray;
     int billingType;
    NSString *amountMBB;
    BOOL fromFB;
}
@property (nonatomic) BOOL fromFB;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *amountMBB;
@property (nonatomic) int billingType;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSString *planID;
@property (nonatomic) int pending_fkbundleid;
@property (strong, nonatomic) NSString *amountUnli;
@property (strong, nonatomic) NSString *amountIntl;
@property (nonatomic) int personIntl;
@property (nonatomic) NSInteger selectedIntl;
@property (strong, nonatomic) NSArray *intlPlanArray;
@property (strong, nonatomic) UIImageView *imgBGIntl;
@property (strong, nonatomic) UIImageView *imgProgressIntl;
@property (strong, nonatomic) NSMutableArray *productPlanArray;
@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableDictionary *productplans;
@property (strong, nonatomic) NSString *sim_type;
@property (strong, nonatomic) IBOutlet UIView *viewPlanHolder;
@property (strong, nonatomic) IBOutlet UILabel *lbl4G3G;
@property (strong, nonatomic) IBOutlet UIImageView *img4G3G;
@property (strong, nonatomic) IBOutlet UILabel *lblData;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) NSMutableDictionary *jsonData;

@property (strong, nonatomic) IBOutlet UIView *viewIntlPackHolder;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblIntlPackPrice;


- (IBAction)btnBack:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnSavePlan:(id)sender;


@end
