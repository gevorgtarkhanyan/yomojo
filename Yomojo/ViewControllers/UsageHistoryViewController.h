//
//  UsageHistoryViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 17/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RRNCollapsableSectionTableViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface UsageHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *HUB;
    IBOutlet UISegmentedControl *segmentControl;
    NSMutableArray *segmentData;
    NSString *usageSelected;

    IBOutlet UITextField *txtFromDate;
    IBOutlet UITextField *txtToDate;
    NSMutableArray *arrayData;
    
    IBOutlet UIButton *btnFrom;
    UIDatePicker *fromPicker;
    
    IBOutlet UIButton *btnTo;
    UIDatePicker *toPicker;
    
    NSString *clientID;
    NSString *sessionID;
    NSString *phoneID;
    NSString *planID;
    NSString *billday;
    NSDate *defaultFromDate;
    NSDate *defaultToDate;
    NSMutableArray *usageData;
    
    //TableView Related
    NSMutableArray *sectionArray;
    NSMutableArray *cellArray;
    NSMutableArray *cellCount;
    NSMutableArray *arrayDates;
    NSMutableDictionary *datesTotal;
    BOOL BGColor;
    NSMutableDictionary *resultDataForUsage;
//    IBOutlet UILabel *lblTotalUsage;
    float totalUsage;
}
@property (nonatomic) float totalUsage;
@property (strong, nonatomic) NSMutableDictionary *resultDataForUsage;
@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSString *phoneID;
@property (strong, nonatomic) NSString *planID;
@property (strong, nonatomic) NSMutableArray *segmentData;
@property (strong, nonatomic) NSString *usageSelected;
@property (strong, nonatomic) NSString *billday;
@property (strong, nonatomic) NSDate *defaultFromDate;
@property (strong, nonatomic) NSDate *defaultToDate;
@property (assign, nonatomic) BOOL isHWBB;

@property (strong, nonatomic) NSMutableArray *usageData;
@property (strong, nonatomic) NSMutableArray *arrayDates;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UITextField *txtFromDate;
@property (strong, nonatomic) IBOutlet UITextField *txtToDate;
@property (strong, nonatomic) IBOutlet UIButton *btnFrom;
@property (strong, nonatomic) IBOutlet UIButton *btnTo;
//@property (strong, nonatomic) IBOutlet UILabel *lblTotalUsage;

- (IBAction)btnSaveHistory:(id)sender;
- (IBAction)btnBack:(id)sender;
- (IBAction)btnRefresh:(id)sender;
- (IBAction)usageSelect:(id)sender;
@end
