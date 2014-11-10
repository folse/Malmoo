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

@interface TSFavoriteController ()
{
    NSMutableArray *placeArray;
    NSMutableArray *placeObjectArray;
    int pageId;
    int PAGE_COUNT;
    int PAGE_NUM;
    NSInteger lastDataCount;
    NSInteger selectedId;
    MJRefreshFooterView *_footer;
}

@end

@implementation TSFavoriteController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PAGE_COUNT = 15;
    
    placeArray = [NSMutableArray new];
    placeObjectArray = [NSMutableArray new];
    
    [self getData];
}

-(void)getData
{
    if (USER_LOGIN) {
        
        PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
        [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        
        for(PFObject *favorite in [favoriteQuery findObjects]){
            
            PFObject *place = favorite[@"place"];
            [self findPlace:place.objectId];
        }
        
        [self getTableViewData];
        
    }else{
        
        // need login
    }
}

-(void)findPlace:(NSString *)placeObjectId
{
    PFQuery *placeQuery = [PFQuery queryWithClassName:@"Place"];
    [placeQuery getObjectInBackgroundWithId:placeObjectId block:^(PFObject *object, NSError *error) {
        [placeObjectArray addObject:object];
    }];
}

-(void)getTableViewData
{
    for (PFObject *object in placeObjectArray) {
        //NSLog(@"%@", object);
        
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
        //place.tags = object[@"tag"];
        
        PFGeoPoint *location = object[@"location"];
        place.latitude = [NSString stringWithFormat:@"%f",location.latitude];
        place.longitude = [NSString stringWithFormat:@"%f",location.longitude];
        
        [placeArray addObject:place];
    }
    
    [HUD hide:YES];
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
    
    lastDataCount = placeObjectArray.count;
    if (PAGE_NUM > 0) {
        [self doneLoadMore];
    }
    
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        PAGE_NUM += 1;
        
        [self getData];
        
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

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        TSPlace *selectedPlace = placeArray[selectedId];
        TSDetailController *detailController = segue.destinationViewController;
        detailController.place = selectedPlace;
    }
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
