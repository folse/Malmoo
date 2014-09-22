//
//  TSPlace.h
//  Malmoo
//
//  Created by folse on 3/12/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

@interface TSPlace : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *openHours;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *news;
@property (nonatomic, strong) NSString *description;

@property (nonatomic) BOOL parking;
@property (nonatomic) BOOL alcohol;
@property (nonatomic) BOOL delivery;
@property (nonatomic) BOOL reservation;

@property (nonatomic, strong) PFObject *parseObject;

@property (nonatomic) BOOL favourited;

@end
