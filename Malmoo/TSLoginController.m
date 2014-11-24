//
//  TSLoginController.m
//  Malmoo
//
//  Created by folse on 10/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSLoginController.h"

@interface TSLoginController ()


@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TSLoginController
{
    NSString *usernameString;
    NSString *passwordString;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonAction:(id)sender
{
    usernameString = _usernameTextField.text;
    passwordString = _passwordTextField.text;
    
    if (usernameString.length > 0 && passwordString.length > 0) {
        
        [self.view endEditing:YES];
        
        HUD_SHOW
        
        [PFUser logInWithUsernameInBackground:usernameString password:passwordString block:^(PFUser *user, NSError *error) {
            
            HUD_DISMISS
            
            if (!error) {

                [USER setBool:YES forKey:@"userLogined"];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"afterLogin" object:nil];
                    e(@"loginSuccess")
                }];
                
            }else{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Opps", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil, nil];
                [alertView show];
                
                e(@"loginFailed")
                
            }
        }];
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please input the username and password", @"")   message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)dismissPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        e(@"loginExit")
    }];
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
