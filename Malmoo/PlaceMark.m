//
//  PlaceMark.m
//  ThinkCare
//
//  Created by Jennifer on 4/16/13.
//  Copyright (c) 2013 Folse. All rights reserved.
//

#import "PlaceMark.h"

@implementation PlaceMark

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id) initWithCoordinate: (CLLocationCoordinate2D) the_coordinate
{
	if (self = [super init])
	{
		coordinate = the_coordinate;
	}
	return self;
}

@end
