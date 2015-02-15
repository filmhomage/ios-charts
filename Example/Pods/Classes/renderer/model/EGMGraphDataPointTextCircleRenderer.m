//
//  EGMGraphDataPointTextCircleRenderer.m
//  newgraph
//
//  Created by Ivan Schuetz on 04/10/14.
//  Copyright (c) 2014 eGym. All rights reserved.
//

#import "EGMGraphDataPointTextCircleRenderer.h"
#import "EGMBubbleView.h"
#import "EGMGraphView.h"

@interface EGMGraphDataPointTextCircleRenderer()
@property (nonatomic, strong) UILabel *circleLabel;
@property (nonatomic, assign) CGAffineTransform labelOriginalTransform;

@property (nonatomic, strong) UILabel *infoView;

@property (nonatomic, strong) UIView *bubbleView;
@end

@implementation EGMGraphDataPointTextCircleRenderer

- (instancetype)initWithPointPx:(CGPoint)pointPx dataPoint:(EGMGraphDataPoint *)dataPoint {
    self = [super initWithPointPx:pointPx dataPoint:dataPoint];
    if (self) {
    }
    return self;
}

- (void)onRender:(CGContextRef)context graph:(EGMGraphView *)graph {
}

- (void)onAddOverlays:(EGMGraphView *)graph {
    
    float w = 50;
    float h = 50;
    
    CGRect frame = CGRectMake(0, self.pointPx.y, 0, 0);
    self.circleLabel = [[UILabel alloc] initWithFrame:frame];
    self.circleLabel.textColor = [UIColor blackColor];
    self.circleLabel.text = [self.dataPoint getText];
    self.circleLabel.font = [UIFont systemFontOfSize:18];
    self.circleLabel.layer.cornerRadius = 24;
    self.circleLabel.layer.borderWidth = 2;
    self.circleLabel.textAlignment = NSTextAlignmentCenter;
    self.circleLabel.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.labelOriginalTransform = self.circleLabel.transform;
    
    UIColor *c = [UIColor colorWithRed: 1
                                  green: 1
                                   blue: 1
                                  alpha: 0.85];
    self.circleLabel.layer.backgroundColor = c.CGColor;
    
    [graph addSubview:self.circleLabel];
    
    
    
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:0 animations:^{

                        CGRect frame = CGRectMake(self.pointPx.x - w/2, self.pointPx.y - h/2, w, h);
                        self.circleLabel.frame = frame;
                        
                        }
                     completion:^(BOOL finished) {
                     }];

}

- (void)cleanup {
    [self.circleLabel removeFromSuperview];
}

- (BOOL)contains:(CGPoint)pointPx {
    return CGRectContainsPoint(self.circleLabel.frame, pointPx);
}

- (void)touchesEnded:(CGPoint)touchPoint graph:(UIView *)graph {
    CGFloat w = 250;
    CGFloat h = 100;
    CGRect frame = CGRectMake(self.pointPx.x - w/2, self.pointPx.y - (h + 12), w, h);

    
    self.bubbleView = [[EGMBubbleView alloc] initWithFrame:frame];
    [graph addSubview:self.bubbleView];
    self.bubbleView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0, 0), CGAffineTransformMakeTranslation(0, 100));

    
    self.infoView = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, w, h - 30)];
    self.infoView.textColor = [UIColor blackColor];
    self.infoView.text = [NSString stringWithFormat: @"Some text about %@", self.dataPoint.getText];
    self.infoView.font = [UIFont systemFontOfSize:18];

    self.infoView.textAlignment = NSTextAlignmentCenter;

    [self.bubbleView addSubview:self.infoView];


    [UIView animateWithDuration:0.2
                          delay:0
                        options:0 animations:^{
                            self.circleLabel.textColor = [UIColor whiteColor];
                            self.circleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
                            self.circleLabel.layer.backgroundColor = [UIColor blackColor].CGColor;
                            self.bubbleView.transform = CGAffineTransformIdentity;
                        }
                     completion:^(BOOL finished) {
                     }];
}

- (void)clearTouch:(EGMGraphView *)graph {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:0 animations:^{
                            self.circleLabel.textColor = [UIColor blackColor];
                            self.circleLabel.layer.borderColor = [UIColor grayColor].CGColor;
                            self.circleLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
                        }
                     completion:^(BOOL finished) {
                     }];
    [self.bubbleView removeFromSuperview];
}


@end
