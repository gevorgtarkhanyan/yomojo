//
//  ChangePlanNextMonthViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 23/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEFilterControl.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ChangePlanNextMonthViewController : UIViewController{
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *tableViewNextMonth;
    
    MBProgressHUD *HUB;
    
    UIImageView *imgProgressVoice;
    UIImageView *imgBG;
    
    UIImageView *imgProgressSMS;
    UIImageView *imgBGSMS;
    
    UIImageView *imgProgressData;
    UIImageView *imgBGData;

    UIImageView *imgProgressIntl;
    UIImageView *imgBGIntl;
    
    UIImageView *imgProgressIntlUnli;
    UIImageView *imgBGIntlUnli;
    
    UIImageView *imgProgressUnli;
    UIImageView *imgBGUnli;

    UIImageView *imgProgressMBB;
    UIImageView *imgBGMBB;
    
    NSString *amountVoice;
    NSString *amountSMS;
    NSString *amountData;
    NSString *amountIntl;
    NSString *amountMBB;
    
    NSInteger selectedVoice;
    NSInteger selectedSMS;
    NSInteger selectedData;
    NSInteger selectedIntl;
    NSInteger selectedUnli;
    NSInteger selectedMBB;

    NSMutableDictionary *productplans;
    NSArray *voicePlanArray;
    NSArray *smsPlanArray;
    NSArray *dataPlanArray;
    NSArray *intlPlanArray;
    NSArray *mbbPlanArray;
    
    NSString *pendingPlansService;
    
    NSString *mbbThisMonthTotal;

    NSMutableDictionary *bundlesPlans;
    float newTotalPrice;
    IBOutlet UITableView *tableViewUnli;
    IBOutlet UIImageView *imgLine;
    NSMutableArray * arrayUnliBundles;
    IBOutlet UILabel *lblMobileBroadband;
    IBOutlet UITableView *tableViewMBB;

    int billingType;
    int unliData;
    int unliIntl;
    int unliTopup;
    int personVoice;
    int personSMS;
    int personData;
    int personIntl;
    int personTopup;
    int mbbBundle;
    NSString *planID;
    int pending_fkbundleid;
    int isUnliPlan;
    
    NSMutableArray *productPlan;
    NSMutableArray *productPlanArray;
    BOOL accountUnli;
    
    NSMutableDictionary *mbbPlans;
    NSString * missingID;
    NSString * missingIDMBB;
    int initalLoadUnli;
    int initialLoadIntl;
    int initialLoadMBB;
    int initialLoadPersonal;
    NSString *thisMonthPrice;
    NSString *plans3G_4G;
    
    NSString *amountUnliPending;
    int unliDataPending;
    NSInteger selectedUnliPending;
    NSMutableArray * pendingProduct;
    IBOutlet UITextView *textView;
    NSString *thisMonthAmountUnli;
}

@property (nonatomic) int isUnliPlan;
@property (strong, nonatomic) NSString *thisMonthAmountUnli;
@property (strong, nonatomic) NSString *plans3G_4G;
@property (strong, nonatomic) NSString *missingID;
@property (strong, nonatomic) NSString * missingIDMBB;
@property (strong, nonatomic) NSString * mbbThisMonthTotal;
@property (nonatomic) BOOL accountUnli;
@property (nonatomic) int initialLoadPersonal;
@property (nonatomic) int initalLoadUnli;
@property (nonatomic) int initialLoadIntl;
@property (nonatomic) int initialLoadMBB;
@property (nonatomic) int billingType;
@property (nonatomic) int unliData;
@property (nonatomic) int unliIntl;
@property (nonatomic) int unliTopup;
@property (nonatomic) int personVoice;
@property (nonatomic) int personSMS;
@property (nonatomic) int personData;
@property (nonatomic) int personIntl;
@property (nonatomic) int personTopup;
@property (nonatomic) int mbbBundle;
@property (nonatomic) int pending_fkbundleid;
@property (nonatomic) float newTotalPrice;
@property (nonatomic) NSInteger selectedVoice;
@property (nonatomic) NSInteger selectedSMS;
@property (nonatomic) NSInteger selectedData;
@property (nonatomic) NSInteger selectedIntl;
@property (nonatomic) NSInteger selectedUnli;
@property (nonatomic) NSInteger selectedMBB;
@property (strong, nonatomic) NSString *pendingPlansService;
@property (strong, nonatomic) NSString *amountVoice;
@property (strong, nonatomic) NSString *amountSMS;
@property (strong, nonatomic) NSString *amountData;
@property (strong, nonatomic) NSString *amountIntl;
@property (strong, nonatomic) NSString *amountUnli;
@property (strong, nonatomic) NSString *amountMBB;
@property (strong, nonatomic) NSString *planID;
@property (strong, nonatomic) UIImageView *imgBGIntl;
@property (strong, nonatomic) UIImageView *imgProgressIntl;
@property (strong, nonatomic) UIImageView *imgBGIntlUnli;
@property (strong, nonatomic) UIImageView *imgProgressIntlUnli;
@property (strong, nonatomic) UIImageView *imgBGData;
@property (strong, nonatomic) UIImageView *imgProgressData;
@property (strong, nonatomic) UIImageView *imgBG;
@property (strong, nonatomic) UIImageView *imgProgressVoice;
@property (strong, nonatomic) UIImageView *imgProgressSMS;
@property (strong, nonatomic) UIImageView *imgBGSMS;
@property (strong, nonatomic) UIImageView *imgProgressUnli;
@property (strong, nonatomic) UIImageView *imgBGUnli;
@property (strong, nonatomic) UIImageView *imgProgressMBB;
@property (strong, nonatomic) UIImageView *imgBGMBB;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) IBOutlet UIView *personalizedView;
@property (strong, nonatomic) IBOutlet UIView *unlimitedView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UITableView *tableViewNextMonth;
@property (strong, nonatomic) NSMutableDictionary *productplans;
@property (strong, nonatomic) NSMutableDictionary *mbbPlans;
@property (strong, nonatomic) NSArray *voicePlanArray;
@property (strong, nonatomic) NSArray *smsPlanArray;
@property (strong, nonatomic) NSArray *dataPlanArray;
@property (strong, nonatomic) NSArray *intlPlanArray;
@property (strong, nonatomic) NSArray *mbbPlanArray;
@property (strong, nonatomic) NSMutableDictionary *bundlesPlans;
@property (strong, nonatomic) IBOutlet UITableView *tableViewUnli;
@property (strong, nonatomic) NSMutableArray * arrayUnliBundles;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine;
@property (strong, nonatomic) IBOutlet UILabel *lblMobileBroadband;
@property (strong, nonatomic) IBOutlet UITableView *tableViewMBB;

@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableArray *productPlanArray;

@property (strong, nonatomic) NSMutableArray * pendingProduct;

@property (strong, nonatomic) NSString *amountUnliPending;
@property (nonatomic) int unliDataPending;
@property (nonatomic) NSInteger selectedUnliPending;

- (IBAction)segmentSelected:(id)sender;
- (IBAction)actionSliderVoice:(SEFilterControl *) sender;
- (IBAction)btnMenu:(id)sender;
- (IBAction)btnChat:(id)sender;
- (IBAction)btnCallNumber:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *textView;


@end
