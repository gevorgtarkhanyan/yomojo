//
//  ChildInfoTableViewCell.m
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "ChildInfoTableViewCell.h"

@implementation ChildInfoTableViewCell
@synthesize imgChild,lblChileName,imgChildOnlieStatus,lblChildStatus;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
