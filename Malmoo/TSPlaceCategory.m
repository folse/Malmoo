//
//  PlaceCategory.m
//  Malmoo
//
//  Created by folse on 4/10/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSPlaceCategory.h"

@implementation TSPlaceCategory

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //encode properties/values
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.objectId forKey:@"objectId"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init])) {
        //decode properties/values
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.objectId = [aDecoder decodeObjectForKey:@"objectId"];
    }
    return self;
}

@end
