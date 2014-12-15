//
//  TSFavoriteController.m
//  Malmoo
//
//  Created by folse on 11/10/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSFavoriteController.h"
#import "MJRefresh.h"
#import "TSMainCell.h"
#import "TSDetailController.h"
#import "TSGuideController.h"

@interface TSFavoriteController ()
{
    NSMutableArray *placeArray;
    NSMutableArray *placeObjectArray;
    int pageId;
    int PAGE_COUNT;
    int PAGE_NUM;
    int skipCount;
    NSInteger lastDataCount;
    NSInteger selectedId;
    MJRefreshFooterView *_footer;
    PFGeoPoint *currentGeoPoint;
    PFQuery *favoriteQuery;
}

@end

@implementation TSFavoriteController

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
    
    HUD_DISMISS
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (USER_LOGIN) {
        
        favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
        
        NSInteger rows = [self.tableView numberOfRowsInSection:0];
        
        if(rows == 0){
            
            HUD_SHOW
            
            PAGE_NUM = 0;
            PAGE_COUNT = 15;
            
            placeArray = [NSMutableArray new];
            placeObjectArray = [NSMutableArray new];
            
            favoriteQuery.limit = PAGE_COUNT;
            favoriteQuery.skip = PAGE_NUM*PAGE_COUNT;
            
        }else{
            
            [placeArray removeAllObjects];
            favoriteQuery.limit = rows;
        }
        
        [self getDataFromServer];
    }
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (USER_LOGIN) {
        
        [self removeNavigationBarShadow];
        
        [self addFooter];
        
    }else{
        
        TSGuideController *guideController = [ACCOUNT_STORYBOARD instantiateViewControllerWithIdentifier:@"GuideController"];
        [self presentViewController:guideController animated:YES completion:^{
            
        }];
    }
}

-(void)getDataFromServer
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            
            [placeObjectArray removeAllObjects];
            
            currentGeoPoint = geoPoint;
            
            [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
            
            [favoriteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for(PFObject *favorite in objects){
                    
                    PFObject *place = favorite[@"place"];
                    [self findPlace:place.objectId];
                }
                
                if(placeObjectArray.count > 0){
                    
                    [self getTableViewData];
                }
                
                HUD_DISMISS
                [self.tableView reloadData];
                [self.tableView setHidden:NO];
                
                if (PAGE_NUM > 0) {
                    lastDataCount = placeObjectArray.count;
                    [self doneLoadMore];
                }
            }];
            
            e(@"getFavoriteSuccess")
            
        }else{
            
            HUD_DISMISS
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please check your location settings",nil) message:NSLocalizedString(@"Maybe network issues",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alertView show];
            
            e(@"getFavoriteFailed")
        }
    }];
}

-(void)findPlace:(NSString *)placeObjectId
{
    PFQuery *placeQuery = [PFQuery queryWithClassName:@"Place"];
    [placeObjectArray addObject:[placeQuery getObjectWithId:placeObjectId]];
}

-(void)getTableViewData
{
    for (PFObject *object in placeObjectArray) {
        
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
        place.favourited = YES;
        //place.tags = object[@"tag"];
        
        PFGeoPoint *location = object[@"location"];
        place.latitude = [NSString stringWithFormat:@"%f",location.latitude];
        place.longitude = [NSString stringWithFormat:@"%f",location.longitude];
        
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:currentGeoPoint.latitude longitude:currentGeoPoint.longitude];
        
        CLLocationDistance meters = [placeLocation distanceFromLocation:currentLocation];
        
        place.distance = [NSString stringWithFormat:@"%dm",(int)meters];
        
        if (meters > 1000000) {
            place.distance = @"";
        }else if (meters > 1000) {
            place.distance = [NSString stringWithFormat:@"%.01fkm",meters/1000];
        }
        
        [placeArray addObject:place];
    }
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        PAGE_NUM += 1;
        
        favoriteQuery.limit = PAGE_COUNT;
        favoriteQuery.skip = PAGE_NUM*PAGE_COUNT;
        
        [self getDataFromServer];
        
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
    return placeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"FavoriteCell";
    TSMainCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    TSPlace *cellPlace = placeArray[row];
    [cell.titleLabel setText:cellPlace.name];
    [cell.addressLabel setText:cellPlace.address];
    
    NSString *avatarUrl = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg|imageMogr2/thumbnail/330x/crop/!330x120a0a80",cellPlace.avatarUrl];
    
    avatarUrl = [avatarUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[[UIImage imageNamed:@"img_empty"] unsharpen]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedId = indexPath.row;
    
    [self performSegueWithIdentifier:@"DetailController" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        TSPlace *selectedPlace = placeArray[selectedId];
        TSDetailController *detailController = segue.destinationViewController;
        detailController.place = selectedPlace;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
