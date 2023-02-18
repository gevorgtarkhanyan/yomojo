//
//  HomeViewItemCell.h
//  MobKard
//
//  Created by Arnel Perez on 9/27/13.
//  Copyright (c) 2013 Arnel Perez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewItemCell : UITableViewCell{
            
    IBOutlet UIView *dataProgress;
    IBOutlet UIView *viewProgressHolder;
    
    IBOutlet UIButton *btnBoltOn;
    IBOutlet UIButton *btnBoltOnHistory;

    IBOutlet UILabel *lblUsage;
    IBOutlet UILabel *lblUnits;
    IBOutlet UILabel *lblExpiry;
    IBOutlet UILabel *lblTotalData;
    IBOutlet UIImageView *iconImg;
    IBOutlet UIProgressView *usageProgress;

}

@property (strong, nonatomic) IBOutlet UIProgressView *usageProgress;
@property (strong, nonatomic) IBOutlet UIImageView *iconImg;

@property (strong, nonatomic) IBOutlet UIView *dataProgress;
@property (strong, nonatomic) IBOutlet UIView *viewProgressHolder;

@property (strong, nonatomic) IBOutlet UILabel *lblUnits;
@property (strong, nonatomic) IBOutlet UILabel *lblUsage;
@property (strong, nonatomic) IBOutlet UILabel *lblExpiry;
@property (strong, nonatomic) IBOutlet UILabel *lblNameText;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalData;

@property (strong, nonatomic) IBOutlet UIButton *btnBoltOn;
@property (strong, nonatomic) IBOutlet UIButton *btnBoltOnHistory;

@end
