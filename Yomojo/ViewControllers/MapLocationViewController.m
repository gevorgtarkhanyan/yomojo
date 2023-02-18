//
//  MapLocationViewController.m
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import "MapLocationViewController.h"
#import "MyAnnotation.h"
#import "UIImageView+WebCache.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "Constants.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MapLocationViewController ()
@end

@implementation MapLocationViewController
@synthesize mapView, coordinateY, coordinateX, authToken, childArray, arrayData, selectedChild, childArrayList, LCURLLocation, lblChildCurrentStatus, onlineInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(checkOnlineStatusSelected) onTarget:self withObject:nil animated:YES];
    
    self.mapView.delegate=self;
    [self showMapLocation];
    
    //[self callWebSocket];
    
    //NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self selector: @selector(refreshMapLocation:) userInfo: nil repeats: YES];
}

- (void)checkOnlineStatusSelected {
    LCURLLocation = FAMILY_URL;
    onlineInfo = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *selectedChildArray = [[NSMutableArray alloc]init];
    for (int i=0; i < [selectedChild count]; i++)  {
        BOOL boolSelected = [[selectedChild objectAtIndex:i] boolValue];
        if (boolSelected == YES) {
            NSMutableDictionary* childDict = [childArrayList objectAtIndex:i];
            [selectedChildArray addObject:childDict];
        }
    }
    
    for (int i=0; i < [selectedChildArray count]; i++)  {
        NSData *purlData = [[NSData alloc] init];
        NSMutableDictionary* childDict = [selectedChildArray objectAtIndex:i];
        NSString* childID = [childDict objectForKey:@"id"];
        
        NSString * strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/request_current_location/%@",LCURLLocation,childID];
        
        //NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/children/current_location/%@",LCURLLocation,childID];
        
        NSLog(@"strPortalURL: %@",strPortalURL);
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request addRequestHeader:@"Auth-Token" value:authToken];
        [request startSynchronous];
        purlData = [request responseData];
        NSError *error = [request error];
        if (!error) {
            NSString* strMessage = @"0";
            NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
            NSLog(@"responseData Online: %@",responseData);
            if (![responseData  isEqual: @""]) {
                NSMutableDictionary *dictData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
                strMessage = [dictData objectForKey:@"success"];
                NSString *messageString = [dictData objectForKey:@"message"];
                NSString *messageKey = [NSString stringWithFormat:@"%@_message",childID];
                if ([strMessage intValue] == 1) {
                    [onlineInfo setObject:@"0" forKey:childID];
                }
                else{
                    [onlineInfo setObject:@"1" forKey:childID];
                    [onlineInfo setObject:messageString forKey:messageKey];
                }
            }
            else{
                NSLog(@"Error: no server response");
                [onlineInfo setObject:@"1" forKey:childID];
                NSString *messageKey = [NSString stringWithFormat:@"%@_message",childID];
                NSString *strError = [NSString stringWithFormat:@"Server not responding: %@",[error localizedDescription]];
                [onlineInfo setObject:strError forKey:messageKey];
            }
        }
        else{
            NSLog(@"Error: %@",error);
            [onlineInfo setObject:@"1" forKey:childID];
            NSString *messageKey = [NSString stringWithFormat:@"%@_message",childID];
            NSString *strError = [NSString stringWithFormat:@"Device unreachable: %@",[error localizedDescription]];
            [onlineInfo setObject:strError forKey:messageKey];
        }
    }
}

-(void) refreshMapLocation:(NSTimer*) t
{
    lblChildCurrentStatus.text = @"";
    LCURLLocation = FAMILY_URL;
    NSString *strPortalURL = [NSString stringWithFormat:@"%@/api-ca/v1/children/locations",LCURLLocation];
    NSLog(@"strPortalURL: %@",strPortalURL);
    NSLog(@"authToken: %@",authToken);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strPortalURL]];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Auth-Token" value:authToken];
    [request startSynchronous];
    NSData *purlData = [request responseData];
    NSError *error = [request error];
    if (!error) {
        NSString *responseData = [[NSString alloc]initWithData:purlData encoding:NSUTF8StringEncoding];
        NSLog(@"responseData: %@",responseData);
        
        NSMutableArray *selectedChildArray = [[NSMutableArray alloc]init];
        for (int i=0; i < [selectedChild count]; i++)  {
            BOOL boolSelected = [[selectedChild objectAtIndex:i] boolValue];
            if (boolSelected == YES) {
                NSMutableDictionary* childDict = [childArrayList objectAtIndex:i];
                [selectedChildArray addObject:childDict];
            }
        }
        arrayData = [NSJSONSerialization JSONObjectWithData:purlData options:NSJSONReadingMutableContainers error:nil];
        childArray = selectedChildArray;
        [self showMapLocation];
    }
    else{
        NSLog(@"Error: %@",error);
        //NSString *strError = [NSString stringWithFormat:@"%@",[error localizedDescription]];
        //[self alertStatus:strError :@"Network error"];
    }
}

-(void) showMapLocation {
    [mapView removeAnnotations:mapView.annotations];
    
    coordinateX = 0.0;
    coordinateY = 0.0;
    NSMutableArray* annotations=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[childArray count]; i++){
        NSMutableDictionary* childDict = [childArray objectAtIndex:i];
        NSString *childName = [childDict objectForKey:@"name"];
        int childID = [[childDict objectForKey:@"id"] intValue];
        
        for (int a=0; a < [arrayData count]; a++) {
            id object = arrayData[a];
            if (object != (id)[NSNull null]){
                NSMutableDictionary *dictData = [[NSMutableDictionary alloc]init];
                dictData = [arrayData objectAtIndex:a];
                if (dictData) {
                    int childIDFromData = [[dictData objectForKey:@"child_id"] intValue];
                    if (childID == childIDFromData) {
                        
                        mapView.showsUserLocation = YES;
                        
                        coordinateX = [[dictData objectForKey:@"lat"] doubleValue];
                        coordinateY = [[dictData objectForKey:@"long"] doubleValue];
                        
                        CLLocationCoordinate2D theCoordinate;
                        theCoordinate.latitude = coordinateX;
                        theCoordinate.longitude = coordinateY;
                        
                        MyAnnotation* myAnnotation=[[MyAnnotation alloc] init];
                        myAnnotation.coordinate=theCoordinate;
                        
                        //myAnnotation.title = childName;
                        NSString *deviceName = [dictData objectForKey:@"device"];
                        myAnnotation.title = [NSString stringWithFormat:@"%@ - %@",childName, deviceName];
                        
                        // last date located by server
                        NSString *createdDate = [dictData objectForKey:@"created_at"];
                        NSDateFormatter *df = [NSDateFormatter new];
                        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        NSDate *dateCreated = [df dateFromString:createdDate];
                        
                        NSDate* date1 = [NSDate date];
                        NSDate* date2 = dateCreated;
                        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
                        
                        NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
                        NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date2  toDate:date1  options:0];
                        NSLog(@"Break down: %li min : %li hours : %li days : %li months", (long)[breakdownInfo minute], (long)[breakdownInfo hour], (long)[breakdownInfo day], (long)[breakdownInfo month]);
                        
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
                            lblDate = @"";
                        }
                        
                        myAnnotation.subtitle = lblDate;
                        myAnnotation.arrayIndex = i;
                        
                        [mapView addAnnotation:myAnnotation];
                        mapView.tag = i;
                        [annotations addObject:myAnnotation];
                        
                        MKMapRect flyTo = MKMapRectNull;
                        
                        MKMapPoint annotationPoint = MKMapPointForCoordinate(myAnnotation.coordinate);
                        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 200, 100);
                        if (MKMapRectIsNull(flyTo)) {
                            flyTo = pointRect;
                        }
                        else {
                            flyTo = MKMapRectUnion(flyTo, pointRect);
                        }
                        
                        // Position the map so that all overlays and annotations are visible on screen.
                        mapView.visibleMapRect = flyTo;
                        
                        MKCoordinateRegion region;
                        MKCoordinateSpan span;
                        region.center=mapView.region.center;
                        span.latitudeDelta=mapView.region.span.latitudeDelta *10;
                        span.longitudeDelta=mapView.region.span.longitudeDelta *10;
                        region.span=span;
                        [mapView setRegion:region animated:TRUE];
                        
                        //[mapView selectAnnotation:myAnnotation animated:YES];
                    }
                }
            }
        }
    }
}

//-(void) showMapLocation {
//    mapView.showsUserLocation = YES;
//
//    CLLocationCoordinate2D theCoordinate;
//    theCoordinate.latitude = coordinateX;
//    theCoordinate.longitude = coordinateY;
//    
//    MyAnnotation* myAnnotation=[[MyAnnotation alloc] init];
//    myAnnotation.coordinate=theCoordinate;
//    myAnnotation.title = childName;
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSDate *date = [dateFormatter dateFromString:createdDate];
//    dateFormatter.dateFormat = @"MMM dd, yyyy HH:mm:ss";
//    NSString *pmamDateString = [dateFormatter stringFromDate:date];
//    NSString *lblDate = [NSString stringWithFormat:@"Last location: %@",pmamDateString];
//    myAnnotation.subtitle = lblDate;
//    
//    [mapView addAnnotation:myAnnotation];
//    
//    MKMapRect flyTo = MKMapRectNull;
//    
//    MKMapPoint annotationPoint = MKMapPointForCoordinate(myAnnotation.coordinate);
//    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//    if (MKMapRectIsNull(flyTo)) {
//        flyTo = pointRect;
//    }
//    else {
//        flyTo = MKMapRectUnion(flyTo, pointRect);
//    }
//    
//    // Position the map so that all overlays and annotations are visible on screen.
//    mapView.visibleMapRect = flyTo;
//    
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    region.center=mapView.region.center;
//    span.latitudeDelta=mapView.region.span.latitudeDelta *5;
//    span.longitudeDelta=mapView.region.span.longitudeDelta *5;
//    region.span=span;
//    [mapView setRegion:region animated:TRUE];
//}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //
    //    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    [self.locationManager startUpdatingLocation];
    //    //NSLog(@"%@", [self deviceLocation]);
    //
    //    //View Area
    //    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    //    region.center.latitude = self.locationManager.location.coordinate.latitude;
    //    region.center.longitude = self.locationManager.location.coordinate.longitude;
    //    region.span.longitudeDelta = 0.005f;
    //    region.span.longitudeDelta = 0.005f;
    //    [mapView setRegion:region animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnShowInMap:(id)sender {
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", coordinateX, coordinateY];
    //NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f", coordinateX, coordinateY];
    
    NSLog(@"directionsURL: %@",directionsURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    
}

- (IBAction)btnCenter:(id)sender {
    [self showMapLocation];
}

- (IBAction)btnMapRefesh:(id)sender {
    HUB = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUB];
    [HUB showWhileExecuting:@selector(checkOnlineStatusSelected) onTarget:self withObject:nil animated:YES];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark MKMapViewDelegate
//-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
//{
//    MKAnnotationView *pinView = nil;
//    if(annotation != mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"com.invasivecode.pin";
//        pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil )
//            pinView = [[MKAnnotationView alloc]
//                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//        pinView.canShowCallout = YES;
//        pinView.image = [UIImage imageNamed:@"mapPin.png"];
//    }
//    else {
//        //[mapView.userLocation setTitle:@"I am here"];
//    }
//    return pinView;
//}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MyAnnotation *myAnnotation = (MyAnnotation*) annotation;
    int arrayIndex = myAnnotation.arrayIndex;
    NSMutableDictionary* childDict = [childArray objectAtIndex:arrayIndex];
    
    NSString* identifier = @"Pin";
    MKPinAnnotationView* annView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(annView == nil) {
        annView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
    }
    
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        //UIImage *imgPlaceHolder = [UIImage imageNamed:@"placeholder.png"];
        //annView.image = imgPlaceHolder;
    }
    else{
        NSString* photoURL = [childDict objectForKey:@"photo_source"];
        NSString* childID = [childDict objectForKey:@"id"];
        NSURL* url = [NSURL URLWithString:photoURL];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response,
                                                   NSData * data,
                                                   NSError * error) {
            if (!error){
                UIImageView *imgFromURL = [[UIImageView alloc]init];
                imgFromURL.image = [self imageWithImage:[UIImage imageWithData:data] scaledToSize:CGSizeMake(25, 25)];
                imgFromURL.layer.cornerRadius = imgFromURL.frame.size.height /2;
                imgFromURL.layer.masksToBounds = YES;
                imgFromURL.layer.borderWidth = 0;
                
                //UIImage *imgPlaceHolder = [UIImage imageNamed:@"placeholder.png"];
                
                UIImage *imgPlaceHolder = [UIImage imageNamed:@"mapPopup.png"];
                UIImage *img = [self drawTextName: annView.annotation.title inImage:imgPlaceHolder atPoint:CGPointMake(0, 0)];
                UIImage *imgWithSub = [self drawTextSubName: annView.annotation.subtitle inImage:img atPoint:CGPointMake(0, 0)];
                UIImage *newIMG = [self drawImage:imgFromURL.image bgImage:imgWithSub];
                annView.image = newIMG;
                
                annView.tag = [childID integerValue];
                UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                leftIconView.frame = CGRectMake(leftIconView.frame.origin.x,leftIconView.frame.origin.y, 35.0, 35.0);
                leftIconView.layer.cornerRadius = leftIconView.frame.size.width / 2;
                leftIconView.clipsToBounds = YES;
                annView.leftCalloutAccessoryView = leftIconView;
            }
            else{
                UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"boxedPin.png"]];
                leftIconView.frame = CGRectMake(leftIconView.frame.origin.x,leftIconView.frame.origin.y, 35.0, 35.0);
                annView.leftCalloutAccessoryView = leftIconView;
            }
        }];
    }
    annView.canShowCallout = NO;
    return annView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annView{
    NSInteger childID = annView.tag;
    NSString *messageKey = [NSString stringWithFormat:@"%ld_message",(long)childID];
    NSString *txtMsg = [onlineInfo objectForKey:messageKey];
    if (txtMsg){
        lblChildCurrentStatus.hidden = NO;
        lblChildCurrentStatus.text = [onlineInfo objectForKey:messageKey];
    }
    else{
        lblChildCurrentStatus.hidden = YES;
    }
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annView{
    lblChildCurrentStatus.text = @"";
    lblChildCurrentStatus.hidden = YES;
}

- (UIImage*) drawTextName:(NSString*) text
                  inImage:(UIImage*) myImage
                  atPoint:(CGPoint) point {
    UIGraphicsBeginImageContext(myImage.size);
    [myImage drawInRect:CGRectMake(0, 0, myImage.size.width, myImage.size.height)];
    UITextView *myText = [[UITextView alloc] init];
    myText.frame = CGRectMake(50, 10, 150, 50);
    myText.text = text;
    myText.font = [UIFont fontWithName:@"Arial" size:15.0f];
    myText.textColor = [UIColor darkGrayColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName: myText.font,NSParagraphStyleAttributeName: paragraphStyle};
    [myText.text drawInRect:myText.frame withAttributes:attributes];
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    return myNewImage;
}

- (UIImage*) drawTextSubName:(NSString*) text
                     inImage:(UIImage*) myImage
                     atPoint:(CGPoint) point {
    UIGraphicsBeginImageContext(myImage.size);
    [myImage drawInRect:CGRectMake(0, 0, myImage.size.width, myImage.size.height)];
    UITextView *myText = [[UITextView alloc] init];
    myText.frame = CGRectMake(50, 52, 150, 20);
    myText.text = text;
    myText.font = [UIFont fontWithName:@"Arial" size:12.0f];
    myText.textColor = [UIColor grayColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName: myText.font,NSParagraphStyleAttributeName: paragraphStyle};
    [myText.text drawInRect:myText.frame withAttributes:attributes];
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    return myNewImage;
}


- (UIImage*) drawImage:(UIImage*) fgImage
               bgImage:(UIImage*) bgImage
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [fgImage drawInRect:CGRectMake(15, 15, fgImage.size.width, fgImage.size.height)];
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
