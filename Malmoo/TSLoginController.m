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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
                [USER setBool:YES forKey:@"needContinueFavorite"];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Opps", @"") message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }];
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please input the username and password" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)dismissPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
