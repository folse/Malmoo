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
#import "TSMenuController.h"
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
}

@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *phoneBtn;

@property (strong, nonatomic) IBOutlet UILabel *openHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *startersLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainDishesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dessertsLabel;

@property (assign) BOOL isOpen;
@property (nonatomic,retain) NSIndexPath *selectIndex;

@property (strong, nonatomic) IBOutlet UIButton *starterDishBtn;
@property (strong, nonatomic) IBOutlet UIButton *mainDishBtn;
@property (strong, nonatomic) IBOutlet UIButton *dessertDishBtn;

@end

@implementation TSDetailController
{
    UIScrollView *_viewScroller;
    
    BTGlassScrollView *_glassScrollView;
    
    BTGlassScrollView *_glassScrollView1;
    BTGlassScrollView *_glassScrollView2;
    BTGlassScrollView *_glassScrollView3;
    int _page;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    [self addBottomToolBar];
    
    //show animation trick
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // [_glassScrollView1 setBackgroundImage:[UIImage imageNamed:@"background"] overWriteBlur:YES animated:YES duration:1];
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    [bottomToolBar removeFromSuperview];
    
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
    
    [_titleLabel setText:_place.name];
    [_addressLabel setText:_place.address];
    [_phoneBtn setTitle:@"042-327050" forState:UIControlStateNormal];
    [_openHoursLabel setText:_place.openHours];
    [_startersLabel setText:_place.starterDishes];
    [_mainDishesLabel setText:_place.mainDishes];
    [_dessertsLabel setText:_place.dessertDishes];
    
    [self removeNavigationBarShadow];
    
    //[self setHeaderImage];
    
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
    self.title = @"Awesome";
    self.view.backgroundColor = [UIColor whiteColor];
    
    TSDetailControllerView *detailView = [[TSDetailControllerView alloc] init];
    
    _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.frame BackgroundImage:[UIImage imageNamed:@"background3"] blurredImage:nil viewDistanceFromBottom:200 foregroundView:detailView];
    
    [self.tableView addSubview:_glassScrollView];
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
        
        UIImageView *bgImageView = [[UIImageView alloc] init];
        
        NSString *originalImageUrl = [self getOriginalImageUrl:_place.avatarUrl];
        
        NSString *originalImagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:originalImageUrl];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:originalImagePath]){
            
            originalImage = [UIImage imageWithContentsOfFile:originalImagePath];
            
            bgImageViewHeight = originalImage.size.height;
            
            [bgImageView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, bgImageViewHeight)];
            
            [self.tableView setContentInset:UIEdgeInsetsMake(bgImageViewHeight, 0, 0, 0)];
            
        }else{
            
            NSString *imagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:_place.avatarUrl];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:imagePath]){
                
                originalImage = [UIImage imageWithContentsOfFile:imagePath];
            }
            
            coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [bgImageView addSubview:coverImageView];
            
            [self showImageByDownloadingProgress:originalImageUrl withDownloadPath:originalImagePath];
            
            bgImageViewHeight = originalImage.size.height*320/120;
            
            [bgImageView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, bgImageViewHeight)];
        }
        
        if(bgImageViewHeight <= 320){
            [self.tableView setContentInset:UIEdgeInsetsMake(bgImageViewHeight - 42, 0, 0, 0)];
        }else{
            [self.tableView setContentInset:UIEdgeInsetsMake(200, 0, 0, 0)];
        }
        
        [bgImageView setImage:originalImage];
        [bgImageView setContentMode:UIViewContentModeScaleAspectFill];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, originalImage.size.height)];
        [bgView addSubview:bgImageView];
        [self.tableView setBackgroundView:bgView];
        
    }
}

-(NSString *)getOriginalImageUrl:(NSString *)imageUrl
{
    NSMutableString *imageUrlString = [[NSMutableString alloc] initWithString:imageUrl];
    [imageUrlString replaceOccurrencesOfString:@"-w120/" withString:@"-w320/" options:NSBackwardsSearch range:NSMakeRange(0, imageUrlString.length)];
    s(imageUrlString)
    return imageUrlString;
}

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

- (IBAction)phoneBtnAction:(id)sender
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_place.phone]];
    UIWebView  *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
    [self.view addSubview:phoneCallWebView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
- (IBAction)photosButtonAction:(id)sender
{
    [self performSegueWithIdentifier:@"photoCollectionController" sender:self];
}

- (IBAction)starterDishBtnAction:(id)sender
{
    [self menuBtnAction:sender];
}

- (IBAction)mainDishBtnAction:(id)sender
{
    [self menuBtnAction:sender];
}

- (IBAction)dessertDishBtnAction:(id)sender
{
    [self menuBtnAction:sender];
}

-(void)menuBtnAction:(id)sender
{
    UIButton *actionBtn = (UIButton *)sender;
    selectedMenuType = [[actionBtn titleLabel] text];
    [self performSegueWithIdentifier:@"MenuController" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapController"]) {
        
        MapController *mapController = segue.destinationViewController;
        [mapController setPlace:_place];
        
    }else if ([segue.identifier isEqualToString:@"MenuController"]) {
        
        TSMenuController *menuController = segue.destinationViewController;
        [menuController setPlace:_place];
        [menuController setMenuType:selectedMenuType];
        
    }else if ([segue.identifier isEqualToString:@"photoCollectionController"]) {
        
        TSPhotoCollectionController *photoCollectionController = segue.destinationViewController;
        [photoCollectionController setPlace:_place];
    }
}

#pragma mark - Mail

-(void)showComposerSheet
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
    NSArray *toRecipients = [NSArray arrayWithObject:@"weigang@gmail.com"];
    
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

-(void)sharePlace
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

-(void)favouritePlace
{
    if (_place.favourited) {
        
        [favouriteImageBtn setImage:[UIImage imageNamed:@"icon_star"]];
        
        _place.favourited = NO;
        
    }else{
        
        [favouriteImageBtn setImage:[UIImage imageNamed:@"icon_star_pressed"]];
        
        _place.favourited = YES;
    }
}

-(void)addBottomToolBar
{
    bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, self.view.frame.size.width, 44.0f)];
    bottomToolBar.tintColor = APP_COLOR;
    [bottomToolBar sizeToFit];
    
    favouriteImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_star"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(favouritePlace)];
    favouriteBtn = [[UIBarButtonItem alloc] initWithTitle:@"Favorite" style:UIBarButtonItemStyleBordered target:self action:@selector(favouritePlace)];
    [favouriteBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
    
    shareImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(sharePlace)];
    shareBtn = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(sharePlace)];
    [shareBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
    
    reportImageBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_report"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(showComposerSheet)];
    reportBtn = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStyleBordered target:self action:@selector(showComposerSheet)];
    [reportBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR,NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:14.0],NSFontAttributeName,nil] forState:normal];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSArray *itemArray = [[NSArray alloc] initWithObjects:flexSpace, favouriteImageBtn,favouriteBtn, flexSpace, shareImageBtn,shareBtn, flexSpace, reportImageBtn,reportBtn, flexSpace, nil];
    
    [bottomToolBar setItems:itemArray animated:YES];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bottomToolBar];
}

@end
