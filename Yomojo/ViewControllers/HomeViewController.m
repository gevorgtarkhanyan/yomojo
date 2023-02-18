//
//  HomeViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 06/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "HomeViewController.h"
#import "PopMenu.h"
#import "LoginViewController.h"
#import "ContactUsViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) PopMenu *popMenu;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMenuData {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:5];
    MenuItem *menuItem = [[MenuItem alloc] initWithTitle:@"Plans" iconName:@"Plans" glowColor:[UIColor colorWithRed:0.000 green:0.840 blue:0.000 alpha:1.000] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"Benefits" iconName:@"Benefits" glowColor:[UIColor colorWithRed:0.000 green:0.840 blue:0.000 alpha:1.000] index:1];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"Buy SIM" iconName:@"BuySim" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:2];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"Activate SIM" iconName:@"ActivateSIM" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:3];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"Contact Us" iconName:@"ContactUS" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:4];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"Login" iconName:@"Login" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:5];
    [items addObject:menuItem];
    
    if (!_popMenu) {
        _popMenu = [[PopMenu alloc] initWithFrame:self.view.bounds items:items];
        _popMenu.menuAnimationType = kPopMenuAnimationTypeNetEase;
    }
    if (_popMenu.isShowed) {
        return;
    }
    _popMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem) {
        NSLog(@" selected index is:%d",(int)selectedItem.index);
        
        if ((int)selectedItem.index == 5) {
            LoginViewController *VC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController pushViewController:VC animated:YES];
        }
        
        if ((int)selectedItem.index == 4) {
            ContactUsViewController *VC = [[ContactUsViewController alloc]initWithNibName:@"ContactUsViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    };
    
   //  [_popMenu showMenuAtView:self.view];
    
    [_popMenu showMenuAtView:self.view startPoint:CGPointMake(CGRectGetWidth(self.view.bounds) - 60, CGRectGetHeight(self.view.bounds)) endPoint:CGPointMake(60, CGRectGetHeight(self.view.bounds))];
}

- (IBAction)showMenu:(id)sender {
    [self showMenuData];
}
@end
