//
//  AccountViewItemCell.h
//  Yomojo
//
//  Created by Arnel Perez on 02/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewItemCell : UITableViewCell {
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblNumber;
}

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblNumber;

@end
