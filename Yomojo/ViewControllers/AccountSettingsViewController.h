//
//  AccountSettingsViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 17/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRNCollapsableSectionTableViewController.h"
#import "ContactDetailsViewController.h"
#import "CreditCardDetailsViewController.h"
#import "UpdatePasswordViewController.h"
#import "SimsAndDevicesViewController.h"
#import "EnableQuickGlanceViewController.h"


@interface AccountSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSData *urlData;
    NSMutableArray *phonesArray;
    NSString *txtEmailAdd;
    IBOutlet UITextField *txtDummy;
    NSString *clientID;
    NSString *sessionID;
    int phonesArrayIndex;
    NSMutableArray *xmlOutputData;
    NSMutableString *nodecontent;
    NSXMLParser *xmlParserObject;
    BOOL fromFB;
}

@property (nonatomic) BOOL fromFB;
@property (nonatomic) int phonesArrayIndex;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSString *txtEmailAdd;
@property (strong, nonatomic) IBOutlet UITextField *txtDummy;
@property (strong, nonatomic) ContactDetailsViewController *contactDetailsViewController;
@property (strong, nonatomic) CreditCardDetailsViewController *creditCardDetailsViewController;
@property (strong, nonatomic) UpdatePasswordViewController *updatePasswordViewController;
@property (strong, nonatomic) SimsAndDevicesViewController *simsAndDevicesViewController;
@property (strong, nonatomic) EnableQuickGlanceViewController *quickGlanceViewController;

- (IBAction)btnBack:(id)sender;


@end
