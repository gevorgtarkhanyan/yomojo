//
//  ChangePlanViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 28/03/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEFilterControl.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ChangePlanViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *HUB;
    
    IBOutlet UIView *viewBundlePlans;
    IBOutlet UIView *viewIntlPackHolder;
    IBOutlet UIView *viewSliderHolder;
    
    IBOutlet UILabel *lblIntlPackPrice;
    IBOutlet UILabel *lblThisMonthPrice;
    IBOutlet UILabel *lblBundlePlanData;
    IBOutlet UILabel *lblNextmonthAmount;
    IBOutlet UILabel *lblBundlePlansDescription;
    
    IBOutlet UITableView *tableBundles;
    
    NSData *urlData;
    BOOL accountUnli;
    
    int billingType;
    int personIntl;
    int unliDataPending;
    int unliData;
    int currentPlanUnliIndex;
    int pending_fkbundleid;
    int isUnliPlan;
    int mbbBundle;
    int cuurentID;
    
    NSString *planID;
    NSString *missingID;
    NSString *missingIDMBB;
    NSString *fkbundleid;
    NSString *amountIntl;
    NSString * selectedUnliStr;
    NSString *amountUnli;
    NSString *oldSimType;
    NSString *amountUnliPending;
    NSString *pendingPlansService;
    NSString *currentPlanFromMissing;
    NSString *amountMBB;
    
    NSInteger selectedIntl;
    NSInteger selectedUnli;
    NSInteger selectedMBB;
    NSInteger pendingMBB;
    
    UIImageView *imgProgressIntl;
    UIImageView *imgBGIntl;
    
    NSArray *mbbPlanArray;
    NSArray *intlPlanArray;
    NSArray *productPlanFromMainVC;
    
    NSMutableArray *productPlan;
    NSMutableArray *productPlanArray;
    NSMutableArray *pendingProduct;
    NSMutableArray *arrayUnliBundles;
    NSMutableArray *phonesArray;
    
    NSMutableDictionary *mbbPlans;
    NSMutableDictionary *productplans;
    NSMutableDictionary *jsonDataSubmit;
}

@property (strong, nonatomic) NSString *fkbundleid;
@property (strong, nonatomic) NSString *currentPlanFromMissing;
@property (strong, nonatomic) NSString *amountMBB;
@property (strong, nonatomic) NSString *pendingPlansService;
@property (strong, nonatomic) NSString *oldSimType;
@property (strong, nonatomic) NSString *amountUnli;
@property (strong, nonatomic) NSString * selectedUnliStr;
@property (strong, nonatomic) NSString *amountIntl;
@property (strong, nonatomic) NSString *planID;
@property (strong, nonatomic) NSString *missingID;
@property (strong, nonatomic) NSString * missingIDMBB;
@property (strong, nonatomic) NSString *amountUnliPending;

@property (nonatomic) int unliData;
@property (nonatomic) int cuurentID;
@property (nonatomic) int mbbBundle;
@property (nonatomic) int personIntl;
@property (nonatomic) int isUnliPlan;
@property (nonatomic) int billingType;
@property (nonatomic) int unliDataPending;
@property (nonatomic) int pending_fkbundleid;
@property (nonatomic) int currentPlanUnliIndex;

@property (nonatomic) BOOL accountUnli;

@property (nonatomic) NSInteger pendingMBB;
@property (nonatomic) NSInteger selectedMBB;
@property (nonatomic) NSInteger selectedUnli;
@property (nonatomic) NSInteger selectedIntl;

@property (strong, nonatomic) NSArray *mbbPlanArray;
@property (strong, nonatomic) NSArray *intlPlanArray;
@property (strong, nonatomic) NSArray *productPlanFromMainVC;

@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableArray *pendingProduct;
@property (strong, nonatomic) NSMutableArray *arrayUnliBundles;
@property (strong, nonatomic) NSMutableArray *productPlanArray;

@property (strong, nonatomic) NSMutableDictionary *mbbPlans;
@property (strong, nonatomic) NSMutableDictionary *productplans;
@property (strong, nonatomic) NSMutableDictionary *jsonDataSubmit;

@property (strong, nonatomic) UIImageView *imgBGIntl;
@property (strong, nonatomic) UIImageView *imgProgressIntl;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSData *urlData;

@property (strong, nonatomic) IBOutlet UIView *viewBundlePlans;
@property (strong, nonatomic) IBOutlet UIView *viewIntlPackHolder;

@property (strong, nonatomic) IBOutlet UIImageView *imgBGColor;
@property (strong, nonatomic) IBOutlet UITableView *tableBundles;

@property (strong, nonatomic) IBOutlet UILabel *lbl4G3G;
@property (strong, nonatomic) IBOutlet UILabel *lblIntlPackPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblThisMonthPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblBundlePlanData;
@property (strong, nonatomic) IBOutlet UILabel *lblNextmonthAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblBundlePlansDescription;

- (IBAction)btnBack:(id)sender;

@end
