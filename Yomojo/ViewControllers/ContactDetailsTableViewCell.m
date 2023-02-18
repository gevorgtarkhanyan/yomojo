//
//  ContactDetailsTableViewCell.m
//  Yomojo
//
//  Created by Arnel Perez on 02/03/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "ContactDetailsTableViewCell.h"

@implementation ContactDetailsTableViewCell
@synthesize txtAddress,txtEmailAdd;

- (void)awakeFromNib {
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [txtAddress resignFirstResponder];
    [txtEmailAdd resignFirstResponder];
}


@end
