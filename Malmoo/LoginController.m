//
//  LoginController.m
//  Malmoo
//
//  Created by folse on 10/16/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()


@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginController
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
        
        [PFUser logInWithUsernameInBackground:usernameString password:passwordString block:^(PFUser *user, NSError *error) {
            
            if (error != nil) {
                [USER setObject:user forKey:@"PFCurrentUser"];
            }else{
                
            }
        }];
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please input the username and password" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
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
