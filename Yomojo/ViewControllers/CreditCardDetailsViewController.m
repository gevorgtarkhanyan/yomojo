//
//  CreditCardDetailsViewController.m
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "CreditCardDetailsViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import <CommonCrypto/CommonDigest.h>
#import "Constants.h"
#import "NTMonthYearPicker.h"

@interface CreditCardDetailsViewController ()
@end

@implementation CreditCardDetailsViewController
@synthesize clientID,sessionID;
@synthesize lblCardNumber, txtCardType, txtCardName, txtCarNum1, cardCCV,btnSave,btnCardType,lblCreditCardNum,strPassword,strUserName,imgCreditCardLogo,lblCardExpiry,btnExpiryDateMonth, btnExpiryDateYear,txtExpiryDate,lblExpiryDate,lblValidThru;
@synthesize btnMonth, cardExpMM, btnYear, cardExpYY, yearPicker, viewEditCard;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
    [btnCardType addTarget:self action:@selector(showCardType:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnExpiryDateMonth addTarget:self action:@selector(showCardExpiryMonth:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnExpiryDateYear addTarget:self action:@selector(showCardExpiryYear:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [cardCCV addTarget:self action:@selector(limitCVV:) forControlEvents:UIControlEventEditingChanged];
    [cardExpMM addTarget:self action:@selector(limitcardExpMM:) forControlEvents:UIControlEventEditingChanged];
    [cardExpYY addTarget:self action:@selector(limitcardExpYY:) forControlEvents:UIControlEventEditingChanged];
    
    [txtCarNum1 addTarget:self action:@selector(setupCardNum:) forControlEvents:UIControlEventEditingChanged];
    
    cardTypeArrayData = [[NSMutableArray alloc]init];
    [cardTypeArrayData addObject:@"- SELECT -"];
    [cardTypeArrayData addObject:@"Visa"];
    [cardTypeArrayData addObject:@"MasterCard"];
    [cardTypeArrayData addObject:@"Amex"];
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    strUserName = [userLogin objectForKey:@"strUserName"];
    strPassword = [userLogin objectForKey:@"strPassword"];
    
    self.cardExpMM.delegate=self;
    self.cardExpYY.delegate=self;
    self.cardCCV.delegate=self;
    self.txtCarNum1.delegate=self;
    self.txtCardName.delegate=self;
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(checkUserCard) onTarget:self withObject:nil animated:YES];
}


-(void)setupCardNum:(UITextField *)textField {
    if ([txtCardType.text isEqualToString: @"Amex"]) {
        if ([textField.text length] > 15) {
            txtCarNum1.text = [textField.text substringToIndex:15];
        }
    } else {
        if ([textField.text length] > 16) {
            txtCarNum1.text = [textField.text substringToIndex:16];
        }
    }
}

-(void)limitCVV:(UITextField *)textField {
    if ([txtCardType.text  isEqual: @"Amex"]){
        if ([textField.text length] > 4) {
            cardCCV.text = [textField.text substringToIndex:4];
        }
    } else {
        if ([textField.text length] > 3) {
            cardCCV.text = [textField.text substringToIndex:3];
        }
    }
}

-(void)limitcardExpMM:(UITextField *)textField {
    if ([textField.text length] > 2) {
        cardExpMM.text = [textField.text substringToIndex:2];
    }
}

-(void)limitcardExpYY:(UITextField *)textField {
    if ([textField.text length] > 2) {
        cardExpYY.text = [textField.text substringToIndex:2];
    }
}

- (void)showCardExpiryMonth:(id)sender forEvent:(UIEvent*)event{
    
    [self dismissKeyboard];
    UIViewController *prodNameView = [[UIViewController alloc]init];
    prodNameView.view.frame = CGRectMake(0,0, 200, 150);
    monthPicker = [[UIPickerView alloc] init];
    monthPicker.delegate = self;
    monthPicker.dataSource = self;
    monthPicker.frame  = CGRectMake(0,0, 200, 150);
    monthPicker.showsSelectionIndicator = YES;
    [prodNameView.view addSubview:monthPicker];
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];

    NSDateComponents *yearPickerComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:yearPicker.date];

    if (yearPickerComponents.year == components.year && (!cardExpMM.text || cardExpMM.text.length == 0)) {
    
        [monthPicker selectRow:components.month - 1 inComponent:0 animated:YES];
        
        NSArray *months = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];

        cardExpMM.text = [months objectAtIndex:components.month - 1];
    } else if (cardExpMM.text && cardExpMM.text.length > 0) {
        [monthPicker selectRow:[cardExpMM.text integerValue] - 1 inComponent:0 animated:YES];
    }
    
    popoverController = [[TSPopoverController alloc] initWithContentViewController:prodNameView];
    popoverController.cornerRadius = 5;
    //popoverController.titleText = @"Select account";
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
    
}

-(void)showCardExpiryYear:(id)sender forEvent:(UIEvent*)event{
    
    [self dismissKeyboard];
    
    NSDate *todaysDate = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:15];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *targetDate = [calendar dateByAddingComponents:components toDate:todaysDate options:0];
    
    UIViewController *fromNameView = [[UIViewController alloc]init];
    fromNameView.view.frame = CGRectMake(0,0, 200, 150);
    
    yearPicker = [[NTMonthYearPicker alloc] initWithFrame:CGRectMake(0,0, 200, 150)];
    yearPicker.datePickerMode = NTMonthYearPickerModeYear;
    yearPicker.minimumDate = [NSDate date];
    yearPicker.maximumDate = targetDate;
    [yearPicker addTarget:self action:@selector(onDatePicked:) forControlEvents:UIControlEventValueChanged];
    
    [fromNameView.view addSubview:yearPicker];
    
    popoverController = [[TSPopoverController alloc] initWithContentViewController:fromNameView];
    popoverController.cornerRadius = 10;
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

- (void)onDatePicked:(UITapGestureRecognizer *)gestureRecognizer {
    [self updateLabel];
}

- (void)updateLabel {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM yy"];
    NSString *dateStr = [df stringFromDate:yearPicker.date];
    NSArray *splitDate = [dateStr componentsSeparatedByString:@" "];
//    cardExpMM.text = [splitDate objectAtIndex:0];
    cardExpYY.text = [splitDate objectAtIndex:1];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];

    NSDateComponents *yearPickerComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:yearPicker.date];

    if (yearPickerComponents.year == components.year) {
        [monthPicker selectRow:components.month - 1 inComponent:0 animated:YES];
        
        NSArray *months = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];

        cardExpMM.text = [months objectAtIndex:components.month - 1];
    }
}

-(void)showCardType:(id)sender forEvent:(UIEvent*)event{
    [self dismissKeyboard];
    UIViewController *prodNameView = [[UIViewController alloc]init];
    prodNameView.view.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 100);
    pickerCardType = [[UIPickerView alloc] init];
    pickerCardType.delegate = self;
    pickerCardType.dataSource = self;
    pickerCardType.frame  = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 120);
    pickerCardType.showsSelectionIndicator = YES;
    [prodNameView.view addSubview:pickerCardType];
    popoverController = [[TSPopoverController alloc] initWithContentViewController:prodNameView];
    popoverController.cornerRadius = 5;
    //popoverController.titleText = @"Select account";
    popoverController.popoverBaseColor = [UIColor whiteColor];
    popoverController.popoverGradient= NO;
    [popoverController showPopoverWithTouch:event];
}

-(void)dismissKeyboard {
    [txtCardType resignFirstResponder];
    [txtCardName resignFirstResponder];
    [txtCarNum1 resignFirstResponder];
    [cardExpMM resignFirstResponder];
    [cardExpYY resignFirstResponder];
    [cardCCV resignFirstResponder];
    
    if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

- (void) alertStatus:(NSString *)msg :(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void) checkUserCard {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->lblCardNumber.text = @"";
        self->lblCardExpiry.text = @"";
        
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/show_basic_cc_info/%@/%@", PORTAL_URL, self->clientID, self->sessionID];
        
        NSLog(@"strURL: %@",strPortalURL);
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        request.HTTPMethod = @"GET";
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
        if (!error) {
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseData: %@",responseData);
            NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
            NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
            NSMutableDictionary *attributes = [resultData objectForKey:@"@attributes"];
            NSString *resultText = [NSString stringWithFormat:@"%@",[attributes objectForKey:@"RESULTTEXT"]];
            if ([resultText isEqualToString:@"Success"]) {
                if ([[resultData objectForKey:@"account"] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *account = [resultData objectForKey:@"account"];
                    for (int i=0; [account count] > i; i++) {
                        NSMutableDictionary *dictAccount = [account objectAtIndex:i];
                        NSString *isActive = [dictAccount objectForKey:@"active"];
                        if ([isActive  isEqual: @"YES"]) {
                            self->lblValidThru.hidden = NO;
                            
                            NSString *acc_expiry = [dictAccount objectForKey:@"acc_expiry"];
                            NSString *acc_pan = [dictAccount objectForKey:@"acc_pan"];
                            NSString * acc_panFirstFour = [acc_pan substringWithRange:NSMakeRange(0, 4)];
                            NSString * acc_panSecond = [acc_pan substringWithRange:NSMakeRange(4,4)];
                            NSString *acc_panLastThree = [acc_pan substringFromIndex: [acc_pan length] - 3];
                            
                            self->lblCardNumber.text = [NSString stringWithFormat:@"%@ %@ .... %@",acc_panFirstFour,acc_panSecond,acc_panLastThree];
                            if (([acc_panFirstFour intValue] >= 3000) && ([acc_panFirstFour intValue] < 4000)) {
                                self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_AMEX"];
                            }
                            if (([acc_panFirstFour intValue] >= 4000) && ([acc_panFirstFour intValue] < 5000)) {
                                self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_VISA"];
                            }
                            if (([acc_panFirstFour intValue] >= 5000) && ([acc_panFirstFour intValue] < 6000)) {
                                self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_MasterCard"];
                            }
                            
                            if ([[dictAccount objectForKey:@"acc_expiry"] isKindOfClass:[NSString class]]) {
                                NSArray* arrayAccExpiry = [acc_expiry componentsSeparatedByString: @"-"];
                                NSString *accYear = [arrayAccExpiry objectAtIndex:0];
                                accYear = [accYear substringFromIndex: [accYear length] - 2];
                                self->lblCardExpiry.text = [NSString stringWithFormat:@"%@/%@",[arrayAccExpiry objectAtIndex:1],accYear];
                                
                                
                            }
                        }
                    }
                }
                if ([[resultData objectForKey:@"account"] isKindOfClass:[NSDictionary class]]){
                    NSMutableDictionary *dictAccount = [resultData objectForKey:@"account"];
                    NSString *isActive = [dictAccount objectForKey:@"active"];
                    
                    if ([isActive  isEqual: @"YES"]) {
                        self->lblValidThru.hidden = NO;
                        
                        NSString *acc_expiry = [dictAccount objectForKey:@"acc_expiry"];
                        NSString *acc_pan = [dictAccount objectForKey:@"acc_pan"];
                        
                        NSString * acc_panFirstFour = [acc_pan substringWithRange:NSMakeRange(0, 4)];
                        NSString * acc_panSecond = [acc_pan substringWithRange:NSMakeRange(4,4)];
                        NSString * acc_panLastThree = [acc_pan substringFromIndex: [acc_pan length] - 3];
                        
                        self->lblCardNumber.text = [NSString stringWithFormat:@"%@ %@ .... %@",acc_panFirstFour,acc_panSecond,acc_panLastThree];
                        if (([acc_panFirstFour intValue] >= 3000) && ([acc_panFirstFour intValue] < 4000)) {
                            self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_VISA"];
                        }
                        if (([acc_panFirstFour intValue] >= 4000) && ([acc_panFirstFour intValue] < 5000)) {
                            self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_VISA"];
                        }
                        if (([acc_panFirstFour intValue] >= 5000) && ([acc_panFirstFour intValue] < 6000)) {
                            self->imgCreditCardLogo.image = [UIImage imageNamed:@"CreditCardLogo_MasterCard"];
                        }
                        
                        if ([[dictAccount objectForKey:@"acc_expiry"] isKindOfClass:[NSString class]]) {
                            NSArray* arrayAccExpiry = [acc_expiry componentsSeparatedByString: @"-"];
                            NSString *accYear = [arrayAccExpiry objectAtIndex:0];
                            accYear = [accYear substringFromIndex: [accYear length] - 2];
                            self->lblCardExpiry.text = [NSString stringWithFormat:@"%@/%@",[arrayAccExpiry objectAtIndex:1],accYear];
                        }
                    }
                }
            } else {
                resultText = [NSString stringWithFormat:@"%@",[resultData objectForKey:@"RESULTTEXT"]];
                NSString *strError = [resultText stringByReplacingOccurrencesOfString:@"func_getClientAccounts.cfm Failed - " withString:@""];
                
                strError = @"There was a problem with your credit card, please try again";
                
                [self alertStatus:strError:@"Error"];
            }
        } else {
            NSLog(@"Error: %@",error);
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
            [self alertStatus:strError:@"Error"];
        }
    });
}

-(IBAction)backBtnAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSave:(id)sender {
    [self dismissKeyboard];
    
    if (([txtCardName.text  isEqual: @""]) ||  ([txtCarNum1.text  isEqual: @""]) ||  ([cardExpMM.text  isEqual: @""]) ||  ([cardExpYY.text  isEqual: @""])){
        [self alertStatus:@"Please enter credit card details and try again.":@"Error"];
    } else {
        if ([txtCardType.text  isEqual: @"Amex"]){
            if ([cardCCV.text length] == 4) {
                HUB = [[MBProgressHUD alloc]initWithView:self.view];
                [self.view addSubview:HUB];
                [HUB showWhileExecuting:@selector(saveCreditCardInfo) onTarget:self withObject:nil animated:YES];
                viewEditCard.hidden = YES;
            } else {
                [self alertStatus:@"CVV should be 4 digits":@"Error"];
            }
        } else {
            if ([cardCCV.text length] == 3) {
                HUB = [[MBProgressHUD alloc]initWithView:self.view];
                [self.view addSubview:HUB];
                [HUB showWhileExecuting:@selector(saveCreditCardInfo) onTarget:self withObject:nil animated:YES];
                viewEditCard.hidden = YES;
            } else {
                [self alertStatus:@"CVV should be 3 digits":@"Error"];
            }
        }
    }
}

- (IBAction)btnEdit:(id)sender {
    viewEditCard.hidden = NO;
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

-(void) saveCreditCardInfo{
    NSString *cardNumFull = [txtCarNum1.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/cc_post?card_number=%@&card_cvv=%@&card_type=%@&card_expiry=%@/%@&card_name=%@", PORTAL_URL, cardNumFull,cardCCV.text,txtCardType.text,cardExpMM.text,cardExpYY.text,txtCardName.text];
    
    NSString* encodedUrl = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url:%@",encodedUrl);
    
    NSLog(@"strURL: %@",encodedUrl);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * urlData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        NSString *return_cc = [dictData objectForKey:@"return_cc"];
        int errorStatus = [[dictData objectForKey:@"error"] intValue];
        if (errorStatus == 1) {
            NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
            strError = return_cc;
            strError = @"There was a problem with your credit card, please try again";
            [self alertStatus:strError:@"Error"];
        } else {
            NSError *jsonError;
            NSData *objectData = [return_cc dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
            NSMutableDictionary * dict2 = [jsonInfo objectForKey:@"2"];
            NSString *externalResponse = [dict2 objectForKey:@"externalResponse"];
            
            if ([externalResponse  isEqual: @"Successful"]) {
                [self saveToEAP:return_cc];
            } else {
                externalResponse = @"There was a problem with your credit card, please try again";
                [self alertStatus:externalResponse:@"Error"];
            }
        }
    } else {
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
        [self alertStatus:strError:@"Error"];
    }
}

-(void) saveToEAP: (NSString *)crn {
    
    NSError *jsonError;
    NSData *objectData = [crn dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
    
    NSDictionary * dictResult = [jsonInfo objectForKey:@"RESULT"];
    NSString *pan = [dictResult objectForKey:@"pan"];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/addAccount", PORTAL_URL];
    
    NSLog(@"strURL: %@",strPortalURL);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate, br"];
    [request addRequestHeader:@"Accept-Language" value:@"en-US,en;q=0.5"];
    [request addRequestHeader:@"Connection" value:@"keep-alive"];
    [request setPostValue:pan forKey:@"pan"];
    [request setPostValue:clientID forKey:@"clientid"];
    [request setPostValue:sessionID forKey:@"sessvar"];
    [request setPostValue:crn forKey:@"crn"];
    [request startSynchronous];
    NSData *urlData = [request responseData];
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
        NSMutableDictionary *result = [dictData objectForKey:@"result"];
        NSString *resultText = [result objectForKey:@"RESULTTEXT"];
        
        if ([resultText  isEqual: @"Success"]) {
            [self checkUserCard];
            [self alertStatus:@"Credit Card Successfully Updated":@"Success"];
        } else {
            NSString *strError = [resultText stringByReplacingOccurrencesOfString:@"func_addAccount.cfm Failed - ERROR:" withString:@""];
            strError = @"There was a problem with your credit card, please try again";
            
            [self alertStatus:strError:@"Error"];
        }
    } else {
        NSLog(@"Error: %@",error);
        NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        strError = [strError stringByReplacingOccurrencesOfString:@"func_doLogin.cfm Failed -" withString:@""];
        [self alertStatus:strError:@"Error"];
    }
}

#define kOFFSET_FOR_KEYBOARD 200.0

-(void)textFieldDidBeginEditing:(UITextField *)sender {
    if  (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    return NO;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    } else {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if ([thePickerView isEqual:monthPicker]) {
        return 12;
    }
    return [cardTypeArrayData count];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([thePickerView isEqual:monthPicker]) {
       
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];

        NSDateComponents *yearPickerComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:yearPicker.date];
        
        NSArray *months = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];

        if ((yearPicker.date && yearPickerComponents.year == components.year && [[months objectAtIndex:row] integerValue] < components.month) || (!yearPicker.date && [[months objectAtIndex:row] integerValue] < components.month)) {
        
            [thePickerView selectRow:components.month - 1 inComponent:0 animated:YES];
            cardExpMM.text = [months objectAtIndex:components.month - 1];
            
        } else {
            
            cardExpMM.text = [months objectAtIndex:row];
            
        }
        
    } else {
        
        if (thePickerView == pickerCardType) {
            txtCardType.text = [cardTypeArrayData objectAtIndex:row];
            if ([txtCardType.text isEqual:@"- SELECT -"]) {
                txtCardType.text = @"";
            } else {
                txtCardType.text = [cardTypeArrayData objectAtIndex:row];
                cardCCV.text = @"";
                txtCarNum1.text = @"";
                txtCardName.text = @"";
                cardExpMM.text = @"";
                cardExpYY.text = @"";
                if ([txtCardType.text isEqualToString:@"Amex"]) {
                    txtCarNum1.placeholder = @"Card Number (xxxx xxxxxx xxxxx)";
                } else {
                    txtCarNum1.placeholder = @"Card Number (xxxx xxxx xxxx xxxx)";
                }
                
                [popoverController dismissPopoverAnimatd:YES];
            }
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    if ([thePickerView isEqual:monthPicker]) {
        
        NSArray *months = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];
        
        UILabel* tView = (UILabel*)view;
        if (!tView){
            tView = [[UILabel alloc] init];
        }
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:18.5]];
        [tView setTextColor:[UIColor darkGrayColor]];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.text = [months objectAtIndex:row];
        return tView;
    }
    
    if (thePickerView == pickerCardType) {
        UILabel* tView = (UILabel*)view;
        if (!tView){
            tView = [[UILabel alloc] init];
        }
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:18.5]];
        [tView setTextColor:[UIColor darkGrayColor]];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.text = [cardTypeArrayData objectAtIndex:row];
        return tView;
    }
    return nil;
}
@end
