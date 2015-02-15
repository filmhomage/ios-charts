//
//  EGMBubbleView.m
//  newgraph
//
//  Created by Ivan Schuetz on 05/10/14.
//  Copyright (c) 2014 eGym. All rights reserved.
//

#import "EGMBubbleView.h"

//src http://stackoverflow.com/a/17056519/930450 (modified)
@interface EGMBubbleView()

@end

@implementation EGMBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context=UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, .5f);
//    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    
    CGRect rrect = CGRectInset(rect, 10, 20);
    CGFloat radius = 0;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGMutablePathRef outlinePath = CGPathCreateMutable();
        
    CGPathMoveToPoint(outlinePath, nil, midx, miny);
    CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius);
    
    CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);

    CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius);
    
    CGPathCloseSubpath(outlinePath);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0,1), 1, [UIColor lightGrayColor].CGColor);
    CGContextAddPath(context, outlinePath);
    CGContextFillPath(context);
    
    CGContextAddPath(context, outlinePath);
    CGContextClip(context);

    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
