//
//  ContactDetailsTableViewCell.h
//  Yomojo
//
//  Created by Arnel Perez on 02/03/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactDetailsTableViewCell : UITableViewCell
{
    IBOutlet UITextField *txtEmailAdd;
    IBOutlet UITextField *txtAddress;
}
@property (strong, nonatomic) IBOutlet UITextField *txtEmailAdd;
@property (strong, nonatomic) IBOutlet UITextField *txtAddress;
@end
