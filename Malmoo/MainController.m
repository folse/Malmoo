//
//  MainController.m
//  Malmoo
//
//  Created by folse on 3/11/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "MainController.h"
#import "Shop.h"
#import "MainCell.h"
#import "DetailController.h"
#import "FSImageDownloader.h"
#import "PlaceMark.h"
#import <MapKit/MKAnnotationView.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SearchController.h"

@interface MainController ()<CLLocationManagerDelegate,MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *shopArray;
    NSInteger selectedId;
    BOOL isSelectedFromMap;
    BOOL isSearching;
    UIButton *mapStretchBtn;
    NSArray *resultArray;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation MainController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HUD_SHOW
    
    [self getShopData:nil];
    
    [[self locationManager] startUpdatingLocation];
}

-(void)getShopData:(NSString *)keyWords
{
    shopArray = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Shop"];
    if (keyWords) {
        [query whereKey:@"metatag" containsString:keyWords];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
                
                Shop *shop = [Shop new];
                shop.name = object[@"name"];
                shop.address = object[@"address"];
                shop.phone = [object[@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                shop.openHours = object[@"openHours"];
                shop.tags = object[@"metatag"];
                shop.avatarUrl = object[@"avatar"];
                shop.latitude = [object[@"location"] componentsSeparatedByString:@","][0];
                shop.longitude = [object[@"location"] componentsSeparatedByString:@","][1];
                shop.starterDishes = object[@"starters"];
                shop.mainDishes = object[@"maindishes"];
                shop.dessertDishes = object[@"desserts"];
                
                [shopArray addObject:shop];
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:shopArray.count-1 inSection:0];
                [self startImageDownload:shop.avatarUrl forIndexPath:index];
            }
            
            [HUD hide:YES];
            [self.tableView reloadData];
            [self.tableView setHidden:NO];
            
            [self markPlace];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuBtnAction:(id)sender
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return shopArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"MainCell";
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[MainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    Shop *cellShop = shopArray[row];
    [cell.titleLabel setText:cellShop.name];
    [cell.addressLabel setText:cellShop.address];
    
    NSString *imagePath = [[F alloc] getMD5FilePathWithUrl:cellShop.avatarUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]){
        
        cell.avatarImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        
    }else{
        
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startImageDownload:cellShop.avatarUrl forIndexPath:indexPath];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedId = indexPath.row;
    
    [self performSegueWithIdentifier:@"DetailController" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        if (isSelectedFromMap) {
            MKAnnotationView *view = sender;
            PlaceMark *detailPlaceMark = (PlaceMark *)view.annotation;
            selectedId = detailPlaceMark.markId;
            isSelectedFromMap = NO;
        }
        
        Shop *selectedShop = shopArray[selectedId];
        DetailController *detailController = segue.destinationViewController;
        detailController.shop = selectedShop;
        
    }
}

#pragma mark - Table cell image support

-(void)startImageDownload:(NSString *)url forIndexPath:(NSIndexPath *)indexPath
{
    FSImageDownloader *imageDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader == nil)
    {
        imageDownloader = [[FSImageDownloader alloc] init];
        [imageDownloader setCompletionHandler:^(UIImage *image) {
            
            MainCell *cell = (MainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.avatarImageView.image = image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        [self.imageDownloadsInProgress setObject:imageDownloader forKey:indexPath];
        [imageDownloader downloadImageFrom:url];
    }
}

#pragma mark - Map

- (void)markPlace
{
    NSMutableArray *stationList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < shopArray.count; i++) {
        
        Shop *mapShop = [shopArray objectAtIndex:i];
        
        CLLocationCoordinate2D place;
        place.latitude =  [mapShop.latitude doubleValue];
        place.longitude = [mapShop.longitude doubleValue];
        
        PlaceMark *placeMark = [[PlaceMark alloc] initWithCoordinate:place];
        placeMark.title = mapShop.name;
        placeMark.markId = i;
        
        [stationList addObject:placeMark];
    }
    
    if (stationList.count > 0) {
        [self.mapView addAnnotations:stationList];
    }
    
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
            
        }else{
            
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    isSelectedFromMap = YES;
    [self performSegueWithIdentifier:@"DetailController" sender:view];
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
    region.span.latitudeDelta  = maxLat - minLat + 0.01;
    region.span.longitudeDelta = maxLon - minLon + 0.01;
    
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
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取当前位置" message:@"请检查是否开启定位服务" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    //[alert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = [_locationManager location];
    if (currentLocation){
        
        //        if(!isExcuted){
        //
        //            isExcuted = YES;
        //
        
        [self displayLocation:currentLocation];
        
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

@end
