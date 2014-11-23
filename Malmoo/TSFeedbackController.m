//
//  TSFeedbackController.m
//  Malmoo
//
//  Created by Jennifer on 11/23/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSFeedbackController.h"
#import "UMFeedback.h"

@interface TSFeedbackController ()<UMFeedbackDataDelegate,UITextViewDelegate>
{
    NSString *placeHolderString;
}

@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UITextField *contactTextField;

@property (strong, nonatomic) UMFeedback *feedback;

@end

@implementation TSFeedbackController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    placeHolderString = NSLocalizedString(@"Tell us your feeling~", nil);
    
    _feedbackTextView.text = placeHolderString;
    [_feedbackTextView setDelegate:self];
    
    _feedback = [UMFeedback sharedInstance];
    _feedback.delegate = self;
    [_feedback get];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_feedbackTextView.text isEqualToString:placeHolderString]) {
        [_feedbackTextView setText:@""];
    }
}

- (IBAction)sendButtonAction:(id)sender
{
    if (_feedbackTextView.text.length > 0 && ![_feedbackTextView.text isEqualToString:placeHolderString]) {
        
        NSMutableDictionary *feedbackDictionary = [NSMutableDictionary new];
                
        NSString *contentString = _feedbackTextView.text;
        
        if (USER_LOGIN) {
            contentString = [NSString stringWithFormat:@"%@, username: %@",contentString,[[PFUser currentUser] username]];
        }
        contentString = [NSString stringWithFormat:@"%@, contact: %@",contentString,_contactTextField.text];
        
        [feedbackDictionary setObject:contentString forKey:@"content"];
        
        [_feedback post:feedbackDictionary];
    }
}

- (void)getFinishedWithError: (NSError *)error
{
    if (error != nil) {
        NSLog(@"%@", error);
    } else {
        [self.view endEditing:YES];
        
        NSLog(@"%@", _feedback.topicAndReplies);
        [self.tableView reloadData];
    }
}

- (void)postFinishedWithError:(NSError *)error
{
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:18/255.0 green:168/255.0 blue:245/255.0 alpha:1]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
    [SVProgressHUD showSuccessWithStatus:@"Success"];
    [_feedback get];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _feedback.topicAndReplies.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedbackCell" forIndexPath:indexPath];
    
    cell.textLabel.text = _feedback.topicAndReplies[row][@"content"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:_feedback.topicAndReplies[row][@"content"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)menuButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    JDSideMenu *sideMenu = (JDSideMenu *)self.navigationController.parentViewController;
    
    if (sideMenu.isMenuVisible) {
        [sideMenu hideMenuAnimated:YES];
    }else{
        [sideMenu showMenuAnimated:YES];
    }
}

@end
