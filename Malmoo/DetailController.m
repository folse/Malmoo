//
//  DetailController.m
//  Pods
//
//  Created by folse on 3/15/14.
//
//

#import "DetailController.h"
#import "MapController.h"
#import "SubCateViewController.h"
#import "MenuController.h"
#import "Cell.h"
#import <MessageUI/MessageUI.h>

@interface DetailController ()<UIFolderTableViewDelegate,MFMailComposeViewControllerDelegate>
{
    NSString *selectedMenuType;
    UIToolbar *bottomToolBar;
    UIBarButtonItem *shareBtn;
    UIBarButtonItem *reportBtn;
    UIBarButtonItem *favouriteBtn;
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

@implementation DetailController

-(void)viewWillAppear:(BOOL)animated
{
    [self showDishMenu];
    
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    [self addBottomToolBar];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    [bottomToolBar removeFromSuperview];
    
    _shop.favourited = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_titleLabel setText:_shop.name];
    [_addressLabel setText:_shop.address];
    [_phoneBtn setTitle:@"042-327050" forState:UIControlStateNormal];
    [_openHoursLabel setText:_shop.openHours];
    [_startersLabel setText:_shop.starterDishes];
    [_mainDishesLabel setText:_shop.mainDishes];
    [_dessertsLabel setText:_shop.dessertDishes];
    
    [self removeNavigationBarShadow];
    
    [self setHeaderImage];
}

-(void)setHeaderImage
{
    if (_shop.avatarUrl != nil) {
        
        UIImageView *bgImageView = [[UIImageView alloc] init];
        
        NSString *originalImageUrl = [self getOriginalImageUrl:_shop.avatarUrl];
        
        NSString *originalImagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:originalImageUrl];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:originalImagePath]){
            
            originalImage = [UIImage imageWithContentsOfFile:originalImagePath];
            
            bgImageViewHeight = originalImage.size.height;
            
            [bgImageView setFrame:CGRectMake(0, 64, SCREEN_WIDTH, bgImageViewHeight)];
            
            [self.tableView setContentInset:UIEdgeInsetsMake(bgImageViewHeight, 0, 0, 0)];
            
        }else{
            
            NSString *imagePath = [[FSProjectSettings alloc] getMD5FilePathWithUrl:_shop.avatarUrl];
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
        UIImage *shopImage = [UIImage imageWithContentsOfFile:imagePath];
        
        int totalExpectedToRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesExpectedToRead] intValue];
        int totalRead = [[NSString stringWithFormat:@"%ld",(long)totalBytesRead] intValue];
        
        float scaleProgress = (float)totalRead/(float)totalExpectedToRead;
        
        [coverImageView setFrame:CGRectMake(0, 0, 320, shopImage.size.height*scaleProgress)];
        coverImageView.image = [self cutImage:shopImage withScale:scaleProgress];
    }];
    
    [operation setCompletionBlock:^{
        UIImage *shopImage = [UIImage imageWithContentsOfFile:imagePath];
        [coverImageView setFrame:CGRectMake(0, 0, 320, shopImage.size.height)];
        coverImageView.image = shopImage;
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

-(void)showDishMenu
{
    if (_shop.starterDishes) {
        [_starterDishBtn setHidden:NO];
    }
    
    if (_shop.mainDishes) {
        [_mainDishBtn setHidden:NO];
    }
    
    if (_shop.dessertDishes) {
        [_dessertDishBtn setHidden:NO];
    }
}

- (IBAction)phoneBtnAction:(id)sender
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_shop.phone]];
    UIWebView  *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
    [self.view addSubview:phoneCallWebView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:@"openHour" forIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell changeArrowWithUp:YES];
    SubCateViewController *subVc = [[SubCateViewController alloc]
                                    initWithNibName:NSStringFromClass([SubCateViewController class])
                                    bundle:nil];
    
    if ([cell.titleLabel.text isEqualToString:@"Open Hours"]) {
        
        subVc.Info = _shop.openHours;
    }
    
    self.tableView.scrollEnabled = NO;
    UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
    [folderTableView openFolderAtIndexPath:indexPath WithContentView:subVc.view
                                 openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                     // opening actions
                                     //[self CloseAndOpenACtion:indexPath];
                                 }
                                closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                    // closing actions
                                    //[self CloseAndOpenACtion:indexPath];
                                    //[cell changeArrowWithUp:NO];
                                }
                           completionBlock:^{
                               // completed actions
                               self.tableView.scrollEnabled = YES;
                               [cell changeArrowWithUp:NO];
                           }];
}

-(void)CloseAndOpenACtion:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectIndex]) {
        self.isOpen = NO;
        [self didSelectCellRowFirstDo:NO nextDo:NO];
        self.selectIndex = nil;
    }
    else
    {
        if (!self.selectIndex) {
            self.selectIndex = indexPath;
            [self didSelectCellRowFirstDo:YES nextDo:NO];
        }
        else
        {
            [self didSelectCellRowFirstDo:NO nextDo:YES];
        }
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
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
        [mapController setShop:_shop];
        
    }else if ([segue.identifier isEqualToString:@"MenuController"]) {
        
        MenuController *menuController = segue.destinationViewController;
        [menuController setShop:_shop];
        [menuController setMenuType:selectedMenuType];
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

-(void)shareShop
{
    NSString *shopPhoneString = _shop.phone;
    
    if (shopPhoneString == nil) {
        shopPhoneString = @" ";
    }
    
    NSString *appName =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *message = [NSString stringWithFormat:@"%@,%@,%@ Send by %@",_shop.name,_shop.address,shopPhoneString,appName];
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems: arrayOfActivityItems applicationActivities:nil];
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
}

-(void)favouriteShop
{
    if (_shop.favourited) {
        
        [favouriteBtn setImage:[UIImage imageNamed:@"icon_star"]];
        
        _shop.favourited = NO;
        
    }else{
        
        [favouriteBtn setImage:[UIImage imageNamed:@"icon_star_pressed"]];
        
        _shop.favourited = YES;
    }
}

-(void)addBottomToolBar
{
    bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, self.view.frame.size.width, 44.0f)];
    bottomToolBar.tintColor = APP_COLOR;
    [bottomToolBar sizeToFit];
    
    favouriteBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_star"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(favouriteShop)];
    
    shareBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(shareShop)];
    
    reportBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_report"] landscapeImagePhone:nil style:UIBarButtonItemStyleBordered target:self action:@selector(showComposerSheet)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSArray *itemArray = [[NSArray alloc] initWithObjects:flexSpace, favouriteBtn, flexSpace, shareBtn, flexSpace, reportBtn, flexSpace, nil];
    
    [bottomToolBar setItems:itemArray animated:YES];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bottomToolBar];
}

@end
