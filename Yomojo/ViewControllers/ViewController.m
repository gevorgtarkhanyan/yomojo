//
//  ViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 05/01/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "ViewController.h"
#import "PopMenu.h"

@interface ViewController ()

@property (nonatomic, strong) PopMenu *popMenu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"%@",@"test");
//    
//    NSString *sSOAPMessage = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//    "<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ecgw=\"ecgw\"><soapenv:Header/><soapenv:Body><ecgw:doLogin soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><spconfigID xsi:type=\"xsd:double\">*</spconfigID><emailaddress xsi:type=\"xsd:string\">alvieyomojo-16dec10a@yahoo.com.ph</emailaddress><password xsi:type=\"xsd:string\">1q2w3e4r</password><mode xsi:type=\"xsd:string\">0</mode></ecgw:doLogin></soapenv:Body></soapenv:Envelope>";
//    
//    NSString *sMessageLength = [NSString stringWithFormat:@"%lu", (unsigned long)[sSOAPMessage length]];
//    
//    NSURL *url = [NSURL URLWithString:@"https://eap2.ecconnect.com.au/eap/owi/webservices/ecgw_webservice.cfc"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    
//    NSString *authStr = @"acquirebpo:acq98aG3@#";
//    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
//    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
//    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Length": sMessageLength, @"Content-Type": @"text/xml; charset=utf-8"};
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    request.HTTPBody = [sSOAPMessage dataUsingEncoding:NSUTF8StringEncoding];
//    request.HTTPMethod = @"POST";
//    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"result: %@",newStr);
//        NSLog(@"error: %@",error);
//    }];
//    [postDataTask resume];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [webResponseData  setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webResponseData  appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Some error in your Connection. Please try again.");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Received Bytes from server: %lu", (unsigned long)[webResponseData length]);
    NSString *myXMLResponse = [[NSString alloc] initWithBytes: [webResponseData bytes] length:[webResponseData length] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",myXMLResponse);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMenu {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:3];
    MenuItem *menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"Plans" glowColor:[UIColor grayColor] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"Benefits" glowColor:[UIColor colorWithRed:0.000 green:0.840 blue:0.000 alpha:1.000] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"BuySim" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"RoundButton" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"RoundButton" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:@"" iconName:@"RoundButton" glowColor:[UIColor colorWithRed:0.687 green:0.000 blue:0.000 alpha:1.000] index:0];
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
    };
    
    //    [_popMenu showMenuAtView:self.view];
    
    [_popMenu showMenuAtView:self.view startPoint:CGPointMake(CGRectGetWidth(self.view.bounds) - 60, CGRectGetHeight(self.view.bounds)) endPoint:CGPointMake(60, CGRectGetHeight(self.view.bounds))];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showMenu];
}

@end
