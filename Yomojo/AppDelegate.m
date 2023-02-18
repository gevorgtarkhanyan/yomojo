//
//  AppDelegate.m
//  Yomojo
//
//  Created by Arnel Perez on 05/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "AppDelegate.h"
#import "AppManager.h"
#import "LoginViewController.h"
#import "SimsAndDevicesViewController.h"
#import "UsageHistoryViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <UserNotifications/UserNotifications.h>
#import "QuickGlanceViewController.h"
#import "NotificationsViewController.h"
#import "SideMenuViewController.h"
#import <PKRevealController/PKRevealController.h>
#import "Constants.h"
#import "AdderviceChooseViewController.h"
#import "BiometricViewController.h"
#import "PopupViewController.h"
@import GooglePlaces;

@import Firebase;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Class Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
    [GMSPlacesClient provideAPIKey:@"AIzaSyAuszgM3lSRX0Mv84lrNLlIjWKLIEXc6fk"];
// Override point for customization after application launch.
    
//    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *version = [NSString stringWithFormat:@"%@ (%@)",appVersionString, appBuildString];
    
    [FIRApp configure];

    [self registerForRemoteNotification];
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    if (launchOptions != nil) {
        // opened from a push notification when the app is closed
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil) {
            [userLogin setObject:@"1" forKey:@"fromNotification"];
        }
    } else {
        // opened app without a push notification.
    }

//    // Checking if application was launched by tapping icon, or push notification
//    if (!launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//        NSDictionary *remoteNotifiInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        if (remoteNotifiInfo) {
//            [self readPushNotification:remoteNotifiInfo];
//        }
//    }
//    else
//    {
//        NSDictionary *remoteNotifiInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//        [self readPushNotification:remoteNotifiInfo];
//    }
    
    [self updateBadge];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [userLogin removeObjectForKey:@"bannerState"];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:[[PopupViewController alloc] initWithNibName:@"PopupViewController" bundle:nil]];
    
    
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"biometricLogin"]) {
//            self.navController = [[UINavigationController alloc] initWithRootViewController:[[BiometricViewController alloc] initWithNibName:@"BiometricViewController" bundle:nil]];
//        } else {
//            self.navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]];
//        }
    

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navController setNavigationBarHidden:YES];
    self.navController.interactivePopGestureRecognizer.enabled = YES;
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application { }

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationWillTerminate:(UIApplication *)application {
    [[AppManager sharedManager] removeSavedLoginAndPasswordIfNeeded];
}

#pragma mark - Remote Notification Delegate // <= iOS 9.x
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *strDevicetoken = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    strDevicetoken = [strDevicetoken stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSLog(@"Device Token = %@",strDevicetoken);
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:strDevicetoken forKey:@"DeviceToken"];
    //self.strDeviceToken = strDevicetoken;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UNNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"#BACKGROUND FETCH CALLED: %@", userInfo);
//    // When we get a push, just writing it to file
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userInfo.plist"];
//    [userInfo writeToFile:filePath atomically:YES];
//    completionHandler(UIBackgroundFetchResultNewData);
//
//    if (userInfo) {
//        if ([userInfo objectForKey:@"aps"]) {
//            if([[userInfo objectForKey:@"aps"] objectForKey:@"badgecount"]) {
//                [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
//            }
//        }
//    }
//    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
//    [userLogin setObject:@"1" forKey:@"fromNotification"];
//
//    [self readPushNotification:userInfo];
//}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateInactive) {
        // opened from a push notification when the app was on background
        if (userInfo) {
            if ([userInfo objectForKey:@"aps"]) {
                if ([[userInfo objectForKey:@"aps"] objectForKey:@"badgecount"]) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
                }
            }
        }
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:@"1" forKey:@"fromNotification"];
    } else if(application.applicationState == UIApplicationStateActive) {
        // a push notification when the app is running. So that you can display an alert and push in any view
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin setObject:@"1" forKey:@"fromNotification"];
    }
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10
//Called when a notification is delivered to a foreground app.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info1 = %@",notification.request.content.userInfo);
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo = [notification.request.content.userInfo mutableCopy];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"1" forKey:@"fromNotification"];
}

- (void) btnNotificationList {
//    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
//    NSData *urlData = [userLogin objectForKey:@"urlData"];
//    NSMutableArray *phonesArray = [userLogin objectForKey:@"phonesArray"];
//    NSString *withFamily = [userLogin objectForKey:@"withFamily"];
//    NSString *showChildMenuOnly = [userLogin objectForKey:@"showChildMenuOnly"];
//
//    if (urlData) {
//        NotificationsViewController *mvc = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:[NSBundle mainBundle]];
//        mvc.urlData = urlData;
//        mvc.phonesArrayNew = phonesArray;
//        mvc.withFamily = withFamily;
//
//        SideMenuViewController *smvc = [[SideMenuViewController alloc] init];
//        smvc.urlData = urlData;
//        smvc.phonesArray = phonesArray;
//        smvc.fromFB = NO;
//        smvc.withFamily = withFamily;
//        smvc.showChildMenuOnly = showChildMenuOnly;
//
//        UINavigationController *navigateVC = [[UINavigationController alloc] initWithRootViewController:mvc];
//        UIViewController *leftViewController = smvc;
//        PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:navigateVC leftViewController:leftViewController];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: revealController];
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        [navController setNavigationBarHidden:YES];
//        self.window.backgroundColor = [UIColor whiteColor];
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        [self.window setRootViewController: navController];
//        [self.window makeKeyAndVisible];
//    }
}

//Called to let your app know which action was selected by the user for a given notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSLog(@"User Info2 = %@",response.notification.request.content.userInfo);
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo = [response.notification.request.content.userInfo mutableCopy];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    [userLogin setObject:@"1" forKey:@"fromNotification"];

    completionHandler();
    [self btnNotificationList];
}

#pragma mark - Class Methods
/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
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

- (void) updateBadge {
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayRemoteNotifiInfo = [[NSMutableArray alloc]init];
    NSString *clientID = [userLogin objectForKey:@"clientID"];
    NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
    arrayRemoteNotifiInfo = [[userLogin objectForKey:keyName] mutableCopy];
    
    int countUnread = 0;
    for (int i = 0; [arrayRemoteNotifiInfo count] > i; i++) {
        NSMutableDictionary *jsonData = [[arrayRemoteNotifiInfo objectAtIndex:i] mutableCopy];
        NSArray *keys=[jsonData allKeys];
        BOOL retVal = [keys containsObject:@"read"];
        if (retVal == YES) {
            NSString * strRead = [jsonData objectForKey:@"read"];
            if ([strRead  isEqualToString: @"NO"]) {
                countUnread = countUnread + 1;
            }
        }
        else{
            [arrayRemoteNotifiInfo removeObjectAtIndex:i];
            NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
            NSString *clientID = [userLogin objectForKey:@"clientID"];
            NSString *keyName = [NSString stringWithFormat:@"arrayRemoteNotificationInfo_%@",clientID];
            [userLogin setObject:arrayRemoteNotifiInfo forKey:keyName];
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = countUnread;
}

@end
