//
//  NotificationsViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 20/11/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface NotificationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD *HUB;
    IBOutlet UITableView *NotifTableList;
    NSMutableArray * arrayRemoteNotifiInfo;
    IBOutlet UILabel *lblCheckNotifications;
    NSString *clientID;
    NSString *sessionID;
    NSData *urlData;
    NSMutableArray * notifArrayData;
    NSMutableArray *phonesArrayNew;
    NSString *withFamily;
    NSUInteger indexToRemove;
}
@property (nonatomic) NSUInteger indexToRemove;
@property (strong, nonatomic) NSMutableArray *phonesArrayNew;
@property (strong, nonatomic) NSString *withFamily;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSString * clientID;
@property (strong, nonatomic) NSString * sessionID;
@property (strong, nonatomic) IBOutlet UITableView *NotifTableList;
@property (strong, nonatomic) NSMutableArray * arrayRemoteNotifiInfo;
@property (strong, nonatomic) NSMutableArray * notifArrayData;
@property (strong, nonatomic) IBOutlet UILabel *lblCheckNotifications;




- (IBAction)btnBack:(id)sender;

@end
