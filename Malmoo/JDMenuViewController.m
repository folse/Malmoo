//
//  JDMenuViewController.m
//  JDSideMenu
//
//  Created by Markus Emrich on 11.11.13.
//  Copyright (c) 2013 Markus Emrich. All rights reserved.
//

#import "UIViewController+JDSideMenu.h"

#import "JDMenuViewController.h"

@interface JDMenuViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation JDMenuViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGRectInset(self.scrollView.bounds, 0, -1).size;
    self.sideMenuController.panGestureEnabled = NO;
}

- (IBAction)HomeBtnAction:(id)sender
{
    UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"mainNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)favouriteBtnAction:(id)sender
{
    UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"categoryNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)moreBtnAction:(id)sender
{
    UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"moreNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)rewardBtnAction:(id)sender
{
    UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"rewardNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)scanBtnAction:(id)sender
{
    ZbarScannerController *scannerController = [ZbarScannerController scanSuccess:^(NSString *data) {
        
        s(data)
        
        UINavigationController *navController = [MUTILANGUAGE_STORYBOARD instantiateViewControllerWithIdentifier:@"mutiLanguageMenuNav"];
        [self.sideMenuController setContentController:navController animated:YES];
    }];
    [self presentViewController:scannerController animated:YES completion:nil];
}


@end
