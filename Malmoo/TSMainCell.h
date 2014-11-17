//
//  TSMainCell.h
//  Malmoo
//
//  Created by folse on 3/12/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSMainCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end
