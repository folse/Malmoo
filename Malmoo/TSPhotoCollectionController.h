//
//  PhotoCollectionController.h
//  Malmoo
//
//  Created by Jennifer on 8/11/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSPhotoCollectionController : UICollectionViewController

@property (nonatomic,strong) TSPlace *place;

@property (nonatomic,strong) NSString *defaultPhotoType;

@end
