// Refer to Andrew Rosenblum's AJNutrtionController


#import "LabelView.h"

@implementation LabelView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();           //SetUp
    
    //Sets the white color
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 1.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    
    //Release the created C objects
    //CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

- (void)drawLine:(CGContextRef)context withPoint:(CGRect)point withLineWidth:(float)width {

    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, point.origin.x, point.origin.y);
    CGContextAddLineToPoint(context, 220, point.origin.y);
    
    CGContextSetLineWidth(context, width);
    
    // and now draw the Path!
    CGContextStrokePath(context);
}
@end
