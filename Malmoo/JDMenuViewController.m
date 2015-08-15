//
//  JDMenuViewController.m
//  JDSideMenu
//
//  Created by Markus Emrich on 11.11.13.
//  Copyright (c) 2013 Markus Emrich. All rights reserved.
//

#import "UIViewController+JDSideMenu.h"
#import "JDMenuViewController.h"
#import "UMFeedback.h"

@interface JDMenuViewController ()
{
    UIImageView *guideImageView;
    UIImage *qrcodeImage;
    UIView *guideBgView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

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
    self.sideMenuController.tapGestureEnabled = YES;
    self.sideMenuController.panGestureEnabled = YES;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    NSString *qrcodeUrl = [NSString stringWithFormat:@"http://qr.liantu.com/api.php?&bg=2a5392&fg=8cacdb&w=280&m=10&text=%@",userName];
    
    [_qrCodeImageView sd_setImageWithURL:[NSURL URLWithString:qrcodeUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        qrcodeImage = image;
        
    }];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQRcode)];
    [_qrCodeImageView setUserInteractionEnabled:YES];
    [_qrCodeImageView addGestureRecognizer:imageTap];
}

- (void)showQRcode
{
    if (qrcodeImage) {
        guideBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [guideBgView setBackgroundColor:[UIColor colorWithRed:42/255.0 green:83/255.0 blue:146/255.0 alpha:0.95]];
        [guideBgView setAlpha:0];
        
        guideImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
        [guideImageView setFrame:CGRectMake(50, 170, 140, 140)];
        [guideBgView addSubview:guideImageView];
        [self.view addSubview:guideBgView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGuideImageView)];
        [guideImageView setUserInteractionEnabled:YES];
        [guideImageView addGestureRecognizer:imageTap];
        [guideBgView addGestureRecognizer:imageTap];
        
        [UIView animateWithDuration:1 animations:^{
            [guideBgView setAlpha:1];

            [guideImageView setAlpha:1];
            
        } completion:nil];

    }
}

-(void)hideGuideImageView
{
    [UIView animateWithDuration:0.6 animations:^{
        
        [guideBgView setAlpha:0];
        [guideImageView setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        [guideBgView removeFromSuperview];
        [guideImageView removeFromSuperview];
    }];
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
        
        if ([data isEqualToString:@"test"]) {
            
            UINavigationController *navController = [MUTILANGUAGE_STORYBOARD instantiateViewControllerWithIdentifier:@"mutiLanguageMenuNav"];
            [self.sideMenuController setContentController:navController animated:YES];
            
        }else{

            NSURL* url = [[NSURL alloc] initWithString:data];
            [[ UIApplication sharedApplication]openURL:url];
        }
    }];
    
    [self presentViewController:scannerController animated:YES completion:nil];
}

- (IBAction)favoriteButtonAction:(id)sender
{
     UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"favoritesNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

- (IBAction)feedbackButtonAction:(id)sender
{
    UINavigationController *navController = [ACCOUNT_STORYBOARD instantiateViewControllerWithIdentifier:@"feedbackNav"];
    [self.sideMenuController setContentController:navController animated:YES];
}

@end
