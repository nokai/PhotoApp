//
//  CustomizedCell.m
//  assignment3
//
//  Created by Ninglin Li on 7/24/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import "CustomizedCell.h"
#import "HomeViewController.h"

@implementation CustomizedCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.refreshButton.userInteractionEnabled = NO;
        self.deleteButton.userInteractionEnabled = NO;
    }
    return self;
}

@end
