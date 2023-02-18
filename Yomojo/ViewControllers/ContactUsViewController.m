//
//  ContactUsViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 09/02/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "ContactUsViewController.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import <PKRevealController/PKRevealController.h>
#import "Constants.h"
#import "XmlReader.h"
//#import <Google/Analytics.h>

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController
@synthesize urlData,phonesArray;
@synthesize txtEmailAdd,txtEnquiryType,txtFirstName,txtMessage,txtmobileNum,txtLastName,btnEnquiry;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"ContactUs Page"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    UIImage *revealImagePortrait = [UIImage imageNamed:@"ico_menu_sm"];
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showRightView:)];
    }

    NSString *noActiveService = @"NO";
    if ([phonesArray count] == 0){
        noActiveService = @"YES";
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    alertInt = 0;
    
    [btnEnquiry addTarget:self action:@selector(showEnquiry:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    arrayEnquiry=[[NSMutableArray alloc]initWithObjects:
                    @"- Select -",
                    @"Billing",
                    @"Technical Support",
                    @"Sales",
                    @"Others",
                    @"Feedback",
                    nil];
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    NSMutableArray *personalDetailsArray = [responseDict objectForKey:@"PERSONDETAILS"];
    NSMutableDictionary *personalDetailsDict = [personalDetailsArray objectAtIndex:0];
    
    txtEmailAdd.text = [personalDetailsDict objectForKey:@"EMAILADDRESS"];
    txtFirstName.text = [personalDetailsDict objectForKey:@"FIRSTNAME"];
    txtLastName.text = [personalDetailsDict objectForKey:@"LASTNAME"];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    
    if ([noActiveService  isEqual: @"YES"]) {
        txtmobileNum.text = @"";
    }
    else{
        txtmobileNum.text = [userLogin objectForKey:@"phoneNumber"];
    }
    //txtmobileNum.text = [userLogin objectForKey:@"phoneNumber"];
    //txtFirstName.text = [userLogin objectForKey:@"FullName"];
    
    //txtMessage = [[UITextView alloc] init];
    txtMessage.delegate = self;
    txtMessage.text = @"Message";
    txtMessage.textColor = [UIColor lightGrayColor];
    
    txtEmailAdd.delegate = self;
    txtLastName.delegate = self;
    txtFirstName.delegate = self;
    txtmobileNum.delegate = self;
    
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(yourTextViewDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    txtMessage.inputAccessoryView = keyboardToolbar;
    
    NSString *clientDetailsXML = [responseDict objectForKey:@"CLIENTDETAILS"];
    NSDictionary *XMLdict = [XMLReader dictionaryForXMLString:clientDetailsXML error:nil];
    NSDictionary *clientDict = [XMLdict objectForKey:@"client"];
    
    NSString *emailaddress = [[clientDict objectForKey:@"emailaddress"]objectForKey:@"text"];
    txtEmailAdd.text = [emailaddress stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    
    NSString *firstname = [[clientDict objectForKey:@"firstname"]objectForKey:@"text"];
    txtFirstName.text = [firstname stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    
    NSString *lastname = [[clientDict objectForKey:@"lastname"]objectForKey:@"text"];
    txtLastName.text = [lastname stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
}

-(void)yourTextViewDoneButtonPressed
{
    [self dismissKeyboard];
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


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if  (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }
    
    if(txtMessage.text.length == 0) {
        txtMessage.text = @"";
        txtMessage.textColor = [UIColor blackColor];
    }
    else if ([txtMessage.text isEqual: @"Message"]){
        txtMessage.text = @"";
        txtMessage.textColor = [UIColor blackColor];
    }
    else{
        txtMessage.textColor = [UIColor blackColor];
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(txtMessage.text.length == 0) {
        txtMessage.textColor = [UIColor lightGrayColor];
        txtMessage.text = @"Message";
        [txtMessage resignFirstResponder];
    }
}


-(void)dismissKeyboard {
    [txtEmailAdd resignFirstResponder];
    [txtLastName resignFirstResponder];
    [txtFirstName resignFirstResponder];
    [txtEnquiryType resignFirstResponder];
    [txtMessage resignFirstResponder];
    [txtmobileNum resignFirstResponder];
    if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define kOFFSET_FOR_KEYBOARD 220.0

//-(void)keyboardWillShow {
//    // Animate the current view out of the way
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}
//
//-(void)keyboardWillHide {
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if  (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0) {
       
    }

//     [self setViewMovedUp:YES];
//    if ([sender isEqual:txtmobileNum])
//    {
//        //move the main view, so that the keyboard does not hide it.
//        [self setViewMovedUp:YES];
//    }
//    else{
//        if  (self.view.frame.origin.y >= 0) {
//            [self setViewMovedUp:YES];
//        }
//        else if (self.view.frame.origin.y < 0) {
//            [self setViewMovedUp:NO];
//        }
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    return NO;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
//}



-(void)showEnquiry:(id)sender forEvent:(UIEvent*)event{
    UIViewController *prodNameView = [[UIViewController alloc]init];
    prodNameView.view.frame = CGRectMake(0,0, 320, 162);
    UIPickerView *pickerEnquiry = [[UIPickerView alloc] init];
    pickerEnquiry.delegate = self;
    pickerEnquiry.dataSource = self;
    pickerEnquiry.frame  = CGRectMake(0,0, 320, 162);
    pickerEnquiry.showsSelectionIndicator = YES;
    [prodNameView.view addSubview:pickerEnquiry];
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithContentViewController:prodNameView];
    popoverController.cornerRadius = 10;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayEnquiry count];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
        NSString* questions = [arrayEnquiry objectAtIndex:row];
        if ((![questions  isEqual: @"Select Question"]) || !questions) {
            [txtEnquiryType setText:questions];
        }
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        [tView setTextAlignment:NSTextAlignmentCenter];
        [tView setLineBreakMode:0];
    }
    tView.text =  [arrayEnquiry objectAtIndex:row];
    return tView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBack:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self showRightView:sender];
}

- (IBAction)btnSubmit:(id)sender {
    if ([txtEnquiryType.text  isEqual: @""] || [txtEnquiryType.text  isEqual: @"- Select -"]) {
        alertInt = 1;
        [self alertStatus:@"Please select your Enquiry" :@"Error"];
    } else {
        if ([txtMessage.text isEqualToString:@""] || [txtMessage.text isEqualToString:@"Message"]) {
            alertInt = 1;
            [self alertStatus:@"Please input your message" :@"Error"];
        } else {
            alertInt = 1;
            HUB = [[MBProgressHUD alloc]initWithView:self.view];
            [self.view addSubview:HUB];
            [HUB showWhileExecuting:@selector(userSubmit) onTarget:self withObject:nil animated:YES];
        }
    }
}

- (IBAction)btnChat:(id)sender {
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://secure.livechatinc.com/licence/6821671/open_chat.cgi"]];
    //NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    //NSString *tzName = [timeZone name];

     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://yomojo.com.au/chat"]];
}

- (IBAction)btnCallLocal:(id)sender {
    NSString *phoneCallNum = @"tel://1300 966 656";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneCallNum]];
}

- (IBAction)btnCallIntl:(id)sender {
    NSString *phoneCallNum = @"tel://+61 2 8089 1602";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneCallNum]];
}

-(void) userSubmit {
//http://yomojo.com.au/api/contact_us/$firstname/$lastname/$email/$mobile/$message/$inquiry
//    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//    NSString *encodedMessage = [txtMessage.text stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    //NSString* encodedUrl = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"url:%@",encodedUrl);
    //https://yomojo.com.au/api/contact_us?fname=$fname&email=$email&mobileno=$mobileno&message=&message&inquiry=$inquiry
    
    //NSString * strPortalURL = [NSString stringWithFormat:@"https://yomojo.com.au/api/contact_us?fname=%@&lname=%@&email=%@&mobile=%@&message=%@&inquiry=%@",txtFirstName.text,txtLastName.text,txtEmailAdd.text,txtmobileNum.text,txtMessage.text,txtEnquiryType.text];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/contact_us?fname=%@&lname=%@&email=%@&mobile=%@&message=%@&inquiry=%@", PORTAL_URL, txtFirstName.text,txtLastName.text,txtEmailAdd.text,txtmobileNum.text,txtMessage.text,txtEnquiryType.text];
    
    NSString* encodedUrl = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    encodedUrl = [encodedUrl stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSLog(@"url:%@",encodedUrl);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        alertInt = 1;
        [self alertStatus:@"Thank you for contacting us, one of our representatives will get in touch with you shortly." :@"Notification"];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else{
        alertInt = 1;
        NSString *strError = [NSString stringWithFormat:@" %@",error];
        [self alertStatus:strError :@"Error"];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        if (alertInt == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


- (void)showRightView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}




@end
