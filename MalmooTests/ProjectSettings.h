//
//  F.h
//  ThinkCare
//
//  Created by Folse on 5/11/13.
//  Copyright (c) 2013 Folse. All rights reserved.
//
#import "MBProgressHUD.h"
#import <AFNetworking.h>
#import "JDSideMenu.h"
#import "MobClick.h"

#define s(content) NSLog(@"%@", content);
#define i(content) NSLog(@"%d", content);
#define f(content) NSLog(@"%f", content);

#define USER [NSUserDefaults standardUserDefaults]
#define USER_ID [USER valueForKey:@"userId"]
#define USER_NAME [USER valueForKey:@"userName"]
#define USER_LOGIN [USER boolForKey:@"userLogined"]
#define APP_COLOR [UIColor colorWithRed:54.0/255.0 green:159.0/255.0 blue:220.0/255.0 alpha:1.0]

#define FIRST_LOAD [USER boolForKey:@"isFirstLoad"]
#define PAGE_ID [USER valueForKey:@"pageId"]

#define STORY_BOARD [UIStoryboard storyboardWithName:@"Main" bundle:nil]

#define e(content) [MobClick event:content];

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define HUD_SHOW \
HUD = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];\
HUD.center = self.view.center;\
HUD.square = YES;\
HUD.margin = 15;\
HUD.minShowTime = 1;\
HUD.mode = MBProgressHUDModeCustomView;\
HUD.customView = [[YSpinKitView alloc] initWithStyle:YSpinKitViewStyleBounce color:[UIColor colorWithRed:88.0/255.0 green:194.0/255.0 blue:255.0/255.0 alpha:1.0]];\
[[UIApplication sharedApplication].keyWindow addSubview:HUD];\
[HUD show:YES];\

#define TEST FALSE

#if TEST
#define API_BASE_URL @"http://0.meilidaren.duapp.com"
#else
#define API_BASE_URL @"http://mldrapi.duapp.com"
#endif

#define UMENG_APP_KEY @"536ef5ee56240b0a790f4074"

//#define API_BASE_URL [NSString stringWithFormat:@"http://%@",[USER valueForKey:@"test"]]

@interface ProjectSettings : NSObject

-(NSString *)MD5:(NSString *)text;

-(NSString *)getMD5FilePathWithUrl:(NSString *)url;

@end
