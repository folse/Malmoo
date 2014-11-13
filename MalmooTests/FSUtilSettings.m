//
//  FSUtilSettings.m
//
//  Created by folse on 11/19/13.
//  Copyright (c) 2013 folse. All rights reserved.
//

#import "FSUtilSettings.h"
#import "CommonCrypto/CommonDigest.h"

@interface FSUtilSettings ()

@end

@implementation FSUtilSettings

+(NSString *)MD5:(NSString *)text
{
    if (text) {
        const char *cStr = [text UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (unsigned)strlen(cStr), result);
        
        return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1], result[2], result[3],
                 result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15]
                 ] lowercaseString];
    }else{
       return @"";
    }
}

+(NSString *)getMD5FilePathWithUrl:(NSString *)url
{
    NSString *urlMD5 = [self MD5:url];
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documents[0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",urlMD5]];
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
