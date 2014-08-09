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
#import "MJRefresh.h"

@interface MainController ()<CLLocationManagerDelegate,MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *shopArray;
    NSInteger selectedId;
    BOOL isSelectedFromMap;
    BOOL isSearching;
    UIButton *mapStretchBtn;
    NSArray *resultArray;
    NSArray *clearArray;
    int clearId;
    int pageId;
    UIWebView *webView;
    NSString *apiKey;
    PFObject *currentObject;
    int PAGE_NUM;
    MJRefreshFooterView *_footer;
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
    
    HUD_SHOW
    
    [self removeNavigationBarShadow];
    
    //apiKey = @"AIzaSyC8IfTEGsA4s8I6SB4SZBgT0b2WJR7mkcY";
    
    shopArray = [NSMutableArray new];
    
    [self addFooter];
    
    //sleep(3);
    
    [self refresh];
    
    //    webView = [[UIWebView alloc] init];
    //    [webView setDelegate:self];
    //
    //[self clearData];
        
}

-(void)removeNavigationBarShadow
{
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UIImageView class]] && view2.frame.size.width == 320) {
                [view2 removeFromSuperview];
            }
        }
    }
}

-(void)refresh
{
    [self getShopData:nil];
}

-(void)clearData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    query.skip = pageId * 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            clearArray = objects;
            
            [self findDuplicateData:clearArray[clearId]];
            
            //[self copyPhotoData:clearArray[clearId]];
            
            //[self replaceLocationData:clearArray[clearId]];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)copyPhotoData:(PFObject *)eachObject
{
    NSString *photoUrl = eachObject[@"photo"];
    NSArray *photoArray = eachObject[@"photos"];
    
    if (photoArray.count > 0 && !photoUrl.length > 0) {
        
        s(@"hasPhoto")
        
        NSString *photoReference = eachObject[@"photos"][0][@"photo_reference"];
        
        currentObject = eachObject;
        
        [self getRealImageUrl:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=120&photoreference=%@&sensor=false&key=%@",photoReference,apiKey]];
        
    }else {
        
        clearId += 1;
        
        if(clearId != 100){
            NSLog(@"cIearArrayId:%d",clearId);
            [self copyPhotoData:clearArray[clearId]];
        }else{
            clearId = 0;
            pageId += 1;
            i(pageId)
            [self clearData];
        }
    }
}

-(void)getRealImageUrl:(NSString *)url
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    s(@"load")
    s(request.URL.absoluteString)
    
    if ([request.URL.absoluteString rangeOfString:@"googleusercontent.com"].length > 0) {
        s(request.URL.absoluteString)
        
        [self savePhotoUrl:currentObject withUrl:request.URL.absoluteString];
    }
    
    return YES;
}

-(void)savePhotoUrl:(PFObject *)object withUrl:(NSString *)photoUrl
{
    object[@"photo"] = photoUrl;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        clearId += 1;
        
        if(clearId != 100){
            NSLog(@"cIearArrayId:%d",clearId);
            [self copyPhotoData:clearArray[clearId]];
        }else{
            clearId = 0;
            pageId += 1;
            i(pageId)
            [self clearData];
        }
    }];
}

-(void)findDuplicateData:(PFObject *)eachObject
{
    NSString *name = eachObject[@"name"];
    NSString *address = eachObject[@"formatted_address"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"name" equalTo:name];
    [query whereKey:@"formatted_address" equalTo:address];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count - 1; i++) {
                
                [objects[i] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        s(@"Delete Successful")
                    }
                }];
            }
            
            clearId += 1;
            
            if(clearId != 100){
                [self findDuplicateData:clearArray[clearId]];
            }else{
                clearId = 0;
                pageId += 1;
                i(pageId)
                [self clearData];
            }
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    i(clearId)
}

-(void)replaceLocationData:(PFObject *)eachObject
{
    PFGeoPoint *location = eachObject[@"location"];
    
    if (!location) {
        
        NSString *lat = eachObject[@"geometry"][@"location"][@"lat"];
        NSString *lng = eachObject[@"geometry"][@"location"][@"lng"];
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
        
        eachObject[@"location"] = geoPoint;
        
        [eachObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            clearId += 1;
            
            if(clearId != 100){
                
                NSLog(@"cIearArrayId:%d",clearId);
                
                /* by folse
                 Change this method name
                 */
                
                //[self copyPhotoData:clearArray[clearId]];
                [self replaceLocationData:clearArray[clearId]];
                
            }else{
                
                clearId = 0;
                pageId += 1;
                i(pageId)
                [self clearData];
                
            }
        }];
        
    }else {
        
        clearId += 1;
        
        if(clearId != 100){
            NSLog(@"cIearArrayId:%d",clearId);
            [self copyPhotoData:clearArray[clearId]];
        }else{
            clearId = 0;
            pageId += 1;
            i(pageId)
            [self clearData];
        }
    }
}

-(void)getShopData:(NSString *)keyWords
{
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    query.limit = 30;
    query.skip = PAGE_NUM*30;
    
    if (keyWords) {
        
        [query whereKey:@"metatag" containsString:keyWords];
        
        [self findObjects:query];
        
    }else{
        
        //        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        //            if (!error) {
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:55.596149 longitude:13.004419];
        
        [query whereKey:@"location" nearGeoPoint:geoPoint];
        
        f(geoPoint.latitude)
        f(geoPoint.longitude)
        
        [self findObjects:query];
        //            }
        //        }];
    }
}

-(void)findObjects:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
                
                Shop *shop = [Shop new];
                shop.name = object[@"name"];
                shop.phone = [object[@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                shop.openHours = object[@"openHours"];
                shop.tags = object[@"metatag"];
                shop.avatarUrl = object[@"photo"];
                //shop.address = object[@"address"];
                //shop.avatarUrl = object[@"avatar"];
                //shop.latitude = [object[@"location"] componentsSeparatedByString:@","][0];
                //shop.longitude = [object[@"location"] componentsSeparatedByString:@","][1];
                
                PFGeoPoint *location = object[@"location"];
                
                shop.latitude = [NSString stringWithFormat:@"%f",location.latitude];
                shop.longitude = [NSString stringWithFormat:@"%f",location.longitude];
                shop.address = object[@"formatted_address"];
                shop.starterDishes = object[@"starters"];
                shop.mainDishes = object[@"maindishes"];
                shop.dessertDishes = object[@"desserts"];
                shop.parseObject = object;
                
                [shopArray addObject:shop];
                
                if (shop.avatarUrl.length > 0) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:shopArray.count-1 inSection:0];
                    [self startImageDownload:shop.avatarUrl forIndexPath:index];
                }
            }
            
            [HUD hide:YES];
            [self.tableView reloadData];
            [self.tableView setHidden:NO];
            
            if (PAGE_NUM > 0) {
                [self doneLoadMore];
            }else{
                [self markPlace];
            }
            
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
    
    Shop *cellShop = shopArray[row];
    [cell.titleLabel setText:cellShop.name];
    [cell.addressLabel setText:cellShop.address];
    
    s(cellShop.avatarUrl)
    
    if (cellShop.avatarUrl.length > 0) {
        NSString *imagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:cellShop.avatarUrl];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:imagePath]){
            
            cell.avatarImageView.image = [UIImage imageWithContentsOfFile:imagePath];
            
        }else{
            
            cell.avatarImageView.image = [UIImage imageNamed:@"default_shop_photo"];
            
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startImageDownload:cellShop.avatarUrl forIndexPath:indexPath];
            }
        }
    }else{
        cell.avatarImageView.image = [UIImage imageNamed:@"default_shop_photo"];
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

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        PAGE_NUM += 1;
        
        [self refresh];
        
    };
    _footer = footer;
}

-(void)doneLoadMore
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:shopArray.count-31 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    [_footer endRefreshing];
}

@end
