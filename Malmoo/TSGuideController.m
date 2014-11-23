//
//  TSGuideController.m
//  Malmoo
//
//  Created by folse on 11/5/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSGuideController.h"

@interface TSGuideController ()

@property (weak, nonatomic) IBOutlet UIImageView *firstBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdBgImageView;

@end

@implementation TSGuideController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (USER_LOGIN) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(showBg1Animation) withObject:nil afterDelay:3];
}

-(void)showBg1Animation
{
    [UIView animateWithDuration:3 animations:^{
                
        [_firstBgImageView setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(showBg2Animation) withObject:nil afterDelay:3];
    }];
}

-(void)showBg2Animation
{
    [UIView animateWithDuration:3 animations:^{
        
        [_secondBgImageView setAlpha:0];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissPageAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [USER setBool:YES forKey:@"userSkipLogin"];
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
