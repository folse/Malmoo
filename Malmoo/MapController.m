//
//  MapController.m
//  Malmoo
//
//  Created by folse on 3/21/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "MapController.h"
#import "PlaceMark.h"
#import <MapKit/MKAnnotationView.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DirectionController.h"

@interface MapController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocation *currentLocation;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation MapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self markPlace];
    
    [[self locationManager] startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLocation
{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)markPlace
{    
    CLLocationCoordinate2D place;
    place.latitude =  [_shop.latitude doubleValue];
    place.longitude = [_shop.longitude doubleValue];
    
    PlaceMark *placeMark = [[PlaceMark alloc] initWithCoordinate:place];
    placeMark.title = _shop.address;
    
    [self.mapView addAnnotation:placeMark];
    
    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
    [self displayLocation:placeLocation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    if ([annotation isKindOfClass:[PlaceMark class]]) {
        static NSString *annotationIdentifier = @"annotationIdentifier";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (pinView == nil){
            
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            return customPinView;
            
        }else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"ServiceNetworkDetailFromMap" sender:view];
}

- (void)displayLocation:(CLLocation *)location
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    if(location.coordinate.latitude > maxLat)
        maxLat = location.coordinate.latitude;
    if(location.coordinate.latitude < minLat)
        minLat = location.coordinate.latitude;
    if(location.coordinate.longitude > maxLon)
        maxLon = location.coordinate.longitude;
    if(location.coordinate.longitude < minLon)
        minLon = location.coordinate.longitude;
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat + 0.03;
    region.span.longitudeDelta = maxLon - minLon + 0.03;
    
    [_mapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark Location manager
- (CLLocationManager *)locationManager
{
    if (_locationManager != nil)
    {
        return _locationManager;
    }
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [_locationManager setDelegate:self];
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取当前位置" message:@"请检查是否开启定位服务" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = [_locationManager location];
    if (currentLocation){
        
        //        if(!isExcuted){
        //
        //            isExcuted = YES;
        //
                    [[self locationManager] stopUpdatingLocation];
        //
        //            //            V1 get English City Name from Location
        //            //            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        //            //            [geoCoder  reverseGeocodeLocation:currentLocation completionHandler:
        //            //             ^(NSArray *placemarks, NSError *error) {
        //            //
        //            //                 for (CLPlacemark *placemark in placemarks)
        //            //                 {
        //            //                     NSString *city = placemark.locality;
        //            //
        //            //                     if (city.length > 0 ) {
        //            //                         stateString = city;
        //            //                     }else{
        //            //                         stateString = [placemark.addressDictionary objectForKey:@"State"];
        //            //                     }
        //            //
        //            //                     s(stateString);
        //
        //            [USER setFloat:currentLocation.coordinate.latitude forKey:@"latitude"];
        //            [USER setFloat:currentLocation.coordinate.longitude forKey:@"longitude"];
        //
        //            [self displayMyLocation:currentLocation];
        //
        //            //                 }
        //            //
        //            //             }];
        //
        //            //V2
        //            NSString *urlString = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?ak=81a0285053693ac3d5302ad4a58153a0&callback=renderReverse&location=%f,%f&output=xml&pois=0", currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
        //
        //            s(urlString)
        //            NSURL *url = [NSURL URLWithString:urlString];
        //            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //
        //            xmlOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        //
        //                XMLParser.delegate = self;
        //                [XMLParser parse];
        //
        //            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        //
        //                s(error)
        //            }];
        //
        //            [xmlOperation start];
        //        }
    }
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
//{
//    if([elementName isEqualToString:@"city"]) return;
//
//}
//
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
//{
//    _tempString = string;
//}
//
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
//{
//    if ([elementName isEqualToString:@"city"]) {
//        _cityString = _tempString;
//    }
//}
//
//- (void)parserDidEndDocument:(NSXMLParser *)parser
//{
//    [self getServiceNetwork];
//}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DirectionController"]) {
        DirectionController *directionController = segue.destinationViewController;
        [directionController setCurrentLat:[NSString stringWithFormat:@"%f",[_locationManager location].coordinate.latitude]];
        [directionController setCurrentLng:[NSString stringWithFormat:@"%f",[_locationManager location].coordinate.longitude]];
        [directionController setDestinationLat:_shop.latitude];
        [directionController setDestinationLng:_shop.longitude];
    }
}

@end
