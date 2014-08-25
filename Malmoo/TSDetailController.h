//
//  TSDetailController.h
//  Pods
//
//  Created by folse on 3/15/14.
//
//

#import <UIKit/UIKit.h>
#import "BTGlassScrollView.h"

@interface TSDetailController : UITableViewController<UIScrollViewAccessibilityDelegate>

@property (nonatomic,strong) TSPlace *place;

@end
