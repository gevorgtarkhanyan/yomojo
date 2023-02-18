//
//  BoltOnHistoryCell.m
//  Yomojo
//
//  Created by Suren Poghosyan on 2/28/19.
//  Copyright © 2019 AcquireBPO. All rights reserved.
//

#import "BoltOnHistoryCell.h"

@implementation BoltOnHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    self.boltOnSizeLabel.text = nil;
    self.purchasedDateLabel.text = nil;
    self.expiryDateLabel.text = nil;
}

@end
