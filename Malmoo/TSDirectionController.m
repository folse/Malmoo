//
//  DirectionController.m
//  Malmoo
//
//  Created by Jennifer on 4/6/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSDirectionController.h"

@interface TSDirectionController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TSDirectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    s(_currentLat)
    
    HUD_SHOW
    
    [_webView setDelegate:self];
    
    NSString *mapUrl = [NSString stringWithFormat:@"https://maps.google.com/maps?saddr=%@,%@&daddr=%@,%@&mode=driving",_currentLat,_currentLng,_destinationLat,_destinationLng];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:mapUrl]];
    
    [_webView loadRequest:request];
    
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3];
}

-(void)dismissHUD
{
    HUD_DISMISS
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    HUD_DISMISS
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
