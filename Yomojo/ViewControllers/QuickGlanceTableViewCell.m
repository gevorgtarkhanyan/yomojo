//
//  QuickGlanceTableViewCell.m
//  Yomojo
//
//  Created by Arnel Perez on 20/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "QuickGlanceTableViewCell.h"

@implementation QuickGlanceTableViewCell
@synthesize  lblNameText, lblRemainingValue, lblRemaining, lblExpiry;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
