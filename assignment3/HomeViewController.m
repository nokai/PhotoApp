//
//  HomeViewController.m
//  assignment3
//
//  Created by Ninglin Li on 5/10/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import "LabelViewController.h"
#import "CustomizedCell.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

//get username from NSUserDefault
//if username not set, get username from user
//else user's fetch photo from parse
- (void)viewWillAppear:(BOOL)animated{
//    check internet before load image
    [self checkInternet];
    self.images = [[NSMutableArray alloc] init];
    self.swipeCell = NO;
    self.objectsArray = [[NSArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults objectForKey:@"userName"];
//    NSLog(@"user name %@", self.username);
    if ( self.username == nil ) {
        [self getUsername];
    } else {
        [self refresh];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}


# pragma mark collection view
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.objectsArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // init CustomizedCell and disable refreshButton and deleteButton at first
    static NSString *identifier = @"CustomizedCell";
    CustomizedCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor whiteColor];
    if (self.swipeCell == NO ) {
        cell.refreshButton.userInteractionEnabled = NO;
        cell.deleteButton.userInteractionEnabled = NO;
        cell.UserImageView.hidden = NO;
    }
    // get photo from self.objectsArray
    UIImageView *userPhoto = cell.UserImageView;
    PFFile *theImage = [[self.objectsArray objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSData *imageData = [theImage getData];
    userPhoto.image = [UIImage imageWithData:imageData];
    
//    add swipe gesture recognizer to cell
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [cell addGestureRecognizer:recognizer];
    return cell;
}

//if user swipe to the right, this method activate
- (void)swipe:(UISwipeGestureRecognizer*)srecognizer{
    // if user swipe to the right and gesture end, get the NSIndexPath to find out which cell is the user touched
    if(srecognizer.state == UIGestureRecognizerStateEnded){
        self.swipeCell = YES;
        CGPoint swipeLocatoin = [srecognizer locationInView:self.collectionView];
        NSIndexPath *swipeIndexPath = [self.collectionView indexPathForItemAtPoint:swipeLocatoin];
        self.selectedIndexPath = swipeIndexPath;
        CustomizedCell * cell = (CustomizedCell*)[self.collectionView cellForItemAtIndexPath:swipeIndexPath];
        if (self.swipeCell == YES) {
            // if the cell received swipe to the right gusture, change background image and enable deletebutton and refreshButton
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black.png"]];
            cell.UserImageView.hidden = YES;
            cell.deleteButton.userInteractionEnabled = YES;
            cell.refreshButton.userInteractionEnabled = YES;
            NSLog(@"swipe");
        }else{
            cell.UserImageView.hidden = NO;
            cell.deleteButton.userInteractionEnabled = NO;
            cell.refreshButton.userInteractionEnabled = NO;
        }
    }
}
//if user choose one cell, go to detailview which edit this image
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [[segue identifier] isEqualToString:@"DetailViewSegue"] ){
        CustomizedCell* cell = (CustomizedCell *)sender;
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathForCell:cell];
        NSLog(@"%d", selectedIndexPath.row);
        DetailViewController * detailViewController = [segue destinationViewController];
        detailViewController.passedImage = [self.images objectAtIndex:selectedIndexPath.row];
    }
}

#pragma mark set username
// get username if it is the first time this user use this app
-(void)getUsername{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter your name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"Enter your name";
    textField.keyboardType = UIKeyboardTypeNamePhonePad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField * textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        self.username = textField.text;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.username forKey:@"userName"];
        // Send query to parse
        [self loadImageFromParse];
    }
}


#pragma mark parse
-(void)loadImageFromParse{
    PFQuery *query = [PFQuery queryWithClassName:@"images"];
    
    [query whereKey:@"userName" equalTo:self.username];
    [query orderByAscending:@"createdAt"];
//    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if( !error){
            self.count = objects.count;
            self.objectsArray = objects;
            for (PFObject * theObject in objects) {
                PFFile *theImage = [theObject objectForKey:@"image"];
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    NSData *imageData = data;
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self.images addObject: image];
                }];
            }
        }
        else{
            NSLog(@"Error: %@, %@", error, [error userInfo]);
        }
        [self.collectionView reloadData];
    }];
   
}

// load image to parse
-(void)addObjectToParse:(NSData *) imageData {
    PFObject *object = [PFObject objectWithClassName:@"images"];
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [object setObject:imageFile forKey:@"image"];
    [object setObject:self.username forKey:@"userName"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self refresh];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)setUpImages:(NSArray *)images{
    // This method sets up the downloaded images and places them nicely in a grid
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.images = [NSMutableArray array];
        // Iterate over all images and get the data from the PFFile
        for (int i = 0; i < images.count; i++) {
            PFObject *eachObject = [images objectAtIndex:i];
            PFFile *theImage = [eachObject objectForKey:@"image"];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            [self.images addObject:image];
        }
    });
}
// delete image from parse
- (void)deleteImageFromParse:(NSIndexPath*) indexPath{
    PFObject *object = [self.objectsArray objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
        [self.images removeObjectAtIndex:indexPath.row];
        [self loadImageFromParse];
        [self.collectionView reloadData];
    }];
    self.swipeCell = NO;
}

// refresh data in collectionview
-(void)refresh{
    [self loadImageFromParse];
    [self.collectionView reloadData];
    self.swipeCell = NO;
}

// delete thsi image from parse when user press delete button
- (IBAction)deleteImage:(id)sender {
    [self deleteImageFromParse:self.selectedIndexPath];
}
// refresh all images when user press refresh button
- (IBAction)refreshData:(id)sender {
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark get photo from library or camera
// add image from camera or photo library
- (IBAction)addImage:(id)sender {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle: @"Please choose your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: nil otherButtonTitles:@"Photo library", @"Take a picture", nil];
    [actSheet showInView:[UIApplication sharedApplication].keyWindow];
}

// actionSheet delegate, if user press "Photo library", go to open photo library
// if user press "Take a picture", open camera
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Photo library"]) {
//        NSLog(@"Photo library button in actionSheet is pressed ");
        [self photoAlbur];
    }else if ([buttonTitle isEqualToString:@"Take a picture"]) {
//        NSLog(@"Take a picture button in actionSheet is pressed");
        [self photoCamera];
    }else if([buttonTitle isEqualToString:@"Cancel"]){
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    }
}
// choose image from photo library
-(void)photoAlbur{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        // tell the UIImagePickerController to send messages to this view controller
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // show image picker on the screen
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error accessing photo library"
                              message:@"Device does not support a photo library"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}
//choose image by taking photo
-(void)photoCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"Image picker was presented");}
         ];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Sorry"
                              message:@"Device does not support camera"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //Get picked image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
   
    //resize image to be suitable for a 305 * 305 frame
    CGSize destinationSize = CGSizeMake(305, 305);
    UIGraphicsBeginImageContext(destinationSize);
    [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"new image size: width is: %f, height is %f", newImage.size.width, newImage.size.height);
    
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(newImage)];
    // save image to parse
    [self addObjectToParse: imageData];
    
    // Take image picker off the screen
    [[self presentedViewController] dismissViewControllerAnimated:YES completion:^{}];
    
}

// show instruction for this app
- (IBAction)getInstruction:(id)sender {
    LabelViewController *controller = [[LabelViewController alloc] init];
    [controller presentInParentViewController:self];
}

//check if internet is available
-(void) checkInternet{
    Reachability *network = [Reachability reachabilityForInternetConnection];
    NetworkStatus newtworkStatus = [network currentReachabilityStatus];
    if (newtworkStatus == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"It seems you have no connection to the internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
