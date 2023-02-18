//
//  UsageHistoryViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 17/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "UsageHistoryViewController.h"
#import "MenuSection.h"
#import "MenuSectionHeaderView.h"
#import "UsageItemTableViewCell.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"

@interface UsageHistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) NSArray *menu;
@end

@implementation UsageHistoryViewController
@synthesize segmentControl,segmentData,usageSelected,arrayDates;
@synthesize txtFromDate,txtToDate,phoneID,planID,clientID,sessionID,usageData;
@synthesize btnFrom,btnTo,billday, resultDataForUsage, totalUsage, defaultToDate, defaultFromDate;

static NSString *identifier = @"MenuSectionHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BGColor = NO;
    segmentData = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"SMS", @"Voice", @"INTL", @"Data", @"Excess", nil]];
    if ([planID isEqualToString:@"5"]) {
        segmentData = [[NSArray arrayWithObjects:@"Data", @"Excess", nil] mutableCopy];
    }
    [self setSegmentData];
    
    [btnFrom addTarget:self action:@selector(showFromDate:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnTo addTarget:self action:@selector(showToDate:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    txtFromDate.text = [dateFormatter stringFromDate:defaultFromDate];
    txtToDate.text = [dateFormatter stringFromDate:defaultToDate];
    
    if (self.isHWBB) {
        self.usageSelected = @"PAYG";
    }
    
    if (self->defaultFromDate == nil || defaultToDate == nil) {
        if (self.isHWBB) {
            self->segmentControl.hidden = YES;
        } else {
            self->segmentControl.hidden = NO;
        }
        if (self->resultDataForUsage[@"startdate"] && resultDataForUsage[@"enddate"]) {
            NSString *startDateString = [self->resultDataForUsage valueForKey:@"startdate"];
            NSString *endDateString = [self->resultDataForUsage valueForKey:@"enddate"];
            
            if (startDateString.length > 0 && endDateString.length > 0) {
                startDateString = [startDateString stringByReplacingOccurrencesOfString:@"{ts '" withString:@""];
                startDateString = [startDateString stringByReplacingOccurrencesOfString:@"'}" withString:@""];
                endDateString = [endDateString stringByReplacingOccurrencesOfString:@"{ts '" withString:@""];
                endDateString = [endDateString stringByReplacingOccurrencesOfString:@"'}" withString:@""];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                self->defaultFromDate = [dateFormatter dateFromString:startDateString];
                self->defaultToDate = [dateFormatter dateFromString:endDateString];
                
                NSDateFormatter *dateFormatterForString = [[NSDateFormatter alloc] init];
                [dateFormatterForString setDateFormat:@"MMM dd, yyyy"];
                
                self->txtFromDate.text = [dateFormatterForString stringFromDate:self->defaultFromDate];
                self->txtToDate.text = [dateFormatterForString stringFromDate:self->defaultToDate];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
                    [self.view addSubview:self->HUB];
                    [self->HUB showWhileExecuting:@selector(getUsageInfo) onTarget:self withObject:nil animated:YES];
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->segmentControl.hidden = NO;
            self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:self->HUB];
            [self->HUB showWhileExecuting:@selector(getUsageInfo) onTarget:self withObject:nil animated:YES];
        });
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void) setSegmentData
{
    [segmentControl removeAllSegments];
    for (int i = 0; i < segmentData.count; i++) {
        [segmentControl insertSegmentWithTitle: segmentData[i] atIndex: i animated: true];
    }
    [segmentControl setSelectedSegmentIndex:0];
    [self segmentAction];
}

-(void)segmentAction {
    NSInteger index = segmentControl.selectedSegmentIndex;
    usageSelected = segmentData[index];
    if ([usageSelected isEqualToString:@"Excess"]) {
        usageSelected = @"PAYG";
    }
    if ([usageSelected isEqualToString:@"Voice"]) {
        usageSelected = @"VOICE";
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    NSString *returnString = @"";
    if (hours != 0) {
        returnString = [NSString stringWithFormat:@"%d Hrs %d Mins %02d Secs",hours, minutes, seconds];
    } else if (minutes != 0) {
        returnString = [NSString stringWithFormat:@"%d Mins %d Secs", minutes, seconds];
    } else if (seconds != 0){
        returnString =  [NSString stringWithFormat:@"%d Secs",seconds];
    }
    return returnString;
}

-(void) getUsageInfo {
    if (!self->usageSelected) {
        self->usageSelected = @"SMS";
    }
    
    self->totalUsage = 0.0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy"];
    
    NSDate *dateFrom = [dateFormat dateFromString:self->txtFromDate.text];
    NSString *startdate = [dateFormat stringFromDate:dateFrom];
    
    NSDate *dateTo = [dateFormat dateFromString:self->txtToDate.text];
    int daysToAdd = 1;
    NSDate *newDate1 = [dateTo dateByAddingTimeInterval:60*60*24*daysToAdd];
    NSString *enddate = [dateFormat stringFromDate:newDate1];
    
    
    NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/get_usage_data/%@/%@/%@/%@/%@/%@",self->usageSelected,startdate,enddate,self->clientID,phoneID,sessionID];
    
    
    NSLog(@"strURL: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            
            if (self->txtFromDate.text.length > 0 && self->txtToDate.text.length > 0) {
                if (self.isHWBB) {
                    self.dataLabel.hidden = NO;
                    self.segmentControl.hidden = YES;
                } else {
                    self.dataLabel.hidden = YES;
                    self.segmentControl.hidden = NO;
                }
            }
            
            self->cellArray=[[NSMutableArray alloc]init];
            self->cellCount=[[NSMutableArray alloc]init];
            
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
            self->usageData = [dictData objectForKey:@"usage"];
            
            self->arrayDates = [[NSMutableArray alloc]init];
            for (int i=0; i < [self->usageData count]; i++){
                NSMutableDictionary *dictUsage =  [self->usageData objectAtIndex:i];
                NSString *starttime = [dictUsage objectForKey:@"starttime"];
                NSArray *arrayStarttime = [starttime componentsSeparatedByString: @" "];
                NSString *startDate = [NSString stringWithFormat:@"%@ %@ %@",arrayStarttime[0],arrayStarttime[1],arrayStarttime[2]];
                if ([self->arrayDates containsObject: startDate] == NO) {
                    [self->arrayDates addObject:startDate];
                }
            }
            
            self->datesTotal = [[NSMutableDictionary alloc]init];
            
            for (int i=0; i < [self->arrayDates count]; i++){
                NSString *forDates = [self->arrayDates objectAtIndex:i];
                NSMutableArray *_cellArray=[[NSMutableArray alloc]init];
                float totalCalculatedCost = 0;
                float totalQuantity = 0;
                for (int a=0; a < [self->usageData count]; a++){
                    NSMutableDictionary *dictUsage =  [self->usageData objectAtIndex:a];
                    NSString *starttime = [dictUsage objectForKey:@"starttime"];
                    NSArray *arrayStarttime = [starttime componentsSeparatedByString: @" "];
                    NSString *startDate = [NSString stringWithFormat:@"%@ %@ %@",arrayStarttime[0],arrayStarttime[1],arrayStarttime[2]];
                    NSString *startTime = [NSString stringWithFormat:@"%@",arrayStarttime[3]];
                    if ([forDates isEqualToString: startDate]) {
                        NSString *rec_desc = [dictUsage objectForKey:@"rec_desc"];
                        NSString *rec_details =[dictUsage objectForKey:@"rec_details"];
                        NSString *calculatedcost = [dictUsage objectForKey:@"calculatedcost"];
                        
                        rec_desc = [rec_desc stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                        rec_desc = [rec_desc stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                        rec_desc = [rec_desc stringByReplacingOccurrencesOfString:@"SMS to" withString:@""];
                        rec_desc = [rec_desc stringByReplacingOccurrencesOfString:@"Call to" withString:@""];
                        rec_desc = [rec_desc stringByReplacingOccurrencesOfString:@"International" withString:@""];
                        rec_details = [rec_details stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                        rec_details = [rec_details stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                        rec_details = [rec_details stringByReplacingOccurrencesOfString:@"Call time:" withString:@""];
                        rec_details = [rec_details stringByReplacingOccurrencesOfString:@"Quantity:" withString:@""];
                        rec_details = [rec_details stringByReplacingOccurrencesOfString:@"<b>Quantity:</b>" withString:@""];
                        
                        if ([rec_desc rangeOfString:@"0411000321"].location == NSNotFound) {
                            
                        } else {
                            rec_desc = @"Voicemail";
                        }
                        
                        if ([self->usageSelected isEqual:@"INTL"]){
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"KB" withString:@""];
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"MB" withString:@""];
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@" " withString:@""];
                            double duration = [rec_details doubleValue];
                            rec_details = [NSString stringWithFormat:@"%d Seconds", (int)duration];
                        } else if ([self->usageSelected isEqual:@"VOICE"]) {
                            rec_desc = [NSString stringWithFormat:@"Call to%@", rec_desc];
                        } else if ([self->usageSelected isEqual:@"SMS"]) {
                            rec_desc = [NSString stringWithFormat:@"SMS to%@", rec_desc];
                        }
                        
                        if (self.isHWBB) {
                            calculatedcost = @"$0";
                        }
                        NSString *details = [NSString stringWithFormat:@" %@|   %@   | %@ |%@",startTime,rec_desc,rec_details,calculatedcost];
                        [_cellArray addObject:details];
                        
                        
                        if ([self->usageSelected isEqual:@"SMS"]) {
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"SMS" withString:@""];
                            totalQuantity = totalQuantity + [rec_details floatValue];
                            calculatedcost = [calculatedcost stringByReplacingOccurrencesOfString:@"$" withString:@""];
                            totalCalculatedCost = totalCalculatedCost + [calculatedcost floatValue];
                        } else if ([self->usageSelected isEqual:@"VOICE"]){
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"Seconds" withString:@""];
                            totalQuantity = totalQuantity + [rec_details floatValue];
                            calculatedcost = [calculatedcost stringByReplacingOccurrencesOfString:@"$" withString:@""];
                            totalCalculatedCost = totalCalculatedCost + [calculatedcost floatValue];
                        } else if ([self->usageSelected isEqual:@"Data"]){
                            BOOL isKB = ([rec_details rangeOfString:@"KB"].location == NSNotFound) ? NO : YES;
                            
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"KB" withString:@""];
                            rec_details = [rec_details stringByReplacingOccurrencesOfString:@"MB" withString:@""];
                            
                            float recFloatValue = (isKB == YES) ? [rec_details floatValue] / 1024 : [rec_details floatValue];
                            
                            totalQuantity = totalQuantity + recFloatValue;
                            calculatedcost = [calculatedcost stringByReplacingOccurrencesOfString:@"$" withString:@""];
                            totalCalculatedCost = totalCalculatedCost + [calculatedcost floatValue];
                        } else if ([self->usageSelected  isEqual: @"INTL"]) {
                            totalQuantity = totalQuantity + [rec_details floatValue];
                            calculatedcost = [calculatedcost stringByReplacingOccurrencesOfString:@"$" withString:@""];
                            totalCalculatedCost = totalCalculatedCost + [calculatedcost floatValue];
                        } else {
                            totalQuantity = totalQuantity + [rec_details floatValue];
                            calculatedcost = [calculatedcost stringByReplacingOccurrencesOfString:@"$" withString:@""];
                            totalCalculatedCost = totalCalculatedCost + [calculatedcost floatValue];
                        }
                    }
                }
                NSString *totalDetails = @"";
                if (self.isHWBB) {
                    totalCalculatedCost = 0;
                }
                
                if ([self->usageSelected isEqual: @"SMS"]) {
                    totalDetails = [NSString stringWithFormat:@" %.0f SMS   Cost: $%.02f",totalQuantity,totalCalculatedCost];
                } else if ([self->usageSelected  isEqual: @"VOICE"]) {
                    NSString *strTimeFormat = [self timeFormatted:totalQuantity];
                    totalDetails = [NSString stringWithFormat:@" %@  Cost: $%.02f",strTimeFormat,totalCalculatedCost];
                } else if ([self->usageSelected isEqual: @"Data"]) {
                    if (totalQuantity < 1) {
                        totalQuantity = totalQuantity * 1024;
                        totalDetails = [NSString stringWithFormat:@" %.02f MB  Cost: $%.02f",totalQuantity,totalCalculatedCost];
                    } else{
                        totalDetails = [NSString stringWithFormat:@" %.02f MB  Cost: $%.02f",totalQuantity,totalCalculatedCost];
                    }
                } else if ([self->usageSelected  isEqual: @"INTL"]) {
                    NSString *strTimeFormat = [self timeFormatted:totalQuantity];
                    totalDetails = [NSString stringWithFormat:@" %@  Cost: $%.02f",strTimeFormat,totalCalculatedCost];
                } else {
                    totalDetails = [NSString stringWithFormat:@" Cost: $%.02f",totalCalculatedCost];
                }
                self->totalUsage = self->totalUsage + totalQuantity;
                
                [self->datesTotal setObject:totalDetails forKey:forDates];
                [self->cellArray addObject:_cellArray];
                [self->cellCount addObject:[NSNumber numberWithInteger:[_cellArray count]]];
            }
        } else {
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            [self alertStatus:strError:@"Error"];
        }
        [self.tableView reloadData];
    });
}


-(NSString *)sectionHeaderReuseIdentifier {
    return identifier;
}

-(NSArray *)model {
    return self.menu;
}

-(UITableView *)collapsableTableView {
    return self.tableView;
}

-(BOOL)singleOpenSelectionOnly {
    return NO;
}

-(void)showToDate:(id)sender forEvent:(UIEvent*)event{
    UIViewController *ToNameView = [[UIViewController alloc]init];
    ToNameView.view.frame = CGRectMake(0,0, 300, 150);
    toPicker = [[UIDatePicker alloc] init];
    toPicker.frame  = CGRectMake(0,0, 300, 100);
    toPicker.datePickerMode = UIDatePickerModeDate;
    if (@available(iOS 13.4, *)) {
        toPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [ToNameView.view addSubview:toPicker];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    if (![txtToDate.text  isEqual: @""]){
        toPicker.date = [dateFormat dateFromString:txtToDate.text];
        [toPicker addTarget:self action:@selector(updateTextFieldTo:) forControlEvents:UIControlEventValueChanged];
    }
    else{
        [toPicker addTarget:self action:@selector(updateTextFieldTo:) forControlEvents:UIControlEventValueChanged];
    }
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithContentViewController:ToNameView];
    popoverController.cornerRadius = 10;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}


-(void)showFromDate:(id)sender forEvent:(UIEvent*)event{
    UIViewController *FromNameView = [[UIViewController alloc]init];
    FromNameView.view.frame = CGRectMake(0,0, 300, 150);
    fromPicker = [[UIDatePicker alloc] init];
    fromPicker.frame  = CGRectMake(0,0, 300, 100);
    fromPicker.datePickerMode = UIDatePickerModeDate;
    if (@available(iOS 13.4, *)) {
        fromPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [FromNameView.view addSubview:fromPicker];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    if (![txtFromDate.text  isEqual: @""]){
        fromPicker.date = [dateFormat dateFromString:txtFromDate.text];
        [fromPicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    } else {
        [fromPicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    }
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithContentViewController:FromNameView];
    popoverController.cornerRadius = 10;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

-(void)updateTextField:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    txtFromDate.text = [dateFormat stringFromDate:fromPicker.date];
}

-(void)updateTextFieldTo:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    txtToDate.text = [dateFormat stringFromDate:toPicker.date];
}

#pragma mark - Actions

- (IBAction)btnSaveHistory:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getUsageInfo) onTarget:self withObject:nil animated:YES];
}

- (IBAction)btnBack:(id)sender {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"0" forKey:@"fromNotification"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnRefresh:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    HUB.labelText = @"Retrieving data…";
    [HUB showWhileExecuting:@selector(getUsageInfo) onTarget:self withObject:nil animated:YES];
}

- (IBAction)usageSelect:(id)sender {
    [self segmentAction];
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    HUB.labelText = @"Retrieving data…";
    [HUB showWhileExecuting:@selector(getUsageInfo) onTarget:self withObject:nil animated:YES];
}

-(IBAction)buttonClicked:(id)sender {
    
    UIButton *button=(UIButton *)sender;
    NSInteger _index=[sender tag]-1;
    if(![button isSelected])
        [cellCount replaceObjectAtIndex:_index withObject:[NSNumber numberWithInt:0]];
    else
        [cellCount replaceObjectAtIndex:_index withObject:[NSNumber numberWithInteger:[[cellArray objectAtIndex:_index]count]]];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 30)];
    UIImageView *headerBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sectionBg.png"]];
    [headerView addSubview:headerBg];
    
    //Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(screenBounds.size.width -30, 0, 30, 30);
    button.tag = section+1;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"shrink.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateSelected];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.selected = ([[cellCount objectAtIndex:section] intValue] == 0) ? YES : NO;
    
    [headerView addSubview:button];
    //Label
    NSString *txtDates = [arrayDates objectAtIndex:section];
    NSString *totalData = [datesTotal objectForKey:txtDates];
    
    NSString *headerLabel = [NSString stringWithFormat:@"%@  %@",txtDates,totalData];
    UILabel *headerTitle=[[UILabel alloc]initWithFrame:CGRectMake(5, 2, screenBounds.size.width -30, 30)];
    [headerTitle setBackgroundColor:[UIColor clearColor]];
    [headerTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [headerTitle setTextColor:[UIColor darkGrayColor]];
    [headerTitle setText:headerLabel];
    [headerTitle setNumberOfLines:0];
    [headerView addSubview:headerTitle];
    return  headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [arrayDates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[cellCount objectAtIndex:section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *strData = [[cellArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([strData containsString:@"KB"]) {
        strData = [strData stringByReplacingOccurrencesOfString:@"KB" withString:@"MB"];
    }
    
    NSArray *arrayStarttime = [strData componentsSeparatedByString: @"|"];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:arrayStarttime];
    
    CGFloat firstItemWidth = (screenBounds.size.width == 320) ? 60 : 70;
    CGFloat lastItemWidth = (screenBounds.size.width == 320) ? 65 : 85;

    for (int i = 0; i < arrayStarttime.count; i ++) {
        if (i == 0) {
            [segmentedControl setWidth:firstItemWidth forSegmentAtIndex:i];
        } else if (i == arrayStarttime.count - 1) {
            [segmentedControl setWidth:lastItemWidth forSegmentAtIndex:i];
        } else {
            CGFloat width = (screenBounds.size.width - (firstItemWidth + lastItemWidth))/(arrayStarttime.count - 2);
            [segmentedControl setWidth:width forSegmentAtIndex:i];
        }
    }
    segmentedControl.frame = CGRectMake(-5, 0, screenBounds.size.width + 10, 31);

    if (BGColor == NO) {
        BGColor = YES;
        UIColor *segmentBG = [UIColor colorWithRed:255.0f/255.0f
                                             green:69.0f/255.0f
                                              blue:5.0f/255.0f
                                             alpha:0.3f];
        segmentedControl.backgroundColor = segmentBG;
        segmentedControl.tintColor = [UIColor clearColor];
    } else{
        BGColor = NO;
        segmentedControl.backgroundColor = [UIColor whiteColor];
        segmentedControl.tintColor = [UIColor whiteColor];
    }
        
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Helvetica" size:10],NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    segmentedControl.enabled = NO;
    
    [cell.contentView addSubview:segmentedControl];
    return  cell;
}

@end
