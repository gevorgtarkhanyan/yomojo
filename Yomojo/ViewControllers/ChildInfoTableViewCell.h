//
//  ChildInfoTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChildInfoTableViewCell : UITableViewCell
{
    IBOutlet UIImageView *imgChild;
    IBOutlet UILabel *lblChileName;
    IBOutlet UIImageView *imgChildOnlieStatus;
    IBOutlet UILabel *lblChildStatus;

}
@property (strong, nonatomic) IBOutlet UIImageView *imgChild;
@property (strong, nonatomic) IBOutlet UILabel *lblChileName;
@property (strong, nonatomic) IBOutlet UIImageView *imgChildOnlieStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblChildStatus;

@end
