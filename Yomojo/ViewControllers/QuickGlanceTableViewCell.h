//
//  QuickGlanceTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 20/07/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickGlanceTableViewCell : UITableViewCell
{
     IBOutlet UILabel *lblNameText;
     IBOutlet UILabel *lblRemainingValue;
     IBOutlet UILabel *lblRemaining;
     IBOutlet UILabel *lblExpiry;
}
@property (strong, nonatomic) IBOutlet UILabel *lblExpiry;
@property (strong, nonatomic) IBOutlet UILabel *lblNameText;
@property (strong, nonatomic) IBOutlet UILabel *lblRemainingValue;
@property (strong, nonatomic) IBOutlet UILabel *lblRemaining;
@end
