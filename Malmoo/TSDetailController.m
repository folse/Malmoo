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
#import "TSGuideController.h"

@interface TSDetailController ()<MFMailComposeViewControllerDelegate>
{
    NSString *clickedPhotoType;
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
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"img_empty"] forBarMetrics:UIBarMetricsDefault];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //preventing weird inset
    [self setAutomaticallyAdjustsScrollViewInsets: NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"img_empty"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor blackColor];
    
    detailView = [[TSDetailControllerView alloc] init];
    
    [detailView.nameLabel setText:_place.name];
    [detailView.newsLabel setText:_place.news];
    [detailView.addressButton setTitle:_place.address forState:UIControlStateNormal];
    [detailView.addressButton.titleLabel setNumberOfLines:3];
    [detailView.descriptionLabel setText:_place.descriptions];
    
    if (!_place.parking) {
        [detailView.parkingLabel setAlpha:0.2];
        [detailView.parkingButton setAlpha:0.2];
    }
    
    if (!_place.wifi) {
        [detailView.wifiLabel setAlpha:0.2];
        [detailView.wifiButton setAlpha:0.2];
    }
    
    if (!_place.alcohol) {
        [detailView.alcoholLabel setAlpha:0.2];
        [detailView.alcoholButton setAlpha:0.2];
    }
    
    if (!_place.delivery) {
        [detailView.deliveryLabel setAlpha:0.2];
        [detailView.deliveryButton setAlpha:0.2];
    }
    
    if (!_place.reservation) {
        [detailView.reservationLabel setText:_place.phone];
    }
    
    if (_place.phone) {
        
        [detailView.phoneButton setTitle:_place.phone forState:UIControlStateNormal];
        
    }else{
        
        [detailView.phoneButton setEnabled:NO];
    }
    
    _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.frame BackgroundImage:nil blurredImage:nil viewDistanceFromBottom:200 foregroundView:detailView];
    
    [self.tableView addSubview:_glassScrollView];
    
    [self setHeaderImage];
    
    [self setOpenHour];
    
    [detailView.favoriteButton addTarget:self action:@selector(favoriteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.shareButton addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.reportButton addTarget:self action:@selector(reportButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.mapButton addTarget:self action:@selector(mapButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.phoneButton addTarget:self action:@selector(phoneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [detailView.openHourButton addTarget:self action:@selector(openHourButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self getFavorite];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteButtonAction) name:@"afterLogin" object:nil];
    
     [self removeNavigationBarShadow];
}

-(void)getFavorite
{
    if (USER_LOGIN) {
        PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
        [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [favoriteQuery whereKey:@"place" equalTo:_place.parseObject];
        [favoriteQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if(number > 0){
                
                _place.favourited = YES;
                [detailView.favoriteButton setImage:[UIImage imageNamed:@"icon_star_pressed"] forState:UIControlStateNormal];
            }
        }];
        
        if (_place.favourited){
            [detailView.favoriteButton setImage:[UIImage imageNamed:@"icon_star_pressed"] forState:UIControlStateNormal];
        }
    }
}

-(void)addFavorite
{
    _place.favourited = YES;
    
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
    [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [favoriteQuery whereKey:@"place" equalTo:_place.parseObject];
    [favoriteQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if(number == 0){
            
            PFObject *favorite = [PFObject objectWithClassName:@"Favorite"];
            favorite[@"user"] = [PFUser currentUser];
            favorite[@"place"] = _place.parseObject;
            [favorite saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
        }
    }];
}

-(void)removeFavorite
{
    _place.favourited = NO;
    
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"Favorite"];
    [favoriteQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [favoriteQuery whereKey:@"place" equalTo:_place.parseObject];
    [favoriteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
        }
    }];
}

-(void)setOpenHour
{
    if (_place.openHours != nil && _place.openHours.length > 0) {
        
        NSString *openHour = [NSString stringWithFormat:@"Today %@",[self getOpenHours:_place.openHours]];
        
        [detailView.openHourLabel setText:openHour];
        
    }else{
        
        [detailView.openHourLabel setHidden:YES];
    }
}

-(void)setHeaderImage
{
    if (_place.avatarUrl != nil) {
        
        NSString *bgHdImageUrl = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg|imageMogr2/thumbnail/x%f/gravity/center/crop/%fx%f/quality/70",_place.avatarUrl,SCREEN_HEIGHT*2,SCREEN_WIDTH*2,SCREEN_HEIGHT*2];
        s(bgHdImageUrl)
        bgHdImageUrl = [bgHdImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *hdImageURL = [NSURL URLWithString:bgHdImageUrl];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if ([manager cachedImageExistsForURL:hdImageURL]) {
            
            UIImage *hdBgImage = [manager.imageCache imageFromDiskCacheForKey:[manager cacheKeyForURL:hdImageURL]];
            
            _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.frame BackgroundImage:hdBgImage blurredImage:nil viewDistanceFromBottom:200 foregroundView:detailView];
            
            [self.tableView addSubview:_glassScrollView];
            
            [self getPhotos];
            
        }else{
            
            NSString *bgImageUrl = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg|imageMogr2/thumbnail/x%f/gravity/center/crop/%fx%f/blur/50x50/quality/50",_place.avatarUrl,SCREEN_HEIGHT*2,SCREEN_WIDTH*2,SCREEN_HEIGHT*2];
            s(bgHdImageUrl)
            bgImageUrl = [bgImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *bgImageURL = [NSURL URLWithString:bgImageUrl];
            
            if ([manager cachedImageExistsForURL:bgImageURL]) {
                
                UIImage *bgImage = [manager.imageCache imageFromDiskCacheForKey:[manager cacheKeyForURL:bgImageURL]];
                
                [self setBgImage:[bgImage unsharpen] withHdImageURL:hdImageURL];
                
            }else{
                
                [manager downloadImageWithURL:[NSURL URLWithString:bgImageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                    [self setBgImage:[image unsharpen] withHdImageURL:hdImageURL];
                }];
            }
        }
    }
}

-(void)setBgImage:(UIImage *)image withHdImageURL:(NSURL *)hdImageURL
{
    _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.frame BackgroundImage:image blurredImage:nil viewDistanceFromBottom:200 foregroundView:detailView];
    
    [self.tableView addSubview:_glassScrollView];
    
    [self setHdBgImage:hdImageURL];
    
    [self getPhotos];
}

-(void)setHdBgImage:(NSURL *)hdBgImageURL
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:hdBgImageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        [_glassScrollView setBackgroundImage:image overWriteBlur:YES animated:YES duration:1.6];
    }];
}

-(void)getPhotos
{
    PFRelation *relation = [_place.parseObject relationForKey:@"photos"];
    PFQuery *productPhotoQuery = [relation query];
    productPhotoQuery.limit = 3;
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

-(NSString *)getOpenHours:(NSString *)openHourData
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
    
    return [openHourString componentsSeparatedByString:@" "][1];
}

-(NSInteger)getTodayWeekDay
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    
    NSInteger weeekDay = [components weekday];
    
    return weeekDay;
}

-(void)showPlacePhotoAlbum
{
    for (int i = 0; i < photoUrlArray.count; i++) {
        
        NSString *thumbnailUrl = [NSString stringWithFormat:@"%@?imageView2/1/format|imageMogr2/gravity/North/thumbnail/150x/crop/!112x112a8",photoUrlArray[i]];

        thumbnailUrl = [thumbnailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(72*i+28*i+26, 198, 72, 72)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonAction)]];
        
        CALayer *layer = [imageView layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 2.0f;
        
        [detailView addSubview:imageView];
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

//-(void)showImageByDownloadingProgress:(NSString *)imageUrl withDownloadPath:(NSString *)imagePath
//{
//    NSURLRequest *photoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:photoRequest];
//
//    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:imagePath append:NO]];
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
//        UIImage *placeImage = [UIImage imageWithContentsOfFile:imagePath];
//
//        int totalExpectedToRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesExpectedToRead] intValue];
//        int totalRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesRead] intValue];
//
//        float scaleProgress = (float)totalRead/(float)totalExpectedToRead;
//
//        [coverImageView setFrame:CGRectMake(0, 0, 320, placeImage.size.height*scaleProgress)];
//        coverImageView.image = [self cutImage:placeImage withScale:scaleProgress];
//    }];
//
//    [operation setCompletionBlock:^{
//        UIImage *placeImage = [UIImage imageWithContentsOfFile:imagePath];
//        [coverImageView setFrame:CGRectMake(0, 0, 320, placeImage.size.height)];
//        coverImageView.image = placeImage;
//    }];
//
//    [operation start];
//}

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
    NSString *telUrl = [NSString stringWithFormat:@"telprompt:%@",[_place.phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSURL *url = [[NSURL alloc] initWithString:telUrl];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)mapButtonAction
{
    if (_place.latitude != 0 && _place.longitude != 0) {
        
        [self performSegueWithIdentifier:@"MapController" sender:self];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No location data",nil) message:NSLocalizedString(@"If you can make this address more particular, please 'report' us. Thanks~",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)photoButtonAction
{
    clickedPhotoType = @"product";
    
    [self performSegueWithIdentifier:@"PhotoCollectionController" sender:self];
}

- (IBAction)menuButtonAction:(id)sender
{
    clickedPhotoType = @"menu";
    
    [self performSegueWithIdentifier:@"PhotoCollectionController" sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapController"]) {
        
        TSMapController *mapController = segue.destinationViewController;
        [mapController setPlace:_place];
        
    }else if ([segue.identifier isEqualToString:@"PhotoCollectionController"]) {
        
        TSPhotoCollectionController *photoCollectionController = segue.destinationViewController;
        [photoCollectionController setDefaultPhotoType:clickedPhotoType];
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
    [picker setSubject:NSLocalizedString(@"Report Data Error",nil)];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"feedback@mtscandic.com"];
    
    [picker setToRecipients:toRecipients];
    [picker setMessageBody:NSLocalizedString(@"I find an information error at:  , it should be: ",nil) isHTML:NO];
    
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
    if (USER_LOGIN) {
        
        if (_place.favourited) {
            
            [detailView.favoriteButton setImage:[UIImage imageNamed:@"icon_star"] forState:UIControlStateNormal];
            
            [self removeFavorite];
            
        }else{
            
            [detailView.favoriteButton setImage:[UIImage imageNamed:@"icon_star_pressed"] forState:UIControlStateNormal];
            
            [self addFavorite];
        }
        
    }else{
        
        TSGuideController *guideController = [ACCOUNT_STORYBOARD instantiateViewControllerWithIdentifier:@"GuideController"];
        [self presentViewController:guideController animated:YES completion:^{
            
        }];
    }
}

-(void)openHourButtonAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Open Hour",nil) message:_place.openHours delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
    [alertView show];
}

@end
