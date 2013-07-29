//
//  DetailViewController.h
//  assignment3
//
//  Created by Ninglin Li on 5/10/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSideScrollView.h"
#import <Parse/Parse.h>
#import "PaintView.h"
//#import "ALRadialButton.h"
//#import "ALRadialMenu.h"
#import "HMSideMenu.h"

@interface DetailViewController : UIViewController<PaintViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *targetImage;
@property (strong, nonatomic) UIImage* passedImage;
@property (strong, nonatomic) NSArray * filterImages;
@property (strong, nonatomic) ILSideScrollView *scroller;
@property (strong, nonatomic) PaintView * paintView;
@property BOOL shouldMerge;


@property (weak, nonatomic) IBOutlet UIButton *addButton;
//@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property(strong, nonatomic) HMSideMenu *sideMenu;
@property (strong, nonatomic) NSArray *popups;
- (IBAction)addSomething:(id)sender;


//- (IBAction)shareImage:(id)sender;
- (IBAction)tagToAddImage:(UITapGestureRecognizer *)sender;




@end
