//
//  TSPhotoGalleryController.m
//  Malmoo
//
//  Created by Jennifer on 8/13/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSPhotoGalleryController.h"

@interface TSPhotoGalleryController ()
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenImageView;

@end

@implementation TSPhotoGalleryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_fullScreenImageView sd_setImageWithURL:[NSURL URLWithString:_photoArray[0]] placeholderImage:[UIImage imageNamed:@"default_shop_photo"]];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [_fullScreenImageView setUserInteractionEnabled:YES];
    [_fullScreenImageView addGestureRecognizer:imageTap];
}

-(void)imageTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
