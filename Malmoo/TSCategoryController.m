//
//  CategoryController.m
//  Malmoo
//
//  Created by folse on 3/21/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSCategoryController.h"
#import "TSPlaceCategory.h"
#import "TSMainController.h"

@interface TSCategoryController ()
{
    NSMutableArray *categoryArray;
    MBProgressHUD *HUD;
    NSInteger selectedId;
}

@end

@implementation TSCategoryController

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
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSData *categoryArrayData = [USER objectForKey:@"categoryArray"];
    categoryArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:categoryArrayData]];
    
    if (categoryArray != nil && categoryArray.count > 0) {
        
        [self.tableView reloadData];
        
    }else{
        
        HUD_SHOW
    }
    
    [self getPlaceCategory];
}

-(void)getPlaceCategory
{
    PFQuery *query = [PFQuery queryWithClassName:@"Category_Place"];
    [query whereKey:@"hidden" equalTo:@NO];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        HUD_DISMISS
        
        if (!error) {
            
            categoryArray = [NSMutableArray new];
            
            for (PFObject *object in objects) {
                
                NSLog(@"%@", object);
                
                TSPlaceCategory *category = [TSPlaceCategory new];
                category.name = object[@"name"];
                category.objectId = object.objectId;

                [categoryArray addObject:category];
            }
            
            if (self.tableView.indexPathsForVisibleRows.count == 0) {
                [HUD hide:YES];
                [self.tableView reloadData];
                [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            }
            
            NSData *categoryArrayData = [NSKeyedArchiver archivedDataWithRootObject:categoryArray];
            
            [USER setObject:categoryArrayData forKey:@"categoryArray"];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            e(@"categoryGetCategoryDataFailed")
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
    return categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    TSPlaceCategory *cellCategory = categoryArray[row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    [cell.textLabel setText:cellCategory.name];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedId = indexPath.row;
    
    if (categoryArray.count > 0) {
        [self performSegueWithIdentifier:@"MainController" sender:self];
        e(@"categorySelectedCategory")
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MainController"]) {
        
        TSPlaceCategory *selectedCategory = categoryArray[selectedId];
        
        TSMainController *mainController = segue.destinationViewController;
        [mainController setCategoryName:selectedCategory.name];
        [mainController setCategoryObjectId:selectedCategory.objectId];
    }
}

@end
