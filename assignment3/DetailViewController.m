//
//  DetailViewController.m
//  assignment3
//
//  Created by Ninglin Li on 5/10/13.
//  Copyright (c) 2013 Ninglin_Li. All rights reserved.
//

#import "DetailViewController.h"
#import "ILSideScrollViewItem.h"
#import "DetailInfoViewController.h"
#import <Social/Social.h>


@interface DetailViewController ()

@end

@implementation DetailViewController{
    NSMutableArray *items;
    UIImage * addImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.targetImage setImage:self.passedImage];
    
    // setup scroller for filter
    self.scroller = [[ILSideScrollView alloc] initWithFrame:CGRectMake(0, 335, 320, 90)];
    [self.scroller setBackgroundColor:[UIColor grayColor] indicatorStyle:UIScrollViewIndicatorStyleWhite itemBorderColor:[UIColor grayColor]];
    [self.view addSubview:self.scroller];
    [self setScrollView];

    // enable draw on targetImage
    self.targetImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *oneTouch=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagToAddImage:)];
    
    [oneTouch setNumberOfTouchesRequired:1];
    [self.targetImage addGestureRecognizer:oneTouch];
    
    //setup button controller 
    [self setUpButtonSetOnTop];
}
// setup button set show on the top of targetView by click on the add button which is in the upper left conner
-(void)setUpButtonSetOnTop{
    UIButton *cloudButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cloudButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchDown];
    UIImageView *cloudIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cloudIcon setImage:[UIImage imageNamed:@"save.png"]];
    [cloudButton addSubview:cloudIcon];

    UIButton *drawButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [drawButton addTarget:self action:@selector(draw) forControlEvents:UIControlEventTouchDown];
    UIImageView *drawIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [drawIcon setImage:[UIImage imageNamed:@"pen.png"]];
    [drawButton addSubview:drawIcon];
    
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchDown];
    UIImageView *infoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [infoIcon setImage:[UIImage imageNamed:@"information.png"]];
    [infoButton addSubview:infoIcon];
    
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [facebookButton addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchDown];
    UIImageView *facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [facebookIcon setImage:[UIImage imageNamed:@"facebook500.png"]];
    [facebookButton addSubview:facebookIcon];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [saveButton addTarget:self action:@selector(saveToPhotoLibrary) forControlEvents:UIControlEventTouchDown];
    UIImageView *saveIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [saveIcon setImage:[UIImage imageNamed:@"library.png"]];
    [saveButton addSubview:saveIcon];
    
       
    self.sideMenu = [[HMSideMenu alloc] initWithItems:@[cloudButton,drawButton,infoButton,facebookButton,saveButton]];
    [self.sideMenu setItemSpacing:5.0f];
    [self.view addSubview:self.sideMenu];
}

#pragma mark - all button methods
- (void)draw {
    // Create a painting view smaller than targetview
    _paintView = [[PaintView alloc] initWithFrame:CGRectMake(8, 40, 305, 294)];
    self.paintView.lineColor = [UIColor grayColor];
    self.paintView.delegate = self;
    [self.view addSubview:self.paintView];
    self.shouldMerge = NO;
}

// infobutton show instruction of the detaile view
- (void)showInfo {
    DetailInfoViewController *controller = [[DetailInfoViewController alloc] init];
    [controller presentInParentViewController:self];
}

// share via facebook
- (void)facebook{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController * controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller addImage:self.targetImage.image];
        [self.navigationController pushViewController:controller animated:NO];
    }
}

-(void)saveImage{
    //save self.targetImage.image to Parse
    NSData* imageData = nil;
    if (self.paintView != nil ) {
        NSLog(@"save paintview");
        CGRect rect = self.targetImage.bounds;
        
        [self mergePaintToBackgroundView:rect];
        imageData = [NSData dataWithData:UIImagePNGRepresentation(self.targetImage.image)];
    }else {
        NSLog(@"no paintview");
        imageData = [NSData dataWithData:UIImagePNGRepresentation(self.targetImage.image)];
    }
    [self addObjectToParse:imageData];
}

// save an image of both targetImage and drawing to photo library
- (void)saveToPhotoLibrary{
    if (self.paintView != nil ) {
        NSLog(@"save paintview");
        CGRect rect = self.targetImage.bounds;
        [self mergePaintToBackgroundView:rect];
    }else {
        NSLog(@"no paintview");
    }
    UIImageWriteToSavedPhotosAlbum( self.targetImage.image, nil, nil, nil );
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Saved" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}
// click the add button in upper right conner to show button set
// and click again to dismiss the button set
- (IBAction)addSomething:(id)sender {
    //the button that brings the items into view was pressed
    if (self.sideMenu.isOpen) {
        [self.sideMenu close];
    }else{
        [self.sideMenu open];
    }
}

#pragma mark scrolView and filter
- (void)setScrollView{
//    resize image and show in thumbnail image
    
    CGSize destinationSize = CGSizeMake(80.0, 80.0);
    UIGraphicsBeginImageContext(destinationSize);
    [self.passedImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *image0 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *image1 = [self sepia:image0];
    UIImage *image2 = [self blackAndWhite:image0];
    UIImage *image3 = [self exploseAddress:image0];
    UIImage *image4 = [self blurImage:image0];

    self.filterImages = [[NSArray alloc] initWithObjects:image0, image1, image2, image3, image4, nil];
    items = [NSMutableArray array];
    
    for ( int i = 0; i < 5; i++ ) {
        ILSideScrollViewItem *item = [ILSideScrollViewItem item];
        item.defaultBackgroundImage = [self.filterImages objectAtIndex:i];
        [item setTarget:self action:@selector(showFilterEffect:) withObject:item];
        [items addObject:item];
    }
    [self.scroller populateSideScrollViewWithItems:items];
}

// show filter effect on targetImageView
-(void)showFilterEffect:(ILSideScrollViewItem *)item{
    NSInteger index = [items indexOfObject:item ];
    if( index == 0){
        self.targetImage.image =self.passedImage;
    } else if (index == 1) {
        self.targetImage.image = [self sepia:self.passedImage];
    }else if( index == 2  ){
        self.targetImage.image = [self blackAndWhite:self.passedImage];
    }else if( index == 3 ){
        self.targetImage.image = [self exploseAddress:self.passedImage];
    }else if(index == 4){
        self.targetImage.image = [self blurImage:self.passedImage];
    }
}

#pragma mark filter implementation
- (UIImage*)sepia:(UIImage*)originalImage{
    CIImage *beginImage = [[CIImage alloc] initWithImage:originalImage];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", @0.8, nil];
    CIImage *outputImage = [filter outputImage];
   
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
     UIImage *filteredImage = [UIImage imageWithCGImage:cgimg];
    return filteredImage;
}
//show black and white effect
- (UIImage*)blackAndWhite:(UIImage*)originalImage{

    CIImage *beginImage = [[CIImage alloc] initWithImage:originalImage];
    
    CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
    CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", [NSNumber numberWithFloat:0.7], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *filteredImage = [UIImage imageWithCGImage:cgiimage];
    
    CGImageRelease(cgiimage);
    
    return filteredImage;

}
//show exposed addressed effect
-(UIImage*)exploseAddress:(UIImage*)originalImage{
    CIImage *beginImage = [[CIImage alloc] initWithImage:originalImage];
    CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureAdjustmentFilter setDefaults];
    [exposureAdjustmentFilter setValue:beginImage forKey:@"inputImage"];
    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:0.4f] forKey:@"inputEV"];
    CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *filteredImage = [UIImage imageWithCGImage:cgimg];
    return filteredImage;
}
//show blur effect on image
-(UIImage*)blurImage:(UIImage*)originalImage{
    CIImage *beginImage = [[CIImage alloc] initWithImage:originalImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputRadius", [NSNumber numberWithFloat:1.0], nil];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result
                                       fromRect:[result extent]];

    UIImage *filteredImage = [UIImage imageWithCGImage:cgImage];
    return filteredImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark paintView
//merge paint view with targetView
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted
{
    if (self.shouldMerge) {
        [self mergePaintToBackgroundView:painted];
    }
}

/*******************************************************************************
 * @method          mergePaintToBackgroundView
 * @abstract        Combine the last painted image into the current background image
 * @description
 *******************************************************************************/
- (void)mergePaintToBackgroundView:(CGRect)painted
{
    // Create a new offscreen buffer that will be the UIImageView's image
    CGRect bounds = self.targetImage.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.targetImage.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Copy the previous background into that buffer.  Calling CALayer's renderInContext: will redraw the view if necessary
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self.targetImage.layer renderInContext:context];
    
    // Now copy the painted contect from the paint view into our background image
    // and clear the paint view.  as an optimization we set the clip area so that we only copy the area of paint view
    // that was actually painted
    CGContextClipToRect(context, painted);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self.paintView.layer renderInContext:context];
    [self.paintView erase];
    
    // Create UIImage from the context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.targetImage.image = image;
    UIGraphicsEndImageContext();
    
    // Save the image to the photolibrary
    NSData *data = UIImagePNGRepresentation(image);
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
    
    // Save the image to the photolibrary in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = UIImagePNGRepresentation(image);
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"\n>>>>> Done saving in background...");//update UI here
        });
    });
}
// upload photo to parse
-(void)addObjectToParse:(NSData *) imageData {
    PFObject *object = [PFObject objectWithClassName:@"images"];
    PFFile *imageFile = [PFFile fileWithData:UIImagePNGRepresentation(self.targetImage.image)];
   
    [object setObject:imageFile forKey:@"image"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * username = [defaults objectForKey:@"userName"];
    [object setObject:username forKey:@"userName"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
//            [self refresh];
            NSLog(@"save object %@", object);
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

// add subview to target image view
- (IBAction)tagToAddImage:(UITapGestureRecognizer *)sender {
    CGPoint locationInView = [sender locationInView:self.view];
    NSLog(@"\ntap location: x:%5.2f y:%5.2f",locationInView.x,locationInView.y);
    UIImageView * addView = [[UIImageView alloc] initWithImage:addImage];
    addView.userInteractionEnabled = YES;
    [self.view addSubview:addView];
}



@end
