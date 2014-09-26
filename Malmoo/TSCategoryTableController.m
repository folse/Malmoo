//
//  CategoryTableController.m
//  Malmoo
//
//  Created by folse on 4/10/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSCategoryTableController.h"
#import "TSMainCell.h"
#import "TSDetailController.h"

@interface CategoryTableController ()
{
    MBProgressHUD *HUD;
    NSMutableArray *placeArray;
    NSInteger selectedId;
}

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation CategoryTableController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:_categoryName];
    
    HUD_SHOW
    
    [self getData:_categoryName];
}

-(void)getData:(NSString *)keyWords
{
    placeArray = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    if (keyWords) {
        [query whereKey:@"category" containsString:keyWords];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
                
                TSPlace *place = [TSPlace new];
                place.name = object[@"name"];
                place.address = object[@"address"];
                place.phone = [object[@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                place.openHours = object[@"openHours"];
                place.tags = object[@"metatag"];
                place.avatarUrl = object[@"avatar"];
                place.description = object[@"description"];
                place.news = object[@"news"];
                place.parking = [object[@"has_parking"] boolValue];
                place.alcohol = [object[@"has_alcohol"] boolValue];
                place.delivery = [object[@"delivery"] boolValue];
                place.reservation = [object[@"phone_reservation"] boolValue];
                place.latitude = [object[@"location"] componentsSeparatedByString:@","][0];
                place.longitude = [object[@"location"] componentsSeparatedByString:@","][1];
                                
                [placeArray addObject:place];
                
            }
            
            [HUD hide:YES];
            [self.tableView reloadData];
            [self.tableView setHidden:NO];
            
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
    
    if (cell == nil) {
        
        cell = [[TSMainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TSPlace *cellPlace = placeArray[row];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        TSPlace *selectedPlace = placeArray[selectedId];
        TSDetailController *detailController = segue.destinationViewController;
        detailController.place = selectedPlace;
        
    }
}

@end
