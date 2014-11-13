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
    
    [self showBgAnimation];

}

-(void)showBgAnimation
{
    [UIView animateWithDuration:4.5 animations:^{
        
        [_firstBgImageView setFrame:CGRectMake(-_firstBgImageView.image.size.width+210, 10, _firstBgImageView.frame.size.width, _firstBgImageView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            
            [_firstBgImageView setAlpha:0];
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:4.5 animations:^{
                
                [_secondBgImageView setFrame:CGRectMake(102, -60, _firstBgImageView.frame.size.width, _firstBgImageView.frame.size.height)];
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:1.0 animations:^{
                    
                    [_secondBgImageView setAlpha:0];
                    
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:4.5 animations:^{
                        
                        [_thirdBgImageView setFrame:CGRectMake(20, 0, _firstBgImageView.frame.size.width, _firstBgImageView.frame.size.height)];
                        
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:1.0 animations:^{
                            
                            [_firstBgImageView setAlpha:1];
                            
                        } completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:3.8 animations:^{
                                
                                [_firstBgImageView setFrame:CGRectMake(-38, -30, _firstBgImageView.frame.size.width, _firstBgImageView.frame.size.height)];
                                
                            } completion:nil];
                            
                        }];
                    }];
                }];
            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissPageAction:(id)sender
{
    
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
