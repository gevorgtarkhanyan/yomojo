//
//  MainViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 01/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import "BEMCheckBox.h"
//#import "CustomIOSAlertView.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,BEMCheckBoxDelegate, UIAlertViewDelegate>
{

    TSPopoverController *popoverController;
    MBProgressHUD *HUB;
    NSString *clientID;
    NSString *sessionID;
    NSString *payg;
    NSMutableDictionary *resource;
    NSString *ExcessCreditBalance;
    NSString *waitingTextInCells;
    IBOutlet UITableView *MIMtableView;
    IBOutlet UITableView *tableViewInactive;

    IBOutlet NSLayoutConstraint *topUpBtnBottomConstraint;
    IBOutlet UILabel *noPlanLabel;

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPortingMessage;
    IBOutlet UIView *lblPortingMessageContainer;
    IBOutlet NSLayoutConstraint *lblPortingMessageTop;
    IBOutlet NSLayoutConstraint *lblPortingMessageBottom;

    int phoneItemSelected;
    IBOutlet UILabel *lblNumber;
    IBOutlet UILabel *lblBalance;
    IBOutlet UILabel *lblDueDate;
    IBOutlet UILabel *lblActivateDate;
    NSMutableArray *productPlan;
    NSMutableArray *productPlanArray;
    
    NSData *urlData;
    NSMutableArray *phonesArray;
    int phonesArrayIndex;
    NSString * phoneID;
    NSString * planID;
    
    int billingType;
    NSString *billday;
    NSString *accountBalance;
    
    IBOutlet UIButton *topupButton;
    IBOutlet UILabel *lblAvailableCredit;
    
    IBOutlet UIButton *btnAccountList;
    UIPickerView *pickerAccountList;
    
    NSString *strUserName;
    NSString *strPassword;

    NSMutableArray *xmlOutputData;
    NSMutableString *nodecontent;
    NSXMLParser *xmlParserObject;
    
    IBOutlet UIView *viewBoltOnPopup;
    
    NSMutableArray *arrayBoltOnLookUp;
    IBOutlet UIButton *btnBoltOnChoices;
    UIPickerView *pickerBoltOnChoices;
    IBOutlet UITextField *txtBoltOnAmount;
    NSString *strBoltOnId;

    IBOutlet UIView *viewBoltOnHistory;
    
    IBOutlet UIView *boltOnHistoryView;
    NSMutableArray *bolton;
    NSMutableArray *boltonHistoryArray;
    
    IBOutlet UITextView *viewBoltOnHistoryList;
    IBOutlet UILabel *testLabel;
    
    IBOutlet UIButton *btnAddBoltOn;
    
    int intBoltTotal;
    IBOutlet NSString *lblDateRange;
    IBOutlet UILabel *lblTotalValue;
    
    NSInteger selectedBoltOnIndex;
    
    IBOutlet UIButton *btnCancelBoltOn;
    BEMCheckBox *myCheckBox;
    NSInteger selectedCell;
    BOOL boltOnButtonCreated;
    IBOutlet UIImageView *imgNavBar;
    UITabBarController *tabBarController;
    
    BOOL accountUnli;
    BOOL fromFB;
    
    NSString *validbolton;

    IBOutlet UIView *viewBoltOn;
    IBOutlet UIView *viewBoltOnBG;
    IBOutlet UIButton *btnBoltOnHistoryNew;
    
    NSString *withFamily;
     IBOutlet UIImageView *imgUnreadNotif;
    NSMutableDictionary *resultDataForUsage;
    
    NSString *current_fkbundleid;
    NSString *billDuration;
    
    UIAlertView *addBoltOnAlert;
    NSString *lblExcessCreditExpiry;

    BOOL noActiveService;

    IBOutlet UIView *viewAds;
    IBOutlet UILabel *lblSummary;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *imgAdsImage;
    IBOutlet UIView *viewAdsHolder;
    NSString * adsURL_link;
    NSString *adsID;
    NSString *autoActivatedate;
    BOOL fromLogin;
    BOOL containsIntlVoice;
    IBOutlet UIButton *btnChangePlanProp;
    IBOutlet UIButton *btnActivateSimProp;
}
@property (nonatomic) BOOL fromLogin;
@property (nonatomic) BOOL containsIntlVoice;
@property (strong, nonatomic) NSString *autoActivatedate;
@property (strong, nonatomic) NSString *adsID;
@property (strong, nonatomic) NSString *lblExcessCreditExpiry;
@property (strong, nonatomic) NSString *ExcessCreditBalance;
@property (strong, nonatomic) NSString *billDuration;
@property (strong, nonatomic) NSString *current_fkbundleid;
@property (strong, nonatomic) NSMutableDictionary *resultDataForUsage;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UIImageView *imgUnreadNotif;
@property (nonatomic) BOOL fromFB;
@property (nonatomic) BOOL noActiveService;
@property (strong, nonatomic) NSString *waitingTextInCells;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property(nonatomic) NSInteger selectedCell;
@property (nonatomic) BEMCheckBox *myCheckBox;
@property (nonatomic) NSInteger selectedBoltOnIndex;
@property (strong, nonatomic) IBOutlet UILabel *lblAvailableCredit;
@property(nonatomic,retain)IBOutlet UITableView *MIMtableView;

@property(nonatomic,retain)IBOutlet UITableView *tableViewInactive;

@property (strong, nonatomic) IBOutlet UIButton *topupButton;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPortingMessage;
@property (strong, nonatomic) IBOutlet UIView *lblPortingMessageContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblPortingMessageTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblPortingMessageBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topUpBtnBottomConstraint;
@property (strong, nonatomic) IBOutlet UILabel *noPlanLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblBalance;
@property (strong, nonatomic) IBOutlet UILabel *lblDueDate;
@property (strong, nonatomic) IBOutlet UILabel *lblActivateDate;

@property (strong, nonatomic) NSString *accountBalance;

@property (strong, nonatomic) NSMutableArray *productPlan;
@property (strong, nonatomic) NSMutableArray *productPlanArray;

@property (strong, nonatomic) NSMutableArray *bolton;
@property (strong, nonatomic) NSMutableArray *boltonHistoryArray;


@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSString * phoneID;
@property (strong, nonatomic) NSString * planID;
@property (strong, nonatomic) NSString * payg;
@property (strong, nonatomic) NSString * billday;
@property (nonatomic) int phonesArrayIndex;

@property (strong, nonatomic) NSMutableDictionary *resource;
@property (strong, nonatomic) NSString * strUserName;
@property (strong, nonatomic) NSString * strPassword;
@property (strong, nonatomic) NSString * validbolton;

@property (strong, nonatomic) IBOutlet UIButton *btnAccountList;

@property (strong, nonatomic) IBOutlet UIView *viewBoltOnPopup;
@property (strong, nonatomic) IBOutlet UIButton *btnBoltOnChoices;
@property (strong, nonatomic) IBOutlet UITextField *txtBoltOnAmount;
@property (strong, nonatomic) NSString * strBoltOnId;
@property (strong, nonatomic) IBOutlet UIView *viewBoltOnHistory;

@property (strong, nonatomic) IBOutlet UIView *boltOnHistoryView;

@property (strong, nonatomic) IBOutlet UITextView *viewBoltOnHistoryList;

@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnAddBoltOn;
@property (strong, nonatomic) IBOutlet NSString *lblDateRange;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalValue;
@property (strong, nonatomic) IBOutlet UIButton *btnCancelBoltOn;
@property (strong, nonatomic) IBOutlet UITableView *boltOnListTable;
@property (strong, nonatomic) IBOutlet UIImageView *imgNavBar;

@property (strong, nonatomic) IBOutlet UIView *viewBoltOn;
@property (strong, nonatomic) IBOutlet UIView *viewBoltOnBG;
@property (strong, nonatomic) IBOutlet UIButton *btnBoltOnHistoryNew;
@property (strong, nonatomic) NSString *withFamily;
@property (strong, nonatomic) IBOutlet UIView *bannerView;
@property (strong, nonatomic) IBOutlet UIButton *closeButtonBanner;
@property (strong, nonatomic) IBOutlet UIButton *bannerMoreButton;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeButtonHeight;



@property (strong, nonatomic) IBOutlet UIView *viewAds;
@property (strong, nonatomic) IBOutlet UILabel *lblSummary;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgAdsImage;
@property (strong, nonatomic) IBOutlet UIView *viewAdsHolder;
@property (strong, nonatomic) NSString * adsURL_link;
@property (strong, nonatomic) IBOutlet UIButton *btnChangePlanProp;
@property (strong, nonatomic) IBOutlet UIButton *btnActivateSimProp;


- (IBAction)adsExit:(id)sender;
- (IBAction)adsTap:(id)sender;

- (IBAction)btRefresh:(id)sender;
- (IBAction)btnShowMenu:(id)sender;
- (IBAction)btnTopUp:(id)sender;
- (IBAction)btnUsageHistory:(id)sender;
- (IBAction)btnChangePlan:(id)sender;
- (IBAction)btnBoltOnHistoryNew:(id)sender;
- (IBAction)btnActivateSIM:(id)sender;


@end
