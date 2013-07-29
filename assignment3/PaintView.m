//
//  PaintView.m
//  Paint
//
//  Created by T. Andrew Binkowski on 4/30/13.
//  Copyright (c) 2013 T. Andrew Binkowski. All rights reserved.
//

#import "PaintView.h"
#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define BEZIER_TYPE 1

@interface PaintView ()
@property CGMutablePathRef trackingPath;

@property (strong, nonatomic) NSMutableArray *strokes;
@property (strong, nonatomic) UIBezierPath *path;

@property CGRect trackingDirty;
@property CGSize shadowSize;
@property CGFloat shadowBlur;
@property CGFloat lineWidth;

@property (strong, nonatomic) NSMutableArray *previousPaths;
@property (strong, nonatomic) NSMutableArray *previousColors;
@end

////////////////////////////////////////////////////////////////////////////////
@implementation PaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupDefaultPaintStyles];
        self.backgroundColor = [UIColor clearColor];
        _strokes = [[NSMutableArray alloc] initWithCapacity:10];
    }

    return self;
}

- (void)setupDefaultPaintStyles
{
    self.lineWidth = 20;
    self.lineColor = [UIColor greenColor];
    self.shadowSize = (CGSize) {10,10},
    self.shadowBlur = 5;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_trackingPath == NULL) {
        _trackingPath = CGPathCreateMutable();
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPathMoveToPoint(_trackingPath, NULL, point.x, point.y);
    
    
    ////////////////////////////////////////////////////////////////////////////
    // BezierPath
    UITouch *touch = [touches anyObject];
    
    self.path = [UIBezierPath bezierPath];
	self.path.lineWidth = 10;
    self.path.lineCapStyle = kCGLineCapRound;
    self.path.lineJoinStyle = kCGLineJoinRound;
	[self.path moveToPoint:[touch locationInView:self]];
    
    // Create the arrays to hold the values
    [self.strokes addObject:self.path];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Add the new path to the point
    CGPoint prevPoint = CGPathGetCurrentPoint(_trackingPath);
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPathAddLineToPoint(_trackingPath, NULL, point.x, point.y);
    
    CGRect dirty = [self segmentBoundsFrom:prevPoint to:point];
    
    //[self setNeedsDisplay];
    //[self setNeedsDisplayInRect:dirty];
    
    
    // Keep track of the cumulative "dirty" rectangle
    _trackingDirty = CGRectUnion(dirty, _trackingDirty);
   
    
    UITouch *touch = [touches anyObject];
    [[self.strokes lastObject] addLineToPoint:[touch locationInView:self]];
    //[self setNeedsDisplay];
    [self setNeedsDisplayInRect:dirty];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

     [_previousPaths addObject:(__bridge id)_trackingPath];
    [_previousColors addObject:self.lineColor];
    CGPathRelease(_trackingPath);
    _trackingPath = NULL;

    [self.delegate paintView:self finishedTrackingPath:_trackingPath inRect:_trackingDirty];

    
    //
	UITouch *touch = [touches anyObject];
    // Update the last one
    [[self.strokes lastObject] addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
    //[self setNeedsDisplayInRect:CGRectUnion(self.firstTouch,self.lastTouch)];
    
    [self.delegate paintView:self finishedTrackingPath:_trackingPath inRect:_trackingDirty];
}


 - (void)drawRect:(CGRect)rect
 {
//     CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
     for (int i=0; i < [self.strokes count]; i++) {
         //for (UIBezierPath *tmp in self.strokes)
         UIBezierPath *tmp = (UIBezierPath*)[self.strokes objectAtIndex:i];
         [[UIColor grayColor] set];
         [tmp stroke];
     }
//     NSLog(@"%2.2fms", 1000.0*(CFAbsoluteTimeGetCurrent() - startTime));
     
 }


/*******************************************************************************
 * @method          <# method #>
 * @abstract        <# abstract #>
 * @description     <# description #>
 *******************************************************************************/
- (void)setPaintStyleInContext:(CGContextRef)context withColor:(UIColor*)color
{

    //CGContextSetShadowWithColor(context, self.shadowSize, self.shadowBlur, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    //}
}

- (void)erase {
    //[self imageRepresentation];
    [_previousPaths removeAllObjects];
    [_previousColors removeAllObjects];

    if (_trackingPath) {
        CGPathRelease(_trackingPath);
        _trackingPath = NULL;
        _trackingDirty = CGRectNull;
    }
    //[self setNeedsDisplay];

    // Bezier Path 
    // Remove all the strokes and clear the arrays
    [self.path removeAllPoints];
    [self.strokes removeAllObjects];

    [self setNeedsDisplay];
}

- (CGRect)segmentBoundsFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
    CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
    return CGRectUnion(dirtyPoint1, dirtyPoint2);
}

@end
