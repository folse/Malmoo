//
//  MObject.h
//  Malmoo
//
//  Created by folse on 4/11/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PFObject *parseObject;

@end
