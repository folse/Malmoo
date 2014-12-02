//
//  TSMutiLanguageMenuController.m
//  Malmoo
//
//  Created by Jennifer on 11/12/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSMutiLanguageMenuController.h"
#import "TSMenuCell.h"
#import "TSMenu.h"

@interface TSMutiLanguageMenuController ()
{
    NSMutableArray *menuCategoryArray;
    NSMutableDictionary *menuDictionary;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *languageSegmentedControl;

@end

@implementation TSMutiLanguageMenuController

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
    
    menuCategoryArray = [NSMutableArray new];
    
    menuDictionary = [NSMutableDictionary new];
    
    [self getMenuData];
}

-(void)getMenuData
{
    PFQuery *menuQuery = [PFQuery queryWithClassName:@"Menu"];
    [menuQuery whereKey:@"place" equalTo:[PFObject objectWithoutDataWithClassName:@"Place" objectId:@"IdWVThJCuX"]];
    [menuQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            //{"abc":["a","b","c"],"xyz":["x":"y","z"]}
            
            for (PFObject *object in objects) {
                
                s(object)
                NSMutableArray *menuArray;
                PFObject *menuPhoto = object[@"photo"];
                PFObject *category = object[@"category"];
                
                TSMenu *menu = [TSMenu new];
                menu.englishName = object[@"English_name"];
                menu.chineseName = object[@"Chinese_name"];
                menu.swedishName = object[@"Swedish_name"];
                menu.englishDescription = object[@"English_description"];
                menu.chineseDescription = object[@"Chinese_description"];
                menu.swedishDescription = object[@"Swedish_description"];
                menu.price = [self convertPrice:object[@"price"]];
                menu.avatarUrl = [PFQuery getObjectOfClass:@"Photo" objectId:menuPhoto.objectId][@"url"];
                
                if ([[menuDictionary allKeys] containsObject:category.objectId]) {
                    
                    menuArray = [menuDictionary objectForKey:category.objectId];
                    
                }else{
                    
                    menuArray = [NSMutableArray new];
                }
                
                [menuArray addObject:menu];
                
                [menuDictionary setObject:menuArray forKey:category.objectId];
            }
            
            [self getMenuCategory];
        }
    }];
}

-(void)getMenuCategory
{
    for (NSString *objectId in [menuDictionary allKeys]) {
        
        PFObject *menuCategory = [PFQuery getObjectOfClass:@"Category_Menu" objectId:objectId];
        
        [menuCategoryArray addObject:menuCategory];
    }
    
    [self.tableView reloadData];
}

-(NSString *)convertPrice:(NSNumber *)priceNumber
{
    NSString *price = @"";
    float fixPrice = [priceNumber floatValue] - [priceNumber intValue];
    if (fixPrice > 0) {
        price = [NSString stringWithFormat:@"%.2fkr",priceNumber.floatValue];
    }else{
        price = [NSString stringWithFormat:@"%dkr",priceNumber.intValue];
    }
    
    return price;
}

- (IBAction)segmentValueChanged:(id)sender
{
//    if (_languageSegmentedControl.selectedSegmentIndex == 0) {
//        
//        
//    }else if (_languageSegmentedControl.selectedSegmentIndex == 1){
//        
//        
//    }
    
    [self.tableView reloadData];
}

- (IBAction)dismissPageAction:(id)sender
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return menuDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSString *key = [menuDictionary allKeys][section];
    
    NSArray *menuArray = [menuDictionary objectForKey:key];
    
    return menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    NSString *key = [menuDictionary allKeys][indexPath.section];
    
    NSArray *menuArray = [menuDictionary objectForKey:key];
    
    PFObject *menu = menuArray[row];
    
    TSMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    
    if (!cell) {
        cell = [[TSMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    switch (_languageSegmentedControl.selectedSegmentIndex) {
            
        case 0:
                        
            [cell.nameLabel setText:menu[@"English_name"]];
            [cell.descriptionLabel setText:menu[@"English_description"]];
            
            break;
            
        case 1:
            
            [cell.nameLabel setText:menu[@"Chinese_name"]];
            [cell.descriptionLabel setText:menu[@"Chinese_description"]];
            
            break;
            
        case 2:
            
            [cell.nameLabel setText:menu[@"Swedish_name"]];
            [cell.descriptionLabel setText:menu[@"Swedish_description"]];
            
            break;
            
            
        default:
            break;
    }
    
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:menu[@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (_languageSegmentedControl.selectedSegmentIndex) {
            
        case 0:
            
            return menuCategoryArray[section][@"English_name"];
            
            break;
            
        case 1:
            
            return menuCategoryArray[section][@"Chinese_name"];
            
            break;
            
        case 2:
            
            return menuCategoryArray[section][@"Swedish_name"];
            
            break;
            
            
        default:
            break;
    }
    
    return @" ";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
