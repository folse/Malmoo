//
//  SubCateViewController.m
//  ExpansionTableViewByZQ
//
//  Created by 郑 琪 on 13-2-27.
//  Copyright (c) 2013年 郑 琪. All rights reserved.
//

#import "SubCateViewController.h"

@interface SubCateViewController ()
@property (strong, nonatomic) IBOutlet UILabel *label_Info;

@end

@implementation SubCateViewController
@synthesize label_Info;
@synthesize Info;
-(void)DisplayInfo:(NSString *)Info
{
//    label_Info.numberOfLines = 0;
//    CGSize size = [Info sizeWithFont:label_Info.font constrainedToSize:CGSizeMake(320, MAXFLOAT)];
//    if(size.height < label_Info.frame.size.height)
//    {
//        size = CGSizeMake(320, label_Info.frame.size.height);
//    }
//    [label_Info setFrame:CGRectMake(0, 0, 320, size.height)];
//    [self.view setFrame:CGRectMake(0, 0, 320, size.height)];
//    label_Info.text = Info;
}

#pragma ViewController
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
    // Do any additional setup after loading the view from its nib.
    label_Info.numberOfLines = 0;
    CGSize size = [Info boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:nil context:nil].size;
    if(size.height < label_Info.frame.size.height)
    {
        size = CGSizeMake(300, label_Info.frame.size.height);
    }
    [label_Info setFrame:CGRectMake(12, 0, 300, size.height)];
    [self.view setFrame:CGRectMake(0, 0, 320, size.height)];
    label_Info.text = Info;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
