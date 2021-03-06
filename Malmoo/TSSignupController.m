//
//  SignupController.m
//  Malmoo
//
//  Created by folse on 10/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSSignupController.h"

@interface TSSignupController ()
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

@implementation TSSignupController

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

- (IBAction)signupButtonAction:(id)sender
{
    usernameString = _usernameTextField.text;
    passwordString = _passwordTextField.text;
    emailString = _emailTextField.text;
    
    if (usernameString.length > 0 && passwordString.length > 0 && emailString.length > 0) {
        
        [self.view endEditing:YES];
        
        HUD_SHOW
        
        PFUser *user = [PFUser user];
        user.username = usernameString;
        user.password = passwordString;
        user.email = emailString;
        user[@"isMerchant"] = @NO;
        
//        if (mobile != nil && mobile.length > 0) {
//            user[@"mobile"] = mobile;
//        }
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            HUD_DISMISS
            
            if (!error) {
                
                [USER setBool:YES forKey:@"userLogined"];
                [USER setObject:usernameString forKey:@"userName"];
                                
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"afterLogin" object:nil];
                    e(@"signupSuccess")
                }];
                
            } else {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"%@",[error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
                [alertView show];
                
                e(@"signupFailed")
            }
        }];
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please input the username and password",nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissPage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        e(@"signupExit")
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
*/

@end
