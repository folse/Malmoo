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
}

@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *phoneBtn;

@property (strong, nonatomic) IBOutlet UILabel *openHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *startersLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainDishesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dessertsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (assign) BOOL isOpen;
@property (nonatomic,retain) NSIndexPath *selectIndex;

@property (strong, nonatomic) IBOutlet UIButton *starterDishBtn;
@property (strong, nonatomic) IBOutlet UIButton *mainDishBtn;
@property (strong, nonatomic) IBOutlet UIButton *dessertDishBtn;

@end

@implementation DetailController

-(void)viewWillAppear:(BOOL)animated
{
    [self displayDishMenu];
    
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_titleLabel setText:_shop.name];
    [_addressLabel setText:_shop.address];
    [_phoneBtn setTitle:_shop.phone forState:UIControlStateNormal];
    [_openHoursLabel setText:_shop.openHours];
    [_startersLabel setText:_shop.starterDishes];
    [_mainDishesLabel setText:_shop.mainDishes];
    [_dessertsLabel setText:_shop.dessertDishes];
    
    NSString *imagePath = [[ProjectSettings alloc] getMD5FilePathWithUrl:_shop.avatarUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:imagePath]){
        
        _avatarImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayDishMenu
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

- (IBAction)moreBtnAction:(id)sender
{
    [self displayComposerSheet];
    
//    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"a"];
//    [actionSheet bk_addButtonWithTitle:@"Share this" handler:^{
//       
//        
//    }];
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [actionSheet bk_addButtonWithTitle:@"Report error" handler:^{
//            
//            
//            
//        }];
//    }
//    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
//    [actionSheet showInView:self.view];
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

-(void)displayComposerSheet
{
    // Attach an image to the email
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
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

@end
