//
//  AccountListViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 02/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountListViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
{
    NSData *urlData;
    NSMutableArray *phonesArray;
    IBOutlet UITableView *MIMtableView;
    NSString *withFamily;
}
@property(nonatomic,retain)IBOutlet UITableView *MIMtableView;
@property (strong, nonatomic) NSData *urlData;
@property (strong, nonatomic) NSMutableArray *phonesArray;
@property (strong, nonatomic) NSString *withFamily;

- (IBAction)btnBack:(id)sender;

@end
