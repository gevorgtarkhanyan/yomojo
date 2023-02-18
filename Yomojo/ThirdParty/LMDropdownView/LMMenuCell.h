//
//  LMMenuCell.h
//  LMDropdownViewDemo
//
//  Created by LMinh on 16/07/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMMenuCell : UITableViewCell
{
    IBOutlet UILabel *menuItemLabel;
    IBOutlet UIImageView *selectedMarkView;
}

@property (strong, nonatomic) IBOutlet UILabel *menuItemLabel;
@property (strong, nonatomic) IBOutlet UIImageView *selectedMarkView;

@end
