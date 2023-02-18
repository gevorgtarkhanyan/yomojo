//
//  SideMenuViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 01/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMDropdownView.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface SideMenuViewController : UIViewController <LMDropdownViewDelegate,UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *HUB;
    NSData *urlData;
    int phonesArrayIndex;
    BOOL fromFB;
    
    NSString * strUserName;
    NSString * strPassword;
    NSString * phoneID;
  
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblNumber;
    IBOutlet UILabel *lblVersion;

    IBOutlet UIView *viewHolder;
    IBOutlet UITableView *tblMenuList;

    NSString *withFamily;
    NSString *showChildMenuOnly;
    NSString *noActiveService;

    UIPickerView *pickerAccountList;

    NSMutableArray *phonesArray;
    NSMutableArray *arrayMenuList;
    NSMutableArray *phonesArrayNew;
    NSMutableDictionary *productPlans;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL fromFB;
@property (strong, nonatomic) NSData *urlData;

@property (nonatomic) int phonesArrayIndex;

@property (strong, nonatomic) NSString * phoneID;
@property (strong, nonatomic) NSString *withFamily;
@property (strong, nonatomic) NSString * strUserName;
@property (strong, nonatomic) NSString * strPassword;
@property (strong, nonatomic) NSString *noActiveService;
@property (strong, nonatomic) NSString *showChildMenuOnly;

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;

@property (strong, nonatomic) NSMutableArray *arrayAccountList;
@property (strong, nonatomic) LMDropdownView *dropdownView;

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) IBOutlet UITableView *tblMenuList;

@property (strong, nonatomic) IBOutlet UIView *viewHolder;
@property (strong, nonatomic) IBOutlet UIImageView *imgNavBar;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableDictionary *productPlans;

@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSMutableArray *arrayMenuList;
@property (strong, nonatomic) NSMutableArray *phonesArrayNew;

- (IBAction)btnMenu:(id)sender;

@end
