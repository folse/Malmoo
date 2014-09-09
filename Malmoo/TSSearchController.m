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
#import "FSImageDownloader.h"

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
                    place.parking = object[@"has_parking"];
                    place.alcohol = object[@"has_alcohol"];
                    place.reservation = object[@"phone_reservation"];
                    
                    [resultArray addObject:place];
                    
                    NSIndexPath *index = [NSIndexPath indexPathForRow:resultArray.count-1 inSection:0];
                    [self startImageDownload:place.avatarUrl forIndexPath:index];
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
    
    NSString *imagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:cellPlace.avatarUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]){
        
        cell.avatarImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        
    }else{
        
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startImageDownload:cellPlace.avatarUrl forIndexPath:indexPath];
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

#pragma mark - Table cell image support

-(void)startImageDownload:(NSString *)url forIndexPath:(NSIndexPath *)indexPath
{
    FSImageDownloader *imageDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader == nil)
    {
        imageDownloader = [[FSImageDownloader alloc] init];
        [imageDownloader setCompletionHandler:^(UIImage *image) {
            
            TSMainCell *cell = (TSMainCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.avatarImageView.image = image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        [self.imageDownloadsInProgress setObject:imageDownloader forKey:indexPath];
        [imageDownloader downloadImageFrom:url];
    }
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
