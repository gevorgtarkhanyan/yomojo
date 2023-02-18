//
//  BoltOnHistoryCell.h
//  Yomojo
//
//  Created by Suren Poghosyan on 2/28/19.
//  Copyright © 2019 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoltOnHistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *boltOnSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *purchasedDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *expiryDateLabel;
@end

