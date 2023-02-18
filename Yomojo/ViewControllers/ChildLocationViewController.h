//
//  ChildLocationViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ChildLocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,BEMCheckBoxDelegate>
{
    MBProgressHUD *HUB;
    BEMCheckBox *myCheckBox;
    IBOutlet UITableView *tableChild;
    NSMutableArray *childArray;
    NSInteger selectedCell;
    NSData *urlData;
    NSString * clientID;
    NSString * sessionID;
    NSString * authToken;
    NSMutableDictionary * photoInfo;
    NSMutableDictionary * onlineInfo;
    NSMutableArray * selectedChild;
    NSString * LCURLLocation;
    IBOutlet UIButton *showLocationBtn;
    NSMutableDictionary * childPhotoURL;
}
@property (strong, nonatomic) NSMutableDictionary * childPhotoURL;
@property (nonatomic) BEMCheckBox *myCheckBox;
@property (strong, nonatomic) NSString * clientID;
@property (strong, nonatomic) NSString * sessionID;
@property (strong, nonatomic) NSString * authToken;
@property (strong, nonatomic) NSString * LCURLLocation;
@property (strong, nonatomic) NSMutableDictionary * photoInfo;
@property (strong, nonatomic) NSMutableDictionary * onlineInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableChild;
@property (strong, nonatomic) NSMutableArray *childArray;
@property (strong, nonatomic) NSMutableArray * selectedChild;
@property(nonatomic) NSInteger selectedCell;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) IBOutlet UIButton *showLocationBtn;


- (IBAction)btnBack:(id)sender;
- (IBAction)btnRetrieveLocation:(id)sender;

@end
