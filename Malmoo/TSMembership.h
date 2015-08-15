//
//  TSMembership.h
//  Malmoo
//
//  Created by Jennifer on 8/5/15.
//  Copyright (c) 2015 Folse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSMembership : NSObject

@property (nonatomic,strong) NSString *shopName;

@property (nonatomic) NSInteger vaildQuantity;

@property (nonatomic) NSInteger punchedQuantity;

-(id)initWithData:(NSDictionary *)data;

@end
