//
//  CustomizedCell.h
//  assignment3
//
//  Created by Ninglin Li on 7/24/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomizedCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *UserImageView;

@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end
