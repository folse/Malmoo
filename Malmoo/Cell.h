//
//  Cell.h
//  ExpansionTableViewByZQ
//
//  Created by 郑 琪 on 13-2-26.
//  Copyright (c) 2013年 郑 琪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
- (void)changeArrowWithUp:(BOOL)up;
@end
