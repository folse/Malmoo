//
//  MoreController.m
//  
//
//  Created by folse on 3/21/14.
//
//

#import "TSMoreController.h"
#import "TSGuideController.h"

@interface TSMoreController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UISwitch *couponNotificationSwitcher;

@end

@implementation TSMoreController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
    
    if (USER_LOGIN) {
        [_logoutButton setTitle:NSLocalizedString(@"LOGOUT", @"") forState:UIControlStateNormal];
    }else{
        [_logoutButton setTitle:NSLocalizedString(@"LOGIN / SIGNUP", @"") forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_couponNotificationSwitcher setOn:[USER boolForKey:@"acceptCouponNotification"]];
}
- (IBAction)couponNotificationSwitcherAction:(id)sender
{
    [USER setBool:_couponNotificationSwitcher.on forKey:@"acceptCouponNotification"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonAction:(id)sender
{
    if (USER_LOGIN) {
        
        [USER setBool:NO forKey:@"userLogined"];
        [USER setBool:NO forKey:@"userSkipLogin"];
        
        [SVProgressHUD setForegroundColor:[UIColor colorWithRed:18/255.0 green:168/255.0 blue:245/255.0 alpha:1]];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
        [SVProgressHUD showSuccessWithStatus:@"Success"];
        
        [_logoutButton setTitle:NSLocalizedString(@"LOGIN / SIGNUP", @"") forState:UIControlStateNormal];
        
        [self resetUserDefaults];
        
        e(@"logout")
        
    }else{
        
        TSGuideController *guideController = [ACCOUNT_STORYBOARD instantiateViewControllerWithIdentifier:@"GuideController"];
        [self presentViewController:guideController animated:YES completion:^{
            e(@"moreLoginButton")
        }];
    }
}

- (void)resetUserDefaults
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

- (IBAction)menuBtnAction:(id)sender
{
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
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
