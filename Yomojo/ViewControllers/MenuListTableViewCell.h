//
//  MenuListTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 06/11/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListTableViewCell : UITableViewCell
{
     IBOutlet UILabel *lblMenuTitle;
    IBOutlet UILabel *lblUnreadNotif;
}
@property (strong, nonatomic) IBOutlet UILabel *lblMenuTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblUnreadNotif;

@end
