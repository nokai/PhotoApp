// Refer to Andrew Rosenblum's AJNutrtionController


#import "DetailInfoViewController.h"
#import "LabelView.h"
#import "Background.h"
//#import "AJRNutritionLabelCalculation.h"

@interface DetailInfoViewController () {
    IBOutlet LabelView *backgroundView;
    Background *backgroundGradientView;
    IBOutlet UILabel *fatDailyValueLabel;
    IBOutlet UILabel *carbDailyValueLabel;
}

@end

@implementation DetailInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"DetailViewInfo" bundle:nibBundleOrNil];
    if (self) {
        self.shouldDimBackground = YES;
        self.shouldAnimateOnAppear = YES;
        self.shouldAnimateOnDisappear = YES;
        self.allowSwipeToDismiss = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Sets up the background of the nutrition view
    backgroundView.layer.cornerRadius = 10.0f;
    backgroundView.layer.masksToBounds = YES;
    backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    backgroundView.layer.borderWidth = 4.5f;
    
    if (self.allowSwipeToDismiss) {
        //Add a swipe gesture recognizer to dismiss the view
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        [self.view addGestureRecognizer:recognizer];
    }
}

- (void)presentInParentViewController:(UIViewController *)parentViewController {
    //Presents the view in the parent view controller
    
    if (self.shouldDimBackground == YES) {
        //Dims the background, unless overridden
        backgroundGradientView = [[Background alloc] initWithFrame:parentViewController.view.bounds];
        [parentViewController.view addSubview:backgroundGradientView];
    }
    
    //Adds the nutrition view to the parent view, as a child
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    
    //Adds the bounce animation on appear unless overridden
    if (!self.shouldAnimateOnAppear)
        return;
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.7f],
                              [NSNumber numberWithFloat:1.2f],
                              [NSNumber numberWithFloat:0.9f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.334f],
                                [NSNumber numberWithFloat:0.666f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    fadeAnimation.duration = 0.1;
    [backgroundGradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self didMoveToParentViewController:self.parentViewController];
}

- (IBAction)close:(id)sender {
    //The close button
    [self dismissFromParentViewController];
}

- (void)dismissFromParentViewController {
    //Removes the nutrition view from the superview
    
    [self willMoveToParentViewController:nil];
    
    //Removes the view with or without animation
    if (!self.shouldAnimateOnDisappear) {
        [self.view removeFromSuperview];
        [backgroundGradientView removeFromSuperview];
        [self removeFromParentViewController];
        return;
    }
    else {
        [UIView animateWithDuration:0.4 animations:^ {
            CGRect rect = self.view.bounds;
            rect.origin.y += rect.size.height;
            self.view.frame = rect;
            backgroundGradientView.alpha = 0.0f;
        }
                         completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             [backgroundGradientView removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self->backgroundView = nil;
    self->carbDailyValueLabel = nil;
    self->fatDailyValueLabel = nil;
    NSLog(@"view did unload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
