//
//  TSMembership.m
//  Malmoo
//
//  Created by Jennifer on 8/5/15.
//  Copyright (c) 2015 Folse. All rights reserved.
//

#import "TSMembership.h"

@implementation TSMembership

-(id)initWithData:(NSDictionary *)data
{
    if (self = [super init]) {
        
        self.shopName = data[@"shop_name"];
        self.vaildQuantity = [data[@"vaild_quantity"] integerValue];
        self.punchedQuantity = [data[@"punched_quantity"] integerValue];
    }
    
    return self;
}

@end
