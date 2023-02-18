//
//  PopupViewController.h
//  Yomojo
//
//  Created by Gevorg Tarkhanyan on 11/24/22.
//  Copyright © 2022 AcquireBPO. All rights reserved.
//

#ifndef PopupViewController_h
#define PopupViewController_h
#import <UIKit/UIKit.h>

@interface PopupViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UITextView *popupTextView;
@property (strong, nonatomic) IBOutlet UIButton *popupButton;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIWindow *window;

@end

#endif /* PopupViewController_h */
