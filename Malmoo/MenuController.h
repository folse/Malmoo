//
//  MenuController.h
//  Malmoo
//
//  Created by folse on 4/8/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shop.h"

@interface MenuController : UITableViewController

@property (nonatomic, strong) Shop *shop;

@property (nonatomic) NSString *menuType;

@end
