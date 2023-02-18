//
//  LoginViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 06/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreData/CoreData.h>
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

@interface LoginViewController : UIViewController <UIPageViewControllerDelegate,UIAlertViewDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUB;
    
    int alertInt;
    BOOL passedFBMethod;
    BOOL hasActivePhone;
    BOOL rememberCheckbox;

    NSString *fbLoginURL;
    NSString *withFamily;
    NSString *showChildMenuOnly;
    
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *btnRemember;
    IBOutlet UIButton *btnQuickGlance;
    
    IBOutlet UILabel *lblVersion;

    IBOutlet UIView *backgroundView;

    IBOutlet UITextField *txtDeviceToken;

    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageView;
    
    IBOutlet NSLayoutConstraint *btnQuickGlanceHeight;
    IBOutlet NSLayoutConstraint *btnQuickGlanceTop;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *fbLoginURL;
@property (strong, nonatomic) NSString *withFamily;
@property (strong, nonatomic) NSString *showChildMenuOnly;
@property (strong, nonatomic) NSMutableArray *pages;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *passContainerView;
@property (strong, nonatomic) IBOutlet UIView *emailContainerView;

@property (strong, nonatomic) IBOutlet UILabel *lblVersion;

@property (strong, nonatomic) IBOutlet UIButton *btnRemember;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *btnQuickGlance;

@property (strong, nonatomic) IBOutlet UITextField *txtEmailAdd;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtDeviceToken;

@property (strong, nonatomic) IBOutlet UIImageView *emailImageView;
@property (strong, nonatomic) IBOutlet UIImageView *passwordImageView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *loginWithCodeView;
@property (strong, nonatomic) IBOutlet UIButton *loginWithCodeBackButton;
@property (strong, nonatomic) IBOutlet UITextField *loginWithCodeTextField;
@property (strong, nonatomic) IBOutlet UIImageView *invalidCodeIcon;
@property (strong, nonatomic) IBOutlet UIButton *verifyCodeButton;
@property (strong, nonatomic) IBOutlet UIView *invalidCodeView;
@property (strong, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (strong, nonatomic) IBOutlet UIView *loginWithCodeTextFieldView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnQuickGlanceHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnQuickGlanceTop;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (IBAction)doLogin:(id)sender;
- (IBAction)btnForgotPass:(id)sender;
- (IBAction)btnBack:(id)sender;

- (IBAction)btnClearEntry:(id)sender;

- (IBAction)btnRemember:(id)sender;

- (IBAction)FBLoginBtn:(id)sender;
- (IBAction)btnQuickGlance:(id)sender;
- (IBAction)handleSwipeRight:(UISwipeGestureRecognizer *)sender;



@end
