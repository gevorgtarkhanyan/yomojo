//
//  NotificationTableViewCell.m
//  Yomojo
//
//  Created by Arnel Perez on 20/11/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell
@synthesize lblTitle, lblMessage, imgReadUnread,lblType;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
