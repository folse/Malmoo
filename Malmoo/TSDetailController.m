//
//  DetailController.m
//  Pods
//
//  Created by folse on 3/15/14.
//
//

#import "TSDetailController.h"
#import "TSMapController.h"
#import "SubCateViewController.h"
#import "TSPhotoCollectionController.h"
#import "Cell.h"
#import <MessageUI/MessageUI.h>
#import "TSDetailControllerView.h"

@interface TSDetailController ()<MFMailComposeViewControllerDelegate>
{
    NSString *selectedMenuType;
    UIToolbar *bottomToolBar;
    UIBarButtonItem *shareBtn;
    UIBarButtonItem *shareImageBtn;
    UIBarButtonItem *reportBtn;
    UIBarButtonItem *reportImageBtn;
    UIBarButtonItem *favouriteBtn;
    UIBarButtonItem *favouriteImageBtn;
    UIImageView *coverImageView;
    UIImage *originalImage;
    float bgImageViewHeight;
    NSMutableArray *photoUrlArray;
}

@property (assign) BOOL isOpen;
@property (nonatomic,retain) NSIndexPath *selectIndex;

@end

@implementation TSDetailController
{
    UIScrollView *_viewScroller;
    
    BTGlassScrollView *_glassScrollView;
    TSDetailControllerView *detailView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    _place.favourited = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _place.name;
    
    [self removeNavigationBarShadow];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //preventing weird inset
    [self setAutomaticallyAdjustsScrollViewInsets: NO];
    
    //navigation bar work
//    NSShadow *shadow = [[NSShadow alloc] init];
//    [shadow setShadowOffset:CGSizeMake(1, 1)];
//    [shadow setShadowColor:[UIColor blackColor]];
//    [shadow setShadowBlurRadius:1];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSShadowAttributeName: shadow};
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.title = @"Detail";
    self.view.backgroundColor = [UIColor whiteColor];
    
    detailView = [[TSDetailControllerView alloc] init];
    
    [detailView.nameLabel setText:_place.name];
    [detailView.newsLabel setText:_place.news];
    [detailView.addressButton setTitle:_place.address forState:UIControlStateNormal];
    [detailView.addressButton.titleLabel setNumberOfLines:3];
    [detailView.openHourLabel setText:_place.openHours];
    [detailView.descriptionLabel setText:_place.description];
    
    if (!_place.parking) {
        [detailView.parkingLabel setAlpha:0.2];
    }
    
    if (!_place.wifi) {
        [detailView.parkingLabel setAlpha:0.2];
    }
    
    if (!_place.alcohol) {
        [detailView.alcoholLabel setAlpha:0.2];
    }
    
    if (!_place.delivery) {
        [detailView.reservationLabel setAlpha:0.2];
    }
    
    if (!_place.reservation) {
        [detailView.reservationLabel setAlpha:0.2];
    }
    
    [detailView.favoriteButton addTarget:self action:@selector(favoriteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.shareButton addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.reportButton addTarget:self action:@selector(reportButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.mapButton addTarget:self action:@selector(mapButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.phoneButton addTarget:self action:@selector(phoneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self setHeaderImage];

}

-(NSString *)showOpenHours:(NSString *)openHourData
{
    NSString *openHourString = @"";
    
    NSArray *weekDayDataArray = [openHourData componentsSeparatedByString:@"\n"];
    
    switch ([self getTodayWeekDay]) {
        // 1 is Sunday
        case 1:
            openHourString = weekDayDataArray[6];
            break;
        // 2 is Monday
        case 2:
            openHourString = weekDayDataArray[0];
            break;
            
        case 3:
            openHourString = weekDayDataArray[1];
            break;
            
        case 4:
            openHourString = weekDayDataArray[2];
            break;
            
        case 5:
            openHourString = weekDayDataArray[3];
            break;
            
        case 6:
            openHourString = weekDayDataArray[4];
            break;
            
        case 7:
            openHourString = weekDayDataArray[5];
            break;
            
        default:
            break;
    }
    
    return openHourString;
}

-(NSInteger)getTodayWeekDay
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    
    NSInteger weeekDay = [components weekday];
    
    return weeekDay;
}

-(void)getPhotos
{
    PFRelation *relation = [_place.parseObject relationForKey:@"photos"];
    PFQuery *productPhotoQuery = [relation query];
    productPhotoQuery.limit = 4;
    //[productPhotoQuery whereKey:@"product" equalTo:@"true"];
    [productPhotoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            photoUrlArray = [NSMutableArray new];
            
            for (PFObject *photoObject in objects) {
                [photoUrlArray addObject:photoObject[@"url"]];
            }
            
            [self showPlacePhotoAlbum];
            
        } else {
            
            s(error)
        }
    }];
}

-(void)showPlacePhotoAlbum
{
    [detailView.albumScrollView setDelegate:self];
    [detailView.albumScrollView setContentSize:CGSizeMake(70*photoUrlArray.count, 70)];
    
    UIGestureRecognizer *imageTap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonAction)];
    
    for (int i = 0; i < photoUrlArray.count; i++) {
        
        NSString *thumbnailUrl = [NSString stringWithFormat:@"%@?imageView2/1/w/140",photoUrlArray[i]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(70*i+20*i+20, 0, 70, 70)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];

        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:imageTap];
        
        CALayer *layer = [imageView layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 3.6f;
    
        [detailView.albumScrollView addSubview:imageView];
    }
}

- (void)viewWillLayoutSubviews
{
    // if the view has navigation bar, this is a great place to realign the top part to allow navigation controller
    // or even the status bar
    
    [_glassScrollView setTopLayoutGuideLength:[self.topLayoutGuide length]];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self viewWillAppear:YES];
}

-(void)setHeaderImage
{
    if (_place.avatarUrl != nil) {
        
        NSString *bgImageUrl = [NSString stringWithFormat:@"%@?imageMogr2/thumbnail/x1136/interlace/1",_place.avatarUrl];

        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:bgImageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.frame BackgroundImage:image blurredImage:nil viewDistanceFromBottom:200 foregroundView:detailView];
            
            [self.tableView addSubview:_glassScrollView];
            
            self.view.backgroundColor = [UIColor blackColor];
            
            [self getPhotos];
            
        }];
        
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];

    }
}

//-(void)setHeaderImage
//{
//    if (_place.avatarUrl != nil) {
//        
//        UIImageView *bgImageView = [[UIImageView alloc] init];
//        
//        NSString *originalImageUrl = [self getOriginalImageUrl:_place.avatarUrl];
//        
//        NSString *originalImagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:originalImageUrl];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if ([fileManager fileExistsAtPath:originalImagePath]){
//            
//            originalImage = [UIImage imageWithContentsOfFile:originalImagePath];
//            
//            bgImageViewHeight = originalImage.size.height;
//            
//            [bgImageView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, bgImageViewHeight)];
//            
//            [self.tableView setContentInset:UIEdgeInsetsMake(bgImageViewHeight, 0, 0, 0)];
//            
//        }else{
//            
//            NSString *imagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:_place.avatarUrl];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            if ([fileManager fileExistsAtPath:imagePath]){
//                
//                originalImage = [UIImage imageWithContentsOfFile:imagePath];
//            }
//            
//            coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//            [bgImageView addSubview:coverImageView];
//            
//            [self showImageByDownloadingProgress:originalImageUrl withDownloadPath:originalImagePath];
//            
//            bgImageViewHeight = originalImage.size.height*320/120;
//            
//            [bgImageView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, bgImageViewHeight)];
//        }
//        
////        if(bgImageViewHeight <= 320){
////            [self.tableView setContentInset:UIEdgeInsetsMake(bgImageViewHeight - 42, 0, 0, 0)];
////        }else{
//            [self.tableView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
////        }
//        
//        //[bgImageView setImage:originalImage];
//        //[bgImageView setContentMode:UIViewContentModeScaleAspectFill];
//        
//        [_glassScrollView setBackgroundImage:originalImage];
//        
////        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, originalImage.size.height)];
////        [bgView addSubview:bgImageView];
////        [self.tableView setBackgroundView:bgView];
//        
//    }
//}
//
//-(NSString *)getOriginalImageUrl:(NSString *)imageUrl
//{
//    NSMutableString *imageUrlString = [[NSMutableString alloc] initWithString:imageUrl];
//    [imageUrlString replaceOccurrencesOfString:@"-w120/" withString:@"-w320/" options:NSBackwardsSearch range:NSMakeRange(0, imageUrlString.length)];
//    s(imageUrlString)
//    return imageUrlString;
//}

-(void)showImageByDownloadingProgress:(NSString *)imageUrl withDownloadPath:(NSString *)imagePath
{
    NSURLRequest *photoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:photoRequest];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:imagePath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        UIImage *placeImage = [UIImage imageWithContentsOfFile:imagePath];
        
        int totalExpectedToRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesExpectedToRead] intValue];
        int totalRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesRead] intValue];
        
        float scaleProgress = (float)totalRead/(float)totalExpectedToRead;
        
        [coverImageView setFrame:CGRectMake(0, 0, 320, placeImage.size.height*scaleProgress)];
        coverImageView.image = [self cutImage:placeImage withScale:scaleProgress];
    }];
    
    [operation setCompletionBlock:^{
        UIImage *placeImage = [UIImage imageWithContentsOfFile:imagePath];
        [coverImageView setFrame:CGRectMake(0, 0, 320, placeImage.size.height)];
        coverImageView.image = placeImage;
    }];
    
    [operation start];
}

-(UIImage *)cutImage:(UIImage *)superImage withScale:(float)scale{
    
    CGSize subImageSize = CGSizeMake(superImage.size.width,superImage.size.height);
    //定义裁剪的区域相对于原图片的位置
    CGRect subImageRect = CGRectMake(0, 0, superImage.size.width,superImage.size.height*scale);
    CGImageRef imageRef = superImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext(); //返回裁剪的部分图像
    return returnImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeNavigationBarShadow
{
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UIImageView class]] && view2.frame.size.width == 320) {
                [view2 removeFromSuperview];
            }
        }
    }
}

- (void)phoneButtonAction
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_place.phone]];
    UIWebView  *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
    [self.view addSubview:phoneCallWebView];
}

-(void)mapButtonAction
{
    [self performSegueWithIdentifier:@"MapController" sender:self];
}

-(void)photoButtonAction
{
    [self performSegueWithIdentifier:@"PhotoCollectionController" sender:self];
}

- (IBAction)menuButtonAction:(id)sender
{    
    [self performSegueWithIdentifier:@"MenuPhotoCollectionController" sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapController"]) {
        
        MapController *mapController = segue.destinationViewController;
        [mapController setPlace:_place];
        
    }else if ([segue.identifier isEqualToString:@"PhotoCollectionController"]) {
        
        TSPhotoCollectionController *photoCollectionController = segue.destinationViewController;
        [photoCollectionController setDefaultPhotoType:@"product"];
        [photoCollectionController setPlace:_place];
        
    }else if ([segue.identifier isEqualToString:@"MenuPhotoCollectionController"]) {
        
        TSPhotoCollectionController *photoCollectionController = segue.destinationViewController;
        [photoCollectionController setDefaultPhotoType:@"menu"];
        [photoCollectionController setPlace:_place];
    }
}

-(void)reportButtonAction
{
    // Attach an image to the email
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker.navigationBar setTintColor:[UIColor whiteColor]];
    [picker setSubject:@"Report Data Error"];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"feedback@mtscandic.com"];
    
    [picker setToRecipients:toRecipients];
    [picker setMessageBody:@"I find an information error at:  , it should be: " isHTML:NO];
    
    NSData *myData = UIImageJPEGRepresentation(viewImage, 1.0);
    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@""];
    
    // Fill out the email body text
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)shareButtonAction
{
    NSString *placePhoneString = _place.phone;
    
    if (placePhoneString == nil) {
        placePhoneString = @" ";
    }
    
    NSString *appName =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *message = [NSString stringWithFormat:@"%@,%@,%@ Send by %@",_place.name,_place.address,placePhoneString,appName];
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems: arrayOfActivityItems applicationActivities:nil];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

-(void)favoriteButtonAction
{
    if (_place.favourited) {
        
        [favouriteImageBtn setImage:[UIImage imageNamed:@"icon_star"]];
        
        _place.favourited = NO;
        
    }else{
        
        [favouriteImageBtn setImage:[UIImage imageNamed:@"icon_star_pressed"]];
        
        _place.favourited = YES;
    }
}

//-(void)addBottomToolBar
//{
//    bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, self.view.frame.size.width, 44.0f)];
//    bottomToolBar.tintColor = APP_COLOR;
//    [bottomToolBar sizeToFit];
//    
//    favouriteImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_star"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(favouritePlace)];
//    favouriteBtn = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style:UIBarButtonItemStyleBordered target:self action:@selector(favouritePlace)];
//    [favouriteBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
//    
//    shareImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(sharePlace)];
//    shareBtn = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(sharePlace)];
//    [shareBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
//    
//    reportImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_report"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(showComposerSheet)];
//    reportBtn = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStyleBordered target:self action:@selector(showComposerSheet)];
//    [reportBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
//    
//    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
//    NSArray *itemArray = [[NSArray alloc] initWithObjects:flexSpace, favouriteImageBtn,favouriteBtn, flexSpace, shareImageBtn,shareBtn, flexSpace, reportImageBtn,reportBtn, flexSpace, nil];
//    
//    [bottomToolBar setItems:itemArray animated:YES];
//    
//    [[[[UIApplication sharedApplication] delegate] window] addSubview:bottomToolBar];
//}

@end
