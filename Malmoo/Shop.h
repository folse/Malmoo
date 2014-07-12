//
//  Shop.h
//  Malmoo
//
//  Created by folse on 3/12/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MObject.h"

@interface Shop : MObject

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *openHours;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *starterDishes;
@property (nonatomic, strong) NSString *mainDishes;
@property (nonatomic, strong) NSString *dessertDishes;

@property (nonatomic) BOOL favourited;

@end
