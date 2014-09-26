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

@interface TSSearchController ()<UISearchBarDelegate>
{
    NSMutableArray *resultArray;
    NSInteger selectedId;
    BOOL isSearching;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchAction {
    [_searchBar becomeFirstResponder];
}

-(void)getData:(NSString *)keyWords
{
    PFQuery *query = [PFQuery queryWithClassName:@"Shop"];
    if (keyWords) {
        [query whereKey:@"metatag" containsString:keyWords];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                [resultArray removeAllObjects];
                
                for (PFObject *object in objects) {
                    
                    TSPlace *place = [TSPlace new];
                    place.name = object[@"name"];
                    place.address = object[@"address"];
                    place.phone = [object[@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                    place.openHours = object[@"openHours"];
                    place.avatarUrl = object[@"avatar"];
                    place.latitude = [object[@"location"] componentsSeparatedByString:@","][0];
                    place.longitude = [object[@"location"] componentsSeparatedByString:@","][1];
                    place.description = object[@"description"];
                    place.news = object[@"news"];
                    place.parking = [object[@"has_parking"] boolValue];
                    place.alcohol = [object[@"has_alcohol"] boolValue];
                    place.delivery = [object[@"delivery"] boolValue];
                    place.reservation = [object[@"phone_reservation"] boolValue];
                    
                    [resultArray addObject:place];
                }
                
                if (resultArray.count > 0) {
                    [self.tableView reloadData];
                }
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
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
    [self getData:_searchBar.text];
    [_searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
}

@end
