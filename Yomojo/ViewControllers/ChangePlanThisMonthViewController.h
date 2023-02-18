//
//  ChangePlanThisMonthViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 23/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ChangePlanThisMonthViewController : UIViewController{
    MBProgressHUD *HUB;
    NSMutableArray *productPlan;
    NSMutableArray *productPlanArray;
    IBOutlet UITableView *tblViewThisMonthData;
    NSMutableDictionary *productplans;
    float newTotalPrice;
}
@property (nonatomic) float newTotalPrice;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableArray *productPlanArray;
@property (strong, nonatomic) NSMutableDictionary *productplans;
@property (strong, nonatomic) NSMutableArray *bolton;
@property (strong, nonatomic) NSMutableArray *boltonHistoryArray;
@property (strong, nonatomic) IBOutlet UITableView *tblViewThisMonthData;

- (IBAction)btnMenu:(id)sender;


@end
