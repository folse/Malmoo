//
//  SearchController.m
//  Malmoo
//
//  Created by Jennifer on 4/6/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSSearchController.h"
#import "TSMainCell.h"
#import "TSDetailController.h"
#import "MJRefresh.h"

@interface TSSearchController ()<UISearchBarDelegate>
{
    NSMutableArray *resultArray;
    NSInteger selectedId;
    BOOL isSearching;
    int PAGE_COUNT;
    int PAGE_NUM;
    int lastDataCount;
    PFQuery *tagQuery;
    PFQuery *nameQuery;
    MJRefreshFooterView *_footer;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation TSSearchController

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
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(searchAction) withObject:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    resultArray = [NSMutableArray new];
    
    PAGE_COUNT = 15;
    
    [self addFooter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchAction {
    [_searchBar becomeFirstResponder];
}

-(void)getSearchPlaceData:(NSString *)keywords
{
    NSMutableArray *tagArray = [NSMutableArray new];
    
    NSArray *keywordsArray = [keywords componentsSeparatedByString:@" "];
    
    for (NSString *keyword in keywordsArray) {
        PFQuery *tagObjectQuery = [PFQuery queryWithClassName:@"Tag"];
        [tagObjectQuery whereKey:@"name" equalTo:keyword];
        PFObject *tagObject = [tagObjectQuery getFirstObject];
        [tagArray addObject:tagObject];
    }
    
    //    nameQuery = [PFQuery queryWithClassName:@"Place"];
    //    [nameQuery whereKey:@"name" containedIn:keywordsArray];
    
    tagQuery = [PFQuery queryWithClassName:@"Place"];
    [tagQuery whereKey:@"tag" containedIn:tagArray];

    [self searchQuery];
}

-(void)searchQuery
{
    PFQuery *placeQuery = [PFQuery orQueryWithSubqueries:@[tagQuery]];
    
    placeQuery.limit = PAGE_COUNT;
    placeQuery.skip = PAGE_NUM*PAGE_COUNT;
    [resultArray removeAllObjects];
    [self findObjects:placeQuery];
}

-(void)findObjects:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
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
                
                [resultArray addObject:place];
            }
            
            [HUD hide:YES];
            [self.tableView reloadData];
            [self.tableView setHidden:NO];
            
            lastDataCount = objects.count;
            if (PAGE_NUM > 0) {
                [self doneLoadMore];
            }
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
    return resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"SearchCell";
    TSMainCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[TSMainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TSPlace *cellPlace = resultArray[row];
    [cell.titleLabel setText:cellPlace.name];
    [cell.addressLabel setText:cellPlace.address];
    
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:cellPlace.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
    
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
        
        TSPlace *selectedPlace = resultArray[selectedId];
        TSDetailController *detailController = segue.destinationViewController;
        detailController.place = selectedPlace;
        
    }
}

#pragma mark - UISearchDisplayController delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    HUD_Define
    [HUD show:YES];
    [self getSearchPlaceData:_searchBar.text];
    [_searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        PAGE_NUM += 1;
        
        [self searchQuery];
        
    };
    _footer = footer;
}

-(void)doneLoadMore
{
    if (resultArray.count > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:resultArray.count-lastDataCount-1 inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        
        [_footer endRefreshing];
    }
}

@end
