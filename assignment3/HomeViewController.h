//
//  HomeViewController.h
//  assignment3
//
//  Created by Ninglin Li on 5/10/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CustomizedCell.h"
#import "Reachability.h"


@interface HomeViewController : UICollectionViewController<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSArray * objectsArray;
@property (nonatomic) NSInteger count;
@property(strong, nonatomic) NSIndexPath *selectedIndexPath;
@property(nonatomic) Boolean swipeCell;


- (IBAction)addImage:(id)sender;
- (IBAction)getInstruction:(id)sender;
- (void) refresh;
- (IBAction)deleteImage:(id)sender;
- (IBAction)refreshData:(id)sender;

@end
