//
//  HomeViewItemCell.m
//  MobKard
//
//  Created by Arnel Perez on 9/27/13.
//  Copyright (c) 2013 Arnel Perez. All rights reserved.
//

#import "HomeViewItemCell.h"
#import "LDProgressView.h"

@implementation HomeViewItemCell
@synthesize lblExpiry,lblNameText,dataProgress,lblUsage,usageProgress,iconImg,viewProgressHolder,btnBoltOn,btnBoltOnHistory, lblTotalData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)btnBoltOn:(id)sender {
    //NSLog(@"BoltON");
}

@end
