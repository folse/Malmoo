//
//  TSDetailControllerView.m
//  Malmoo
//
//  Created by Jennifer on 8/26/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "TSDetailControllerView.h"

@implementation TSDetailControllerView

- (id)init
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TSDetailControllerView" owner:self options:nil];
    self = [nib objectAtIndex:0];
    if (self) {
        // Custom initialization
        
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

}

@end
