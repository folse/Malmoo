//
//  TSDetailControllerView.h
//  Malmoo
//
//  Created by Jennifer on 8/26/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSDetailControllerView : UIView
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsLabel;
@property (strong, nonatomic) IBOutlet UILabel *parkingLabel;
@property (strong, nonatomic) IBOutlet UILabel *alcoholLabel;
@property (strong, nonatomic) IBOutlet UILabel *reservation;
@property (strong, nonatomic) IBOutlet UILabel *openHourLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *albumScrollView;

@end
