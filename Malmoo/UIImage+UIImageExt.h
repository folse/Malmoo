//
//  UIImage+UIImageExt.h
//  weidian
//
//  Created by YoungShook on 14-1-22.
//  Copyright (c) 2014年 folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageExt)

- (UIImage *)imageByWidth:(CGFloat)width;

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
