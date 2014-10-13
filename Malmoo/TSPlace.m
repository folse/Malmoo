//
//  TSPlace.m
//  Malmoo
//
//  Created by folse on 3/12/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSPlace.h"

@implementation TSPlace

-(void)setAvatarUrl:(NSString *)avatarUrl
{
    _avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"http://ts-image1.qiniudn.com" withString:@"http://ts-image1.qiniug.com"];
}

@end
