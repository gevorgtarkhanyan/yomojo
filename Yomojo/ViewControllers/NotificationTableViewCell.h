//
//  NotificationTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 20/11/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblMessage;
    IBOutlet UIImageView *imgReadUnread;
    IBOutlet UILabel *lblType;
}

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIImageView *imgReadUnread;
@property (strong, nonatomic) IBOutlet UILabel *lblDateAdded;
@property (strong, nonatomic) IBOutlet UILabel *lblType;

@end
