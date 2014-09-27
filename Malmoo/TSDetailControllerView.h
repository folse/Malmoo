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
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (strong, nonatomic) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsLabel;
@property (weak, nonatomic) IBOutlet UIButton *parkingButton;
@property (weak, nonatomic) IBOutlet UILabel *parkingLabel;
@property (weak, nonatomic) IBOutlet UIButton *alcoholButton;
@property (weak, nonatomic) IBOutlet UILabel *alcoholLabel;
@property (weak, nonatomic) IBOutlet UIButton *deliveryButton;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (weak, nonatomic) IBOutlet UIButton *wifiButton;
@property (weak, nonatomic) IBOutlet UILabel *wifiLabel;
@property (weak, nonatomic) IBOutlet UIButton *reservationButton;
@property (weak, nonatomic) IBOutlet UILabel *reservationLabel;
@property (strong, nonatomic) IBOutlet UILabel *openHourLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *albumScrollView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *openHourButton;

@end
