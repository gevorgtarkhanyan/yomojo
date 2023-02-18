//
//  NoServiceViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 04/07/2018.
//  Copyright © 2018 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface NoServiceViewController : UIViewController
{
    MBProgressHUD *HUB;
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *withFamily;
    BOOL fromFB;
    IBOutlet UIButton *btnLabelGotoFamily;
    IBOutlet UIButton *btnLabelAddService;
    
    IBOutlet UIView *viewAds;
    IBOutlet UIImageView *imgAdsImage;
    IBOutlet UIView *viewAdsHolder;
    NSString * adsURL_link;
    BOOL fromLogin;
    NSString *clientID;
    NSString *adsID;
    IBOutlet UIImageView *imgResizeImg;
}
@property (strong, nonatomic) NSString *adsID;
@property (strong, nonatomic) NSString *clientID;
@property (nonatomic) BOOL fromLogin;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSString *withFamily;
@property (nonatomic) BOOL fromFB;

@property (strong, nonatomic) IBOutlet UIButton *btnLabelGotoFamily;
@property (strong, nonatomic) IBOutlet UIButton *btnLabelAddService;

@property (strong, nonatomic) IBOutlet UIView *viewAds;
@property (strong, nonatomic) IBOutlet UIImageView *imgAdsImage;
@property (strong, nonatomic) IBOutlet UIView *viewAdsHolder;
@property (strong, nonatomic) NSString * adsURL_link;

@property (strong, nonatomic) IBOutlet UIImageView *imgResizeImg;


- (IBAction)adsExit:(id)sender;
- (IBAction)adsTap:(id)sender;

- (IBAction)btnAddService:(id)sender;
- (IBAction)btnGotoFamily:(id)sender;
- (IBAction)btnMenu:(id)sender;
- (IBAction)btnAddMobileService:(id)sender;

@end
