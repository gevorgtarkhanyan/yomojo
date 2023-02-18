//
//  RRNCollapsableTableViewController.h
//  RRNCollapsableSectionTableView
//
//  Created by Robert Nash on 08/09/2015.
//  Copyright (c) 2015 Robert Nash. All rights reserved.
//

#import "RRNCollapsableSectionHeaderProtocol.h"

@interface RRNCollapsableTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RRNCollapsableSectionHeaderReactiveProtocol>

//Override required
-(NSArray *)model;
-(UITableView *)collapsableTableView;
-(NSString *)sectionHeaderReuseIdentifier;

//Override optional
-(void)userTapped:(UIView <RRNCollapsableSectionHeaderProtocol> *)view;
-(BOOL)singleOpenSelectionOnly;

@end
