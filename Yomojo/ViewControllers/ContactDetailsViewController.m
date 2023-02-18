//
//  ContactDetailsViewController.m
//  Yomojo
//
//  Created by Kevin Theodore Gonzales on 05/04/2016.
//  Copyright © 2016 AcquireBPO. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "XmlReader.h"
#import "Constants.h"
//#import <Google/Analytics.h>
@import GooglePlaces;

@interface ContactDetailsViewController () <GMSAutocompleteViewControllerDelegate, UITextViewDelegate>
{
    NSString *title;
    NSString *firstname;
    NSString *lastname;
    NSString *dob;
    NSString *emailaddress;
    GMSAutocompleteFilter *_filter;
    
}
@end

@implementation ContactDetailsViewController
@synthesize urlData,phonesArray,phonesArrayIndex,txtViewAddress,txtEmailAdd,fromFB,lblNotes;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSData *tempUrlData = [userLogin objectForKey:@"urlData"];
    if(tempUrlData){
        urlData = tempUrlData;
    }
    
    NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableContainers error:nil];
    NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
    NSMutableDictionary *responseDict = [resultData objectForKey:@"RESPONSE"];
    
    clientID = [responseDict objectForKey:@"CLIENTID"];
    sessionID = [responseDict objectForKey:@"SESSION_VAR"];
    
    NSMutableArray *personalDetailsArray = [responseDict objectForKey:@"PERSONDETAILS"];
    NSMutableDictionary *personalDetailsDict = [personalDetailsArray objectAtIndex:0];
    txtEmailAdd.text = [personalDetailsDict objectForKey:@"EMAILADDRESS"];
    
    NSString *clientDetailsXML = [responseDict objectForKey:@"CLIENTDETAILS"];
    
    NSDictionary *XMLdict = [XMLReader dictionaryForXMLString:clientDetailsXML error:nil];
    NSDictionary *clientDict = [XMLdict objectForKey:@"client"];
    
    if (fromFB == YES){
        txtEmailAdd.enabled = NO;
        lblNotes.hidden = YES;
    }
    else{
        txtEmailAdd.enabled = YES;
        lblNotes.hidden = NO;
    }
    
    NSDictionary *crnt_address1 = [clientDict objectForKey:@"crnt_address1"];
    NSDictionary *crnt_address2 = [clientDict objectForKey:@"crnt_address2"];
    NSDictionary *crnt_suburb = [clientDict objectForKey:@"crnt_suburb"];
    NSDictionary *crnt_state = [clientDict objectForKey:@"crnt_state"];
    NSDictionary *crnt_postcode = [clientDict objectForKey:@"crnt_postcode"];
    
    NSString *fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", [crnt_address1 objectForKey:@"text"],[crnt_address2 objectForKey:@"text"],[crnt_suburb objectForKey:@"text"],[crnt_state objectForKey:@"text"],[crnt_postcode objectForKey:@"text"]];
    fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    fullAddress = [fullAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    txtViewAddress.text = fullAddress;
    
    title = [[clientDict objectForKey:@"title"]objectForKey:@"text"];
    title = [title stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    firstname = [[clientDict objectForKey:@"firstname"]objectForKey:@"text"];
    firstname = [firstname stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    lastname = [[clientDict objectForKey:@"lastname"]objectForKey:@"text"];
    lastname = [lastname stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    dob = [[clientDict objectForKey:@"dob"]objectForKey:@"text"];
    dob = [dob stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    emailaddress = [[clientDict objectForKey:@"emailaddress"]objectForKey:@"text"];
    emailaddress = [emailaddress stringByReplacingOccurrencesOfString:@"\n                        " withString:@""];
    
    if ([txtEmailAdd.text  isEqual: @""]) {
        txtEmailAdd.text = emailaddress;
    }
    
    if ([txtViewAddress.text isEqual: @""]) {
        txtViewAddress.text = [self callGetClientDetails];
    }
}

-(NSString*) callGetClientDetails {
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/get_client_details?clientid=%@", PORTAL_URL, clientID];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        NSMutableDictionary *resultsDict = [dictData objectForKey:@"result"];
        NSMutableDictionary *clientDict = [resultsDict objectForKey:@"client"];
        
        NSString *dlv_address1 = [clientDict objectForKey:@"dlv_address1"];
        NSString *dlv_address2 = [clientDict objectForKey:@"dlv_address2"];
        NSString *dlv_suburb = [clientDict objectForKey:@"dlv_suburb"];
        NSString *dlv_state = [clientDict objectForKey:@"dlv_state"];
        NSString *dlv_postcode = [clientDict objectForKey:@"dlv_postcode"];
        
        NSString *fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", dlv_address1, dlv_address2, dlv_suburb, dlv_state, dlv_state, dlv_postcode];
        
        fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@"{\n}" withString:@""];
        
        return fullAddress;
    }
    return @"";
}

-(void)dismissKeyboard {
    [txtEmailAdd resignFirstResponder];
    [txtViewAddress resignFirstResponder];
}


- (void) alertStatus:(NSString *)msg :(NSString *)strTitle
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strTitle
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(IBAction)backBtnAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)btnSave:(id)sender {
    if (![txtEmailAdd.text  isEqual: @""]) {
        BOOL validEmail = [self NSStringIsValidEmail:txtEmailAdd.text];
        if (validEmail == NO) {
            [self alertStatus:@"Email address invalid" :@"Failed"];
        } else {
            if (![txtViewAddress.text isEqual: @""]) {
                HUB = [[MBProgressHUD alloc]initWithView:self.view];
                [self.view addSubview:HUB];
                [HUB showWhileExecuting:@selector(saveData) onTarget:self withObject:nil animated:YES];
            } else {
                [self alertStatus:@"Please enter Billing Address" :@"Failed"];
            }
        }
    } else {
        [self alertStatus:@"Please enter email address" :@"Failed"];
    }
}

- (void) saveData {
    //get location
    
    NSString * strPortalURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?&address=%@&key=AIzaSyCDjW3CoOXokm0MJ1FhvtpHah08FuZeGII",txtViewAddress.text];
    NSString* encodedUrl = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        
        NSMutableArray *resultsArray = [dictData objectForKey:@"results"];
        
        if ([resultsArray count] > 0)  {
            NSMutableDictionary *resultsDataIndex0 = [[dictData objectForKey:@"results"] objectAtIndex:0];
            NSMutableArray * address_components = [resultsDataIndex0 objectForKey:@"address_components"];
            
            NSString *street_number = @"";
            NSString *route = @"";
            NSString *locality = @"";
            NSString *administrative_area_level_1 = @"";
            NSString *postal_code = @"";
            
            for (int i=0; i < [address_components count]; i++) {
                NSMutableDictionary *arrayAddress = [address_components objectAtIndex:i];
                NSString *short_name = [arrayAddress objectForKey:@"short_name"];
                NSString *types = [[arrayAddress objectForKey:@"types"] objectAtIndex:0];
                
                if ([types  isEqual: @"street_number"]) {
                    street_number = short_name;
                } else if ([types  isEqual: @"route"]) {
                    route = short_name;
                } else if ([types  isEqual: @"locality"]) {
                    locality = short_name;
                } else if ([types  isEqual: @"administrative_area_level_1"]) {
                    administrative_area_level_1 = short_name;
                } else if ([types  isEqual: @"postal_code"]) {
                    postal_code = short_name;
                }
            }
            NSString * strPortalURL = [NSString stringWithFormat:@"%@/update_contact_details?clientid=%@&title=%@&firstname=%@&lastname=%@&dob=%@&subpremise=%@&street_number=%@&route=%@&locality=%@&admin_area=%@&postal_code=%@&email=%@", PORTAL_URL, clientID,title,firstname,lastname,dob,@"",street_number,route,locality,administrative_area_level_1,postal_code,txtEmailAdd.text];
            
            
            NSString* encodedUrl = [strPortalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"url:%@",encodedUrl);
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:encodedUrl]];
            request.HTTPMethod = @"GET";
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * purlData = [NSURLConnection sendSynchronousRequest:request
                                                      returningResponse:&response
                                                                  error:&error];
            if (!error) {
                NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
                NSLog(@"responseData: %@",responseData);
                
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *resultData = [dictData objectForKey:@"result"];
                NSString *resultText = [resultData objectForKey:@"RESULTTEXT"];
                
                if (resultText) {
                    if ([resultText  isEqual: @"Success"]){
                        [self updateURLData];
                        [self alertStatus:@"Contact details updated." :@"Success"];
                    } else {
                        resultText = [resultText stringByReplacingOccurrencesOfString:@"func_editClient.cfm Failed - func_editPerson.cfm Failed - ERROR - " withString:@""];
                        resultText = [resultText stringByReplacingOccurrencesOfString:@"func_editClient.cfm Failed - ERROR - crnt" withString:@""];
                        resultText = [resultText stringByReplacingOccurrencesOfString:@"func_editClient.cfm Failed - ERROR -" withString:@""];
                        [self alertStatus:resultText :@"Error"];
                    }
                } else {
                    [self updateURLData];
                    [self alertStatus:@"Contact details updated." :@"Success"];
                }
            } else {
                NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
                [self alertStatus:strError :@"Failed"];
            }
        } else {
            [self alertStatus:@"An error was occurred, please check inputted data" :@"Failed"];
        }
    }
}
-(void) updateURLData{
    NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
    NSString *userPassword = [userLogin objectForKey:@"Password"];
    
    NSString * strPortalURL = [NSString stringWithFormat:@"%@/login/%@/%@", PORTAL_URL, txtEmailAdd.text,userPassword];
    
    NSLog(@"strURL: %@",strPortalURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    urlData = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&response
                                                error:&error];
    
    [userLogin setObject:urlData forKey:@"urlData"];
}

- (IBAction)btnCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnRefresh:(id)sender {
    [self updateURLData];
}

// Add a UIButton in Interface Builder, and connect the action to this function.
- (IBAction)getCurrentPlace:(UIButton*)sender {
    
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    
    // Specify the place data types to return.
    GMSPlaceField fields = (GMSPlaceFieldAll);
    acController.placeFields = fields;
    
    // Specify a filter.
    _filter = [[GMSAutocompleteFilter alloc] init];
    _filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    _filter.country = @"AU";
    acController.autocompleteFilter = _filter;
    
    // Display the autocomplete view controller.
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place ID %@", place.placeID);
    NSLog(@"Place attributions %@", place.attributions.string);
    self.txtViewAddress.text = place.formattedAddress;
    
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
