//
//  ZbarScannerController.h
//  MMG
//
//  Created by tian.liang on 14-7-19.
//  Copyright (c) 2014年 sparrow_liang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZbarScannerController : UIViewController

+(ZbarScannerController *)scanSuccess:(void (^)(NSString *data))success;

@end