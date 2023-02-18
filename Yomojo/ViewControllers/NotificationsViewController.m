//
//  NotificationsViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 20/11/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import <PKRevealController/PKRevealController.h>
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "Constants.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController
@synthesize NotifTableList, arrayRemoteNotifiInfo, lblCheckNotifications, clientID, sessionID, urlData, notifArrayData, phonesArrayNew,withFamily, indexToRemove;

- (void)viewDidLoad {
    [super viewDidLoad];
    indexToRemove = 0;
    
    withFamily = @"YES";
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"0" forKey:@"fromNotification"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    arrayRemoteNotifiInfo = [[NSMutableArray alloc]init];
    NSString *clientID = [userLogin objectForKey:@"clientID"];
    NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
    arrayRemoteNotifiInfo = [[userLogin objectForKey:keyName] mutableCopy];
    
    lblCheckNotifications.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNotif)];
    [lblCheckNotifications addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(getNotifications) onTarget:self withObject:nil animated:YES];
}

- (void) refreshPage {
    [self getNotifications];
}

-(NSString*) sha1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (NSString *)getAutToken{
    NSString *strAuthToken = @"";
    NSString* strHash = [NSString stringWithFormat:@"%@-%@-6uJOCglydQexaZBeJfeEZrpNsxOv6060MmtTm5wVWrMnZ5zA26CXlB7BlInE8fzpOrgvEwHu04YU90KtnAMaS4FITQBY7Xj0B1DAI9n2hNCnh2yQ4djFcrvO",clientID,sessionID];
    NSString *hashOutput = [self sha1:strHash];
    NSLog(@"hashOutput: %@",hashOutput);
    
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/get-auth-token",FAMILY_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:clientID forKey:@"client_id"];
    [request setPostValue:sessionID forKey:@"session_var"];
    [request setPostValue:hashOutput forKey:@"hash"];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        strAuthToken = [dictData objectForKey:@"auth_token"];
    }
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:strAuthToken forKey:@"authToken"];
    return strAuthToken;
}

- (void) getNotifications {
    NSString *aToken = [self getAutToken];
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/user/device/alerts",FAMILY_URL];
    NSLog(@"url: %@",strPortalURL);
    NSURL *urlString = [NSURL URLWithString:strPortalURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlString];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:aToken];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        self.notifArrayData = [[NSMutableArray alloc]init];
        self.notifArrayData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        [self removeInvalidNotitification];
        [self sortNotifArray];
        [self removeMoreThan7Days];
            [self.NotifTableList reloadData];
        });
    } else {
        NSLog(@"error: %@",error);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.NotifTableList reloadData];
    });
}

- (void) selectNotif{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://yomojo.com.au/"]];
}

-(void) sortNotifArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
    NSArray *sortedArrayNotif = [notifArrayData sortedArrayUsingDescriptors:@[sortDescriptor]];
    notifArrayData = [sortedArrayNotif mutableCopy];
}

- (void) removeInvalidNotitification {
    for (int i = 0;  i < [notifArrayData count]; i++) {
        NSMutableDictionary *jsonData = [notifArrayData objectAtIndex:i];
        NSMutableDictionary *dictNotification = [jsonData objectForKey:@"notification"];
        NSString *notifType = [NSString stringWithFormat:@"%@", [dictNotification objectForKey:@"type"]];
        
        if ([notifType  isEqual: @"current_location"]) {
            [notifArrayData removeObjectAtIndex:i];
        }
    }
}

-(void) removeMoreThan7Days {
    NSMutableArray *indexForRemove = [[NSMutableArray alloc] init];
    
    if ([notifArrayData count] > 0) {
        for (int i = 0;  i < [notifArrayData count]; i++) {
            int retValue = 0;
            NSMutableDictionary *jsonData = [notifArrayData objectAtIndex:i];
            NSLog(@"%@",[jsonData objectForKey:@"created_at"]);

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            NSString *dateString=[NSString stringWithString:[jsonData objectForKey:@"created_at"]];
            dateString = [NSString stringWithFormat:@"%@ UTC",dateString];
            NSDate *dateObj = [dateFormatter dateFromString:dateString];
            
            retValue = [self getDateDiff2:dateObj];
            if (retValue == 1) {
                [indexForRemove addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        
        int a = (int)([indexForRemove count] - 1);
        for (int b=a; b >= 0; b--) {
            int inderVal = [[indexForRemove objectAtIndex:b] intValue];
            [notifArrayData removeObjectAtIndex:inderVal];
        }
    }
}

//-(void) clearNullNotification{
//    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
//    NSString *clientID = [userLogin objectForKey:@"clientID"];
//    NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
//    arrayRemoteNotifiInfo = [[userLogin objectForKey:keyName] mutableCopy];
//    if ([arrayRemoteNotifiInfo count] > 0) {
//        for (int i = 0;  i < [arrayRemoteNotifiInfo count]; i++) {
//            NSMutableDictionary *jsonData = [arrayRemoteNotifiInfo objectAtIndex:i];
//            NSString *strRead = [jsonData objectForKey:@"read"];
//            if ([strRead  isEqualToString: @"NO"] || [strRead  isEqualToString: @"YES"]) {
//                NSLog(@"Not for remove");
//            }
//            else{
//                [arrayRemoteNotifiInfo removeObjectAtIndex:i];
//            }
//        }
//        [userLogin setObject:arrayRemoteNotifiInfo forKey:keyName];
//    }
//}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    arrayRemoteNotifiInfo = [[NSMutableArray alloc]init];
    NSString *clientID = [userLogin objectForKey:@"clientID"];
    NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
    
    arrayRemoteNotifiInfo = [[userLogin objectForKey:keyName] mutableCopy];
    
        [self.NotifTableList reloadData];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"will enter foreground notification");
}

- (void) markDataAsRead{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        for (int i = 0; [self.arrayRemoteNotifiInfo count] > i; i++) {
            NSMutableDictionary *jsonData = [[self.arrayRemoteNotifiInfo objectAtIndex:i] mutableCopy];
            [jsonData setObject:@"YES" forKey:@"read"];
            [self.arrayRemoteNotifiInfo replaceObjectAtIndex:i withObject:jsonData];
        }
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        NSString *clientID = [userLogin objectForKey:@"clientID"];
        NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
        [userLogin setObject:self.arrayRemoteNotifiInfo forKey:keyName];
    });
}

- (IBAction)btnBack:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(markDataAsRead) onTarget:self withObject:nil animated:YES];
    
    [self showRightView:sender];
}


- (void)showRightView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (NSString*) getDateDiff: (NSDate *)createdDate {
    NSDate* date1 = [NSDate date];
    NSDate* date2 = createdDate;
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date2  toDate:date1  options:0];

    NSString *txtMo = @"months";
    NSString *txtDy = @"days";
    NSString *txtHr = @"hours";
    NSString *txtMn = @"mins";
    
    if ([breakdownInfo month] <= 1 )
        txtMo = @"month";
    if ([breakdownInfo day] <= 1 )
        txtDy = @"day";
    if ([breakdownInfo hour] <= 1 )
        txtHr = @"hour";
    if ([breakdownInfo minute] <= 1 )
        txtMn = @"min";
    
    NSString *lblDate = @"";
    if ([breakdownInfo month] > 0) {
        lblDate = [NSString stringWithFormat:@"%ld %@ %ld %@ ago",(long)[breakdownInfo month],txtMo, (long)[breakdownInfo day],txtDy];
    }
    else if ([breakdownInfo day] > 0){
        lblDate = [NSString stringWithFormat:@"%ld %@ %ld %@ %ld %@ ago",(long)[breakdownInfo day],txtDy, (long)[breakdownInfo hour], txtHr, (long)[breakdownInfo minute],txtMn];
    }
    else if ([breakdownInfo hour] > 0){
        lblDate = [NSString stringWithFormat:@"%ld %@ %ld %@ ago", (long)[breakdownInfo hour],txtHr, (long)[breakdownInfo minute],txtMn];
    }
    else if ([breakdownInfo minute] > 0){
        lblDate = [NSString stringWithFormat:@"%ld %@ ago", (long)[breakdownInfo minute],txtMn];
    }
    else{
        lblDate = @"A few minutes ago";
    }
    return lblDate;
}

- (int) getDateDiff2: (NSDate *)createdDate {
    NSDate* date1 = [NSDate date];
    NSDate* date2 = createdDate;
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date2  toDate:date1  options:0];
    
    NSLog(@"Month: %d",(int)[breakdownInfo month]);
    NSLog(@"Days: %d",(int)[breakdownInfo day]);
    NSLog(@"Hour: %d",(int)[breakdownInfo hour]);
    NSLog(@"Min: %d",(int)[breakdownInfo minute]);
    
    int intMonth = (int)[breakdownInfo month];
    int intDay = (int)[breakdownInfo day];
    int intHrs = (int)[breakdownInfo hour];
    int intMin = (int)[breakdownInfo minute];

    if (intMonth > 0) {
        return 1;
    }
    if (intDay > 7){
        return 1;
    }
    if (intDay == 7) {
        if (intHrs > 0) {
            return 1;
        }
        if (intMin > 0) {
            return 1;
        }
    }
    return 0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [notifArrayData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *jsonData = [notifArrayData objectAtIndex:indexPath.section];
    static NSString *simpleTableIdentifier = @"Cell";
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSMutableDictionary *dictNotification = [jsonData objectForKey:@"notification"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *dateString=[NSString stringWithString:[jsonData objectForKey:@"created_at"]];
    dateString = [NSString stringWithFormat:@"%@ UTC",dateString];
    
    NSDate *dateObj = [dateFormatter dateFromString:dateString];
    
    NSString *strTitle = [NSString stringWithFormat:@"%@", [dictNotification objectForKey:@"title"]];
    if ([strTitle  isEqualToString: @"(null)"]) {
        strTitle = [NSString stringWithFormat:@"%@", [dictNotification objectForKey:@"message"]];
    }

    cell.lblType.text = [NSString stringWithFormat:@"%@", [dictNotification objectForKey:@"type"]];
    cell.lblDateAdded.text =  [self getDateDiff:dateObj];
    cell.lblTitle.text = strTitle;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        self->indexToRemove = indexPath.section;
        self->HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:self->HUB];
        [self->HUB showWhileExecuting:@selector(readPushNotification) onTarget:self withObject:nil animated:YES];
        completionHandler(NO);
    }];

    UISwipeActionsConfiguration *swipeAction = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
    swipeAction.performsFirstActionWithFullSwipe = NO;
    
    return swipeAction;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        indexToRemove = indexPath.section;
        HUB = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:HUB];
        [HUB showWhileExecuting:@selector(readPushNotification) onTarget:self withObject:nil animated:YES];
    }
}

-(void) readPushNotification {
    NSMutableDictionary *jsonData = [notifArrayData objectAtIndex:indexToRemove];
    NSString *pushNotifId = [jsonData objectForKey:@"id"];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString* authToken = [userLogin objectForKey:@"authToken"];
    NSLog(@"authToken: %@",authToken);
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/user/device/close-alert",FAMILY_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:authToken];
    [request setPostValue:pushNotifId forKey:@"id"];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSString* successRet = [dictData objectForKey:@"success"];
        NSLog(@"Success: %@",successRet);
    }
    else{
        NSLog(@"error: %@",error);
    }
    [self getNotifications];
}
@end
