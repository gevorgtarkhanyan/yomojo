//
//  BoltOnHistoryTableViewCell.m
//  Yomojo
//
//  Created by Arnel Perez on 12/01/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "BoltOnHistoryTableViewCell.h"

@implementation BoltOnHistoryTableViewCell
@synthesize lblBoltonData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



@end
