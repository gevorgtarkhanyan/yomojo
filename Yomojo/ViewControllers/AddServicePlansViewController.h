//
//  AddServicePlansViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 01/06/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface AddServicePlansViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    MBProgressHUD *HUB;
    IBOutlet UITableView *tblPacks;
    NSMutableArray *arrayUnliBundles;
    NSArray *mbbPlanArray;
    NSString *planID;
    NSString *simNickName;
    NSString *packUnli;
    NSString *portMobile;
    IBOutlet UILabel *lblPleaseSelectPlan;
    NSMutableDictionary *mbbPlans;
    NSData *urlData;
}

@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableDictionary *mbbPlans;
@property (strong, nonatomic) IBOutlet UITableView *tblPacks;
@property (strong, nonatomic) NSMutableArray *arrayUnliBundles;
@property (strong, nonatomic) NSArray *mbbPlanArray;
@property (strong, nonatomic) NSString *planID;
@property (strong, nonatomic) NSString *simNickName;
@property (strong, nonatomic) NSString *packUnli;
@property (strong, nonatomic) NSString *portMobile;
@property (strong, nonatomic) IBOutlet UILabel *lblPleaseSelectPlan;

- (IBAction)btnBack:(id)sender;


@end
