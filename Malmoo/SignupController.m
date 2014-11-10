//
//  SignupController.m
//  Malmoo
//
//  Created by folse on 10/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "SignupController.h"

@interface SignupController ()
{
    NSString *usernameString;
    NSString *passwordString;
    NSString *emailString;
}
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)signupButtonAction:(id)sender
{
    usernameString = _usernameTextField.text;
    passwordString = _passwordTextField.text;
    emailString = _emailTextField.text;
    
    if (usernameString.length > 0 && passwordString.length > 0 && emailString.length > 0) {
        
        [SVProgressHUD show];
        
        PFUser *user = [PFUser user];
        user.username = usernameString;
        user.password = passwordString;
        user.email = emailString;
        user[@"isMerchant"] = @NO;
        
//        if (mobile != nil && mobile.length > 0) {
//            user[@"mobile"] = mobile;
//        }
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [SVProgressHUD dismiss];
            
            if (!error) {
                
                [USER setBool:YES forKey:@"userLogined"];
                
                if (user.isAuthenticated) {
                    s(@"logined");
                    s([PFUser currentUser])
                }
                [USER setBool:YES forKey:@"needContinueFavorite"];
                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please input the username and password" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
*/

@end
