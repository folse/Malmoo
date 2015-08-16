//
//  TSMemberController.m
//  Malmoo
//
//  Created by Jennifer on 8/4/15.
//  Copyright (c) 2015 Folse. All rights reserved.
//

#import "TSMemberController.h"
#import "TSMembership.h"

@interface TSMemberController ()
{
    NSMutableArray *membershipArray;
}

@end

@implementation TSMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    membershipArray = [NSMutableArray new];
    
    [self getMembershipShop];
}

-(void)getMembershipShop
{
    HUD_SHOW
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:USER_NAME forKey:@"customer_username"];
    
    s(parameterDict)
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSSet *acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/html", nil];
    manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    [manager GET:MEMBERSHIP parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON){
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        HUD_DISMISS
        
        NSDictionary *data = (NSDictionary *)[JSON valueForKey:@"data"];
        
        if ([[JSON valueForKey:@"resp"] isEqualToString:@"0000"]){
            
            for (NSDictionary *item in data[@"memberships"]) {
                
                TSMembership *membership = [[TSMembership alloc] initWithData:item];
                [membershipArray addObject:membership];
            }
            
            [self.tableView reloadData];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Opps" message:[data valueForKey:@"msg"]];
            
            [alertView bk_addButtonWithTitle:@"好的" handler:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            //暂不提示
            //[alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HUD_DISMISS
        
        s(error)
        //FSError(error)
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
    return membershipArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    TSMembership *membership = membershipArray[row];

    NSString *membershipDetailString = [NSString stringWithFormat:NSLocalizedString(@"Prepaid %@, Points %@",@""),[NSNumber numberWithInteger:membership.vaildQuantity],[NSNumber numberWithInteger:membership.punchedQuantity]];
    
    [cell.textLabel setText:membership.shopName];
    [cell.detailTextLabel setText:membershipDetailString];
    cell.textLabel.font = [UIFont systemFontOfSize:24];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
