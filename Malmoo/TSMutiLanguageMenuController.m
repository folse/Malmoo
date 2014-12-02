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
    
    HUD_SHOW
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
                menu.englishName = object[@"english_name"];
                menu.chineseName = object[@"chinese_name"];
                menu.swedishName = object[@"swedish_name"];
                menu.englishDescription = object[@"english_description"];
                menu.chineseDescription = object[@"chinese_description"];
                menu.swedishDescription = object[@"swedish_description"];
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
        s(menuCategoryArray)
        [menuCategoryArray addObject:menuCategory];
    }
    NSArray *keyArray = [menuDictionary allKeys];
    
    keyArray = [NSMutableArray arrayWithArray:[keyArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        int rank1;
        int rank2;
        
        if ([obj1 isEqualToString:@"enLnt3oX27"]) {
            rank1 = 1;
        }else if ([obj1 isEqualToString:@"uEYQlF9B4u"]) {
            rank1 = 2;
        }else if ([obj1 isEqualToString:@"scjnGzPDr6"]) {
            rank1 = 3;
        }else if ([obj1 isEqualToString:@"M6jl9n2aVB"]) {
            rank1 = 4;
        }
        
        if ([obj2 isEqualToString:@"enLnt3oX27"]) {
            rank2 = 1;
        }else if ([obj2 isEqualToString:@"uEYQlF9B4u"]) {
            rank2 = 2;
        }else if ([obj2 isEqualToString:@"scjnGzPDr6"]) {
            rank2 = 3;
        }else if ([obj2 isEqualToString:@"M6jl9n2aVB"]) {
            rank2 = 4;
        }
        
        if (rank1 > rank2) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (rank1 < rank2) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    NSMutableArray *newMenuCategoryArray = [NSMutableArray new];
    
    for(NSString *key in keyArray){
        
        for (PFObject *menuObject in menuCategoryArray) {

            if ([key isEqualToString:menuObject.objectId]) {
                [newMenuCategoryArray addObject:menuObject];
            }
        }
    }
    
    menuCategoryArray = newMenuCategoryArray;

    [self.tableView reloadData];
    
    HUD_DISMISS
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
    
    PFObject *menuObject = menuCategoryArray[section];
    NSArray *menuArray = [menuDictionary objectForKey:menuObject.objectId];
    
    return menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    PFObject *menuObject = menuCategoryArray[indexPath.section];
    NSArray *menuArray = [menuDictionary objectForKey:menuObject.objectId];

    TSMenu *menu = menuArray[row];
    
    TSMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    
    if (!cell) {
        cell = [[TSMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    [cell.priceLabel setText:menu.price];
    
    switch (_languageSegmentedControl.selectedSegmentIndex) {
            
        case 0:
                        
            [cell.nameLabel setText:menu.englishName];
            [cell.descriptionLabel setText:menu.englishDescription];
            
            break;
            
        case 1:
            
            [cell.nameLabel setText:menu.chineseName];
            [cell.descriptionLabel setText:menu.chineseDescription];
            
            break;
            
        case 2:
            
            [cell.nameLabel setText:menu.swedishName];
            [cell.descriptionLabel setText:menu.swedishDescription];
            
            break;
            
            
        default:
            break;
    }
    
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:menu.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (_languageSegmentedControl.selectedSegmentIndex) {
            
        case 0:
            
            return menuCategoryArray[section][@"english_name"];
            
            break;
            
        case 1:
            
            return menuCategoryArray[section][@"chinese_name"];
            
            break;
            
        case 2:
            
            return menuCategoryArray[section][@"swedish_name"];
            
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
