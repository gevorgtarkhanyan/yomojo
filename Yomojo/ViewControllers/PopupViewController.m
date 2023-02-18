//
//  popupViewController.m
//  Yomojo
//
//  Created by Gevorg Tarkhanyan on 11/24/22.
//  Copyright © 2022 AcquireBPO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopupViewController.h"
#import "Constants.h"
#import "AppManager.h"
#import "LoginViewController.h"
#import "BiometricViewController.h"


@interface PopupViewController()

@end

@implementation PopupViewController
@synthesize popupButton,popupTextView;


- (void)viewDidLoad {
    [self getPopupText];
    [self initialSetup];
}


-(void) initialSetup {
    _popupView.layer.borderColor = UIColor.blackColor.CGColor;
    _popupView.layer.borderWidth = 1.0;
    _popupView.layer.cornerRadius = 10;
    popupTextView.layer.cornerRadius = 10;
    popupButton.layer.borderColor = UIColor.blackColor.CGColor;
    popupButton.layer.borderWidth = 0.5;
    UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:popupButton.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = maskPath.CGPath;
    popupButton.layer.mask = maskLayer;
}


-(void) getPopupText{
    
    NSString * mode = @"";
    
    if ([PORTAL_URL  isEqual: @"https://yomojo.com.au/dev/api"]) {
            mode =  @"Dev";
        } else {
            mode = @"Prod";
        };
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/mobile_outage?type=popup&app=Yomojo&device=IOS&mode=%@", PORTAL_URL,mode];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary* resultSet = [dictData objectForKey:@"result"];
            NSMutableArray* result = [resultSet valueForKey: @"summary"];
            
                if ([result count] >= 1) {
                    for (NSString* resultText in result){
//                        self->_popupView.hidden = NO;
                        NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithData:[resultText dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                              documentAttributes:nil error:nil];
                        NSMutableAttributedString *encodedString = [[NSMutableAttributedString alloc] initWithData:[newAttributedString.string dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                   NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                              documentAttributes:nil error:nil];

                        UITextView *lbl = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, encodedString.size.width, encodedString.size.height + 100)];
                        lbl.editable = NO;
                        lbl.backgroundColor = [UIColor clearColor];
                        lbl.attributedText = encodedString;
//                        [lbl setFont:[UIFont fontWithName:@"Arial" size:14.0f]];
                        lbl.textAlignment = NSTextAlignmentCenter;
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        [alert setValue:lbl forKey:@"accessoryView"];
                        [alert show];
                        
//                        self->popupTextView.attributedText  =  encodedString;
                    }
                    
                   
                    
                } else {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"biometricLogin"]) {
                        self->_navController = [[UINavigationController alloc] initWithRootViewController:[[BiometricViewController alloc] initWithNibName:@"BiometricViewController" bundle:nil]];
                    } else {
                        self->_navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]];
                    }
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    [self.navController setNavigationBarHidden:YES];
                    self.navController.interactivePopGestureRecognizer.enabled = YES;
                    
                    self.window.backgroundColor = [UIColor whiteColor];
                    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                    [self.window setRootViewController: self->_navController];
                    [self.window makeKeyAndVisible];
                }
                
        } else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"biometricLogin"]) {
                self->_navController = [[UINavigationController alloc] initWithRootViewController:[[BiometricViewController alloc] initWithNibName:@"BiometricViewController" bundle:nil]];
            } else {
                self->_navController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]];
            }
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self.navController setNavigationBarHidden:YES];
            self.navController.interactivePopGestureRecognizer.enabled = YES;
            
            self.window.backgroundColor = [UIColor whiteColor];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [self.window setRootViewController: self->_navController];
            [self.window makeKeyAndVisible];
        }
    });
    
}
- (IBAction)popupButtonAction:(id)sender {
    exit(0);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        exit(0);
    }
}


@end
