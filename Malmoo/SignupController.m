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
    NSString *userName;
    NSString *password;
    NSString *email;
    NSString *mobile;
}

@end

@implementation SignupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void)parseSignupUser
{
    PFUser *user = [PFUser user];
    user.username = userName;
    user.password = password;
    user.email = email;
    
    if (mobile != nil && mobile.length > 0) {
        user[@"mobile"] = mobile;
    }
    
    user[@"isMerchant"] = @NO;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            s(errorString)
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
