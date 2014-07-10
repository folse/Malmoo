//
//  CategoryTableController.m
//  Malmoo
//
//  Created by folse on 4/10/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "CategoryTableController.h"
#import "Shop.h"
#import "MainCell.h"
#import "DetailController.h"
#import "FSImageDownloader.h"

@interface CategoryTableController ()
{
    MBProgressHUD *HUD;
    NSMutableArray *shopArray;
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
    
    [self.navigationItem setTitle:_categoryName];
    
    HUD_SHOW
    
    [self getShopData:_categoryName];
}

-(void)getShopData:(NSString *)keyWords
{
    shopArray = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Shop"];
    if (keyWords) {
        [query whereKey:@"category" containsString:keyWords];
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
                shop.starterDishes = object[@"starters"];
                shop.mainDishes = object[@"maindishes"];
                shop.dessertDishes = object[@"desserts"];
                shop.latitude = [object[@"location"] componentsSeparatedByString:@","][0];
                shop.longitude = [object[@"location"] componentsSeparatedByString:@","][1];
                
                
                [shopArray addObject:shop];
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:shopArray.count-1 inSection:0];
                [self startImageDownload:shop.avatarUrl forIndexPath:index];
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
    
    NSString *imagePath = [[ProjectSettings alloc] getMD5FilePathWithUrl:cellShop.avatarUrl];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailController"]) {
        
        Shop *selectedShop = shopArray[selectedId];
        DetailController *detailController = segue.destinationViewController;
        detailController.shop = selectedShop;
        
    }
}

@end
