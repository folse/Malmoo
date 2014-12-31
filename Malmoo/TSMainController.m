//
//  MainController.m
//  Malmoo
//
//  Created by folse on 3/11/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSMainController.h"
#import "TSMainCell.h"
#import "TSDetailController.h"
#import "TSPlaceMark.h"
#import <MapKit/MKAnnotationView.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TSSearchController.h"
#import "MJRefresh.h"
#import "TSGuideController.h"


@interface TSMainController ()<CLLocationManagerDelegate,MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *placeArray;
    NSInteger selectedId;
    BOOL isSelectedFromMap;
    BOOL isSearching;
    BOOL isRefreshFromMap;
    BOOL updatedUserLocation;
    UIButton *mapStretchBtn;
    NSArray *resultArray;

    int PAGE_COUNT;
    int PAGE_NUM;
    NSInteger lastDataCount;
    MJRefreshFooterView *_footer;
    
    CLLocation *currentLocation;
    CLLocation *lastMapCenterLocation;
    CLLocationManager *locationManager;
    
    int pageId;
    int clearId;
    int apiKeyId;
    int photoArrayId;
    NSArray *clearArray;
    NSArray *photoArray;
    NSArray *apiKeyArray;
    UIWebView *photoWebView;
    PFObject *currentObject;
    NSString *loadingPhotoUrl;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatiorView;

@end

@implementation TSMainController


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
    
    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:APP_COLOR] forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_activityIndicatiorView setHidden:YES];
    [_activityIndicatiorView stopAnimating];
    
    [self removeNavigationBarShadow];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    apiKeyArray = [NSArray arrayWithObjects:@"AIzaSyC8IfTEGsA4s8I6SB4SZBgT0b2WJR7mkcY",
                   @"AIzaSyC5xWawMGqWOi3VJq0xoLsdGKU84Nf8eLk",
                   @"AIzaSyC6GGSFl-RKY5XgFeGEFNdkLIzC5g5JSpw",
                   @"AIzaSyBCgh8Bmg43FiPBBAjrMj7bJTDpK5wlLZ4",
                   @"AIzaSyAqLUgVvQV1qmN1APpndQJqoF8q1MR-Ls0",
                   @"AIzaSyD7LqPOyd_uwydZgeeWNHIThV3794q2bEY",
                   @"AIzaSyBvs25RjogtWqPDD13ja_iOvC26ODLvQeM",
                   @"AIzaSyAcsvwj8u-Lvvm7gCMKzkzP5p33TVHHEeU",
                   @"AIzaSyCy7uC4Uy974sAyIujoJDKJaIIoVZDtXx4",
                   @"AIzaSyAsFPk3j65gBZZd1QSm9HaJAxscWg_gKY0",
                   @"AIzaSyAeHrJ1pTedhijma8bP1GSu8dZVvPGn77s",
                   @"AIzaSyAKXbdKWEO6xrhe_lk4dk3RTxCtQc8hfVw",
                   @"AIzaSyA_oc9uDRGeC3dkZWD4awlK5uhygss5seg",
                   @"AIzaSyDJxa5YEb1cDhNvt8RGaUjPsmTLVwWNbdc",
                   @"AIzaSyBdwlLFKYF7QbAfMGjtcUS3Lp_-1grDFU0",nil];
    
    PAGE_COUNT = 15;
    
    placeArray = [NSMutableArray new];
    
    [self addFooter];
    
    //sleep(3);
    
    if (USER_LOGIN || USER_SKIP_LOGIN) {
        
        HUD_Define
        [HUD show:YES];
        
    }else{
        
        TSGuideController *guideController = [ACCOUNT_STORYBOARD instantiateViewControllerWithIdentifier:@"GuideController"];
        [self presentViewController:guideController animated:YES completion:nil];
    }
    
    if (_categoryName) {
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(getCategoryPlaceData) object:nil] start];
        
        [_mapView setHidden:YES];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        
        [self.navigationItem setTitle:_categoryName];
        
        [self.tableView setContentInset:UIEdgeInsetsMake(-160, 0, 0, 0)];
        
    }
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    [_mapView setUserInteractionEnabled:YES];
    [_mapView addGestureRecognizer:imageTap];
    
    
    photoWebView = [[UIWebView alloc] init];
    [photoWebView setDelegate:self];
    
    [self clearData];
}

-(void)hideMenu
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    if (sideMenu.isMenuVisible) {
        
        [sideMenu hideMenuAnimated:YES];
    }
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
    [self getData:nil];
}

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)getData:(NSString *)keyWords
{
    PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
    query.limit = PAGE_COUNT;
    query.skip = PAGE_NUM*PAGE_COUNT;
    
    if (keyWords) {
        
        [query whereKey:@"metatag" containsString:keyWords];
        
        [self findObjects:query];
        
    }else{
        
        f(lastMapCenterLocation.coordinate.latitude)
        f(lastMapCenterLocation.coordinate.longitude)
        
        PFGeoPoint *locationPoint = [PFGeoPoint geoPointWithLatitude:lastMapCenterLocation.coordinate.latitude longitude:lastMapCenterLocation.coordinate.longitude];
        
        [query whereKey:@"location" nearGeoPoint:locationPoint];
        [self findObjects:query];
    }
}

-(void)getCategoryPlaceData
{
    placeArray = [NSMutableArray new];
    
    PFQuery *placeCategoryQuery = [PFQuery queryWithClassName:@"Category_Place"];
    PFObject *categoryObject = [placeCategoryQuery getObjectWithId:_categoryObjectId];
    
    PFQuery *placeQuery = [PFQuery queryWithClassName:@"StockholmPlace"];
    [placeQuery whereKey:@"category" containedIn:[NSArray arrayWithObject:categoryObject]];
    placeQuery.limit = PAGE_COUNT;
    placeQuery.skip = PAGE_NUM*PAGE_COUNT;
    [self findObjects:placeQuery];
}

-(void)findObjects:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [_activityIndicatiorView stopAnimating];
            [_activityIndicatiorView setHidden:YES];
            
            if (isRefreshFromMap) {
                [placeArray removeAllObjects];
                isRefreshFromMap = NO;
                PAGE_NUM = 0;
            }
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
                
                TSPlace *place = [TSPlace new];
                place.name = object[@"name"];
                place.phone = object[@"phone"];
                place.openHours = object[@"open_hour"];
                place.avatarUrl = object[@"avatar"];
                place.address = object[@"address"];
                place.descriptions = object[@"description"];
                place.news = object[@"news"];
                place.parking = [object[@"has_park"] boolValue];
                place.alcohol = [object[@"has_alcohol"] boolValue];
                place.delivery = [object[@"delivery"] boolValue];
                place.reservation = [object[@"phone_reservation"] boolValue];
                place.parseObject = object;
                
                PFGeoPoint *location = object[@"location"];
                place.latitude = [NSString stringWithFormat:@"%f",location.latitude];
                place.longitude = [NSString stringWithFormat:@"%f",location.longitude];
                
                if (currentLocation) {
                    
                    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
                    CLLocationDistance meters = [placeLocation distanceFromLocation:currentLocation];
                    
                    place.distance = [NSString stringWithFormat:@"%dm",(int)meters];
                    
                    if (meters > 1000000) {
                        place.distance = @"";
                    }else if (meters > 1000) {
                        place.distance = [NSString stringWithFormat:@"%.01fkm",meters/1000];
                    }
                }
                
                [placeArray addObject:place];
            }
            
            [HUD hide:YES];
            [self.tableView reloadData];
            [self.tableView setHidden:NO];
            
            lastDataCount = objects.count;
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
    if (_categoryName) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
        
        if (sideMenu.isMenuVisible) {
            [sideMenu hideMenuAnimated:YES];
        }else{
            [sideMenu showMenuAnimated:YES];
        }
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
    return placeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"MainCell";
    TSMainCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    TSPlace *cellPlace = placeArray[row];
    [cell.titleLabel setText:cellPlace.name];
    [cell.addressLabel setText:cellPlace.address];
    [cell.distanceLabel setText:cellPlace.distance];
    
    NSString *avatarUrl = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg|imageMogr2/thumbnail/460x/crop/!460x170a0a90",cellPlace.avatarUrl];
    
    avatarUrl = [avatarUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"bg_cell_main"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedId = indexPath.row;
    
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    if (sideMenu.isMenuVisible) {
        
        [sideMenu hideMenuAnimated:YES];
        
    }else{
        
        [self performSegueWithIdentifier:@"DetailController" sender:self];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        if (isSelectedFromMap) {
            MKAnnotationView *view = sender;
            TSPlaceMark *detailPlaceMark = (TSPlaceMark *)view.annotation;
            selectedId = detailPlaceMark.markId;
            isSelectedFromMap = NO;
        }
        
        TSPlace *selectedPlace = placeArray[selectedId];
        TSDetailController *detailController = segue.destinationViewController;
        detailController.place = selectedPlace;
    }
}

#pragma mark - Map

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!updatedUserLocation) {
        updatedUserLocation = YES;
        [self displayLocation:userLocation];
    }
    currentLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    if (sideMenu.isMenuVisible) {
        
        [sideMenu hideMenuAnimated:YES];
        
    }else{
        
        if (lastMapCenterLocation != nil) {
            if (mapView.region.center.latitude != lastMapCenterLocation.coordinate.latitude || mapView.region.center.longitude != lastMapCenterLocation.coordinate.longitude) {
                
                [HUD hide:YES];
                
                isRefreshFromMap = YES;
                
                [_activityIndicatiorView setHidden:NO];
                [_activityIndicatiorView startAnimating];
                
                PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:_mapView.region.center.latitude longitude:_mapView.region.center.longitude];
                
                PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
                query.limit = PAGE_COUNT;
                query.skip = PAGE_NUM*PAGE_COUNT;
                [query whereKey:@"location" nearGeoPoint:geoPoint];
                [self findObjects:query];
            }
        }
        
        lastMapCenterLocation = [[CLLocation alloc] initWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
    }
}

- (void)markPlace
{
    for (int i = 0; i < placeArray.count; i++) {
        
        TSPlace *mapPlace = [placeArray objectAtIndex:i];
        
        CLLocationCoordinate2D place;
        place.latitude =  [mapPlace.latitude doubleValue];
        place.longitude = [mapPlace.longitude doubleValue];
        
        TSPlaceMark *placeMark = [[TSPlaceMark alloc] initWithCoordinate:place];
        placeMark.title = mapPlace.name;
        placeMark.markId = i;
        
        if (![self hasAnnotation:placeMark]) {
            [_mapView addAnnotation:placeMark];
        }
    }
}

-(BOOL)hasAnnotation:(TSPlaceMark *)placeMark
{
    for (TSPlaceMark *placeAnnotation in _mapView.annotations) {
        if ([placeAnnotation.title isEqualToString:placeMark.title]) {
            return YES;
        }
    }
    
    return NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        {
        return nil;
        }
    
    if ([annotation isKindOfClass:[TSPlaceMark class]]) {
        static NSString *annotationIdentifier = @"annotationIdentifier";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (pinView == nil){
            
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = NO;
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

- (void)displayLocation:(MKUserLocation *)location
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
    if (placeArray.count > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:placeArray.count-lastDataCount-1 inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        
        [_footer endRefreshing];
    }
}

#pragma parse more data control method


-(void)clearData
{
    PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
    query.skip = pageId * 100;
    query.limit = 100;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            clearArray = objects;
            
            //[self findDuplicateData:clearArray[clearId]];
            
            [self addPhotoToParse:clearArray[clearId]];
            
            //[self addAvatarToParse:clearArray[clearId]];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)addAvatarToParse:(PFObject *)eachObject
{
    if (eachObject){
        
        PFRelation *relation = [eachObject relationForKey:@"photos"];
        PFQuery *productPhotoQuery = [relation query];
        productPhotoQuery.limit = 1;
        
        NSArray *objects = [productPhotoQuery findObjects];

        if (objects.count > 0) {
            
            eachObject[@"avatar"] = objects[0][@"url"];
            
            [eachObject save];
        }
    }
    
    [self goNextPhoto];
}

-(void)addPhotoToParse:(PFObject *)eachObject
{
    photoArray = [NSArray arrayWithArray:eachObject[@"g_photos"]];
    
    if (photoArray.count > 0){
        
        currentObject = eachObject;
        
        PFRelation *relation = [eachObject relationForKey:@"photos"];
        PFQuery *productPhotoQuery = [relation query];
        productPhotoQuery.limit = 1;
        [productPhotoQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            //if the "photos" has no photo relations, it should be the first time to add photo
            if (!error && number == 0) {
                
                [self getPhotoUrl:photoArray[0]];
                
            }else{
                
                [self goNextPhoto];
            }
        }];
        
    }else{
        
        s(@"g_photos is 0")
        [self goNextPhoto];
    }
}

-(void)getPhotoUrl:(NSDictionary *)photoDataDictionary
{
    NSString *photoReference = photoDataDictionary[@"photo_reference"];
    
    [self getRealImageUrl:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=1536&photoreference=%@&sensor=false&key=%@",photoReference,apiKeyArray[apiKeyId]]];
}

-(void)savePhotoUrl:(PFObject *)object withUrl:(NSString *)photoUrl
{
    PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
    photoObject[@"url"] = photoUrl;
    photoObject[@"other_category"]=@YES;
    [photoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFRelation *photoRelation = [object relationForKey:@"photos"];
        [photoRelation addObject:photoObject];
        
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            photoArrayId += 1;
            
            if (photoArray.count > photoArrayId) {
                
                [self getPhotoUrl:photoArray[photoArrayId]];
                
            }else{
                
                [self goNextPhoto];
            }
        }];
    }];
}

-(void)goNextPhoto
{
    photoArrayId = 0;
    
    clearId += 1;
    
    if(clearId != 100){
        NSLog(@"arrayId:%d",clearId+pageId*100);
        [self addPhotoToParse:clearArray[clearId]];
        //[self addAvatarToParse:clearArray[clearId]];
    }else{
        clearId = 0;
        pageId += 1;
        i(pageId)
        [self clearData];
    }
}

-(void)getRealImageUrl:(NSString *)url
{
    [photoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    s(request.URL.absoluteString)
    
    if ([request.URL.absoluteString rangeOfString:@"googleusercontent.com"].length > 0) {
        
        loadingPhotoUrl = request.URL.absoluteString;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (loadingPhotoUrl) {
        [self savePhotoUrl:currentObject withUrl:loadingPhotoUrl];
        loadingPhotoUrl = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    s(@"load error:")
    s(error)
    if (error.code == 403) {
        apiKeyId += 1;
        [self getPhotoUrl:photoArray[photoArrayId]];
    }
}

-(void)findDuplicateData:(PFObject *)eachObject
{
    PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
    [query whereKey:@"name" equalTo:eachObject[@"name"]];
    [query whereKey:@"address" equalTo:eachObject[@"address"]];
    [query whereKey:@"place_id" equalTo:eachObject[@"place_id"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count - 1; i++) {
                
                if ([objects[i] delete]) {
                    s(@"Delete Successful")
                }
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

//-(void)replaceLocationData:(PFObject *)eachObject
//{
//    PFGeoPoint *location = eachObject[@"location"];
//
//    if (!location) {
//
//        NSString *lat = eachObject[@"geometry"][@"location"][@"lat"];
//        NSString *lng = eachObject[@"geometry"][@"location"][@"lng"];
//
//        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
//
//        eachObject[@"location"] = geoPoint;
//
//        [eachObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//
//            clearId += 1;
//
//            if(clearId != 100){
//
//                NSLog(@"cIearArrayId:%d",clearId);
//
//                /* by folse
//                 Change this method name
//                 */
//
//                //[self copyPhotoData:clearArray[clearId]];
//                [self replaceLocationData:clearArray[clearId]];
//
//            }else{
//
//                clearId = 0;
//                pageId += 1;
//                i(pageId)
//                [self clearData];
//
//            }
//        }];
//
//    }else {
//
//        clearId += 1;
//
//        if(clearId != 100){
//            NSLog(@"cIearArrayId:%d",clearId);
//            //[self copyPhotoData:clearArray[clearId]];
//            [self addPhotoToParse:clearArray[clearId]];
//        }else{
//            clearId = 0;
//            pageId += 1;
//            i(pageId)
//            [self clearData];
//        }
//    }
//}

@end
