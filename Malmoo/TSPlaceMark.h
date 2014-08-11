//
//  TSPlaceMark.h
//  ThinkCare
//
//  Created by Jennifer on 4/16/13.
//  Copyright (c) 2013 Folse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TSPlaceMark : NSObject <MKAnnotation>{

    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
       
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) int markId;

-(id) initWithCoordinate: (CLLocationCoordinate2D) the_coordinate;

@end
