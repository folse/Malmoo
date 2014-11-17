//
//  ZbarScannerController.m
//  MMG
//
//  Created by tian.liang on 14-7-19.
//  Copyright (c) 2014年 sparrow_liang. All rights reserved.
//

#import "ZbarScannerController.h"
#import "ZBarReaderView.h"

NSString* const ZbarScannerControllerImageMessage = @"ZbarScannerControllerImageMessage";

@interface ZbarCameraOverlayView : UIImageView

@property (nonatomic,strong)UIImageView* scanLine;

@end

@implementation ZbarCameraOverlayView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        //        self.scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        //        self.scanLine.image = [UIImage imageNamed:@"bg_scan"];
        //        [self addSubview:self.scanLine];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, SCREEN_WIDTH, SCREEN_HEIGHT)];
        bgView.image = [UIImage imageNamed:@"bg_scan"];
        [self addSubview:bgView];
        
    }
    return self;
}

-(void)setNeedsDisplay{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatCount:9999];
    [UIView setAnimationDuration:3.0f];
    self.scanLine.transform = CGAffineTransformMakeTranslation(0, 220);
    [UIView commitAnimations];
}

@end


@interface ZbarScannerController ()<ZBarReaderViewDelegate>
@property (nonatomic, retain, readonly) ZBarReaderView *readView;
@property (nonatomic, retain, readonly) ZBarImageScanner *imageScanner;
@property (nonatomic, retain) UIView *cameraOverlayView;
@property (nonatomic,copy)void (^success)(NSString *);
@end

@implementation ZbarScannerController{
    UIView *_loadingBackgroundView;
    UIActivityIndicatorView *_loadingView;
}


+(ZbarScannerController*)scanSuccess:(void (^)(NSString *))success{
    ZbarScannerController *controller = [[ZbarScannerController alloc]init];
    controller.success = success;
    return controller;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_readView start];
    [_cameraOverlayView setNeedsDisplay];
    [self performSelector:@selector(removeLoadingView) withObject:nil afterDelay:0.3];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    float barHeight = 64;
    
    [self.navigationController.navigationBar setHidden:YES];
    
    CGSize size = self.view.frame.size;
    
    _imageScanner = [[ZBarImageScanner alloc] init];
    [_imageScanner setSymbology:ZBAR_PARTIAL config:ZBAR_CFG_ENABLE to:0];
    _imageScanner.enableCache = YES;
    
    _readView = [[ZBarReaderView alloc] initWithImageScanner:_imageScanner];
    _readView.tracksSymbols = NO;
    _readView.readerDelegate = self;
    _readView.frame = CGRectMake(0, 0, size.width, size.height);
    _readView.backgroundColor = [UIColor blackColor];
    [self.view addSubview: _readView];
    
    self.cameraOverlayView = [[ZbarCameraOverlayView alloc] initWithFrame:CGRectMake(0, barHeight, size.width, size.height - barHeight )];
    [self.view addSubview:_cameraOverlayView];
    
    _loadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight, size.width, size.height - barHeight)];
    _loadingBackgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_loadingBackgroundView];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.frame = CGRectMake(size.width/2-20, size.height/2-84, 40, 40);
    [_loadingView startAnimating];
    [_loadingView setHidesWhenStopped:YES];
    [_loadingBackgroundView addSubview:_loadingView];
    
  //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 44, 90, 38)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:duration];
    //closeButton.transform = CGAffineTransformMakeRotation(-M_PI * 1.5);
    //[UIView commitAnimations];
}

- (void)removeLoadingView{
    [_loadingView setHidden:YES];
    [_loadingBackgroundView removeFromSuperview];
}

-(void)cancleButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_readView stop];
}

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image{
    ZBarSymbol *symbol = nil;
    for (symbol in symbols) {
        break;
    }
    if (_success) {
        _success(symbol.data);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [MobClick event:@"scan_order_number_success"];
    }];
    
    NSLog(@"%@",symbol.data);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end