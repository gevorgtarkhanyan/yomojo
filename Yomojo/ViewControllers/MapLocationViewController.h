//
//  MapLocationViewController.h
//  Yomojo
//
//  Created by Arnel Perez on 23/03/2017.
//  Copyright © 2017 AcquireBPO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface MapLocationViewController : UIViewController <MKMapViewDelegate,  CLLocationManagerDelegate>
{
    MBProgressHUD *HUB;
    IBOutlet MKMapView *mapView;
    double coordinateX;
    double coordinateY;
    NSString * authToken;
    NSMutableArray *childArray;
    NSMutableArray *arrayData;
    NSMutableArray * selectedChild;
    NSMutableArray * childArrayList;
    NSString * LCURLLocation;
    IBOutlet UILabel *lblChildCurrentStatus;
    NSMutableDictionary * onlineInfo;
}
@property (strong, nonatomic) NSString * LCURLLocation;
@property (nonatomic) double coordinateX;
@property (nonatomic) double coordinateY;
@property (strong, nonatomic) NSString * authToken;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *childArray;
@property (strong, nonatomic) NSMutableArray *arrayData;
@property (strong, nonatomic) NSMutableArray * selectedChild;
@property (strong, nonatomic) NSMutableArray * childArrayList;
@property (strong, nonatomic) NSMutableDictionary * onlineInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblChildCurrentStatus;


- (IBAction)btnBack:(id)sender;
- (IBAction)btnShowInMap:(id)sender;
- (IBAction)btnCenter:(id)sender;
- (IBAction)btnMapRefesh:(id)sender;



@end
