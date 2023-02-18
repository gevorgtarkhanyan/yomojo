//
//  AddServiceFinalizeViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 01/06/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SEFilterControl.h"

@interface AddServiceFinalizeViewController : UIViewController
{
    MBProgressHUD *HUB;

    IBOutlet UIView *viewPlanHolder;
    IBOutlet UIView *viewIntlPackHolder;

    IBOutlet UILabel *lblData;
    IBOutlet UILabel *lbl4G3G;
    IBOutlet UILabel *lblPrice;
    IBOutlet UILabel *lblDescription;
    IBOutlet UILabel *lblTotalPrice;
    IBOutlet UILabel *lblIntlPackPrice;
    IBOutlet UILabel *lblSimNick;

    IBOutlet UIImageView *img4G3G;

    NSMutableDictionary *jsonData;
    NSMutableDictionary *productplans;

    NSArray *intlPlanArray;
    
    UIImageView *imgBGIntl;
    UIImageView *imgProgressIntl;
  
    NSInteger selectedIntl;
    NSData *urlData;
    
    NSString *intlID;
    NSString *dataID;
    NSString *packUnli;
    NSString *amountUnli;
    NSString *amountIntl;
    NSString *simNickName;
}
@property (strong, nonatomic) NSData *urlData;

@property (strong, nonatomic) NSString *dataID;
@property (strong, nonatomic) NSString *simNickName;
@property (strong, nonatomic) NSString *amountUnli;
@property (strong, nonatomic) NSString *amountIntl;
@property (strong, nonatomic) NSString *intlID;
@property (strong, nonatomic) NSString *packUnli;

@property (nonatomic) NSInteger selectedIntl;

@property (strong, nonatomic) UIImageView *imgBGIntl;
@property (strong, nonatomic) UIImageView *imgProgressIntl;

@property (strong, nonatomic) NSArray *intlPlanArray;
@property (strong, nonatomic) NSMutableDictionary *productplans;

@property (strong, nonatomic) IBOutlet UIImageView *img4G3G;

@property (strong, nonatomic) IBOutlet UIView *viewPlanHolder;
@property (strong, nonatomic) IBOutlet UIView *viewIntlPackHolder;

@property (strong, nonatomic) IBOutlet UILabel *lbl4G3G;
@property (strong, nonatomic) IBOutlet UILabel *lblData;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblIntlPackPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblSimNick;


@property (strong, nonatomic) NSMutableDictionary *jsonData;

- (IBAction)btnBack:(id)sender;
- (IBAction)btnSave:(id)sender;


@end
