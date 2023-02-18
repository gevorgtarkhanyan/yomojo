//
//  QuickGlanceViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 11/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface QuickGlanceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *HUB;
    NSData *urlData;
    NSMutableArray *phonesArray;
    IBOutlet UILabel *lblNumber;
    NSString *clientID;
    NSString *sessionID;
    NSString *billday;
    NSString * phoneID;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblDueDate;
    NSMutableArray *productPlanArray;
    NSMutableArray *productPlan;
    IBOutlet UITableView *MIMtableView;
    NSString * payg;
    IBOutlet UIPageControl *pagingControl;
    NSString *validbolton;
    float totalBoltON;
    NSMutableDictionary *resource;
}
@property (strong, nonatomic) NSMutableDictionary *resource;
@property (nonatomic) float totalBoltON;
@property (strong, nonatomic) NSString * validbolton;
@property (strong, nonatomic) NSString * payg;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableArray *productPlanArray;
@property (strong, nonatomic) IBOutlet UILabel *lblNumber;
@property (strong, nonatomic) NSString * phoneID;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblDueDate;
@property (strong, nonatomic) IBOutlet UITableView *MIMtableView;
@property (strong, nonatomic) IBOutlet UIPageControl *pagingControl;


- (IBAction)btnLogin:(id)sender;
- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender;

@end
