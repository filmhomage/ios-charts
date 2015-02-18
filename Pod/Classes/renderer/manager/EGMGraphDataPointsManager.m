//
//  EGMGraphDataPointsManager.m
//  TrainerApp
//
//  Created by Ivan Schuetz on 18/09/14.
//  Copyright (c) 2014 eGym. All rights reserved.
//

#import "EGMGraphDataPointsManager.h"
#import "EGMGraphDataPointRectTextRenderer.h"
#import "EGMGraphDataPointRectWithNoteTextRenderer.h"
#import "EGMGraphDataPointBarRenderer.h"
#import "EGMGraphAxisRenderer.h"
#import "EGMGraphUtils.h"
#import "EGMGraphView.h"
#import "EGMGraphRectConflictSolver.h"

@interface EGMGraphDataPointsManager()
@property (nonatomic, strong) NSArray *dataPoints;
@property (nonatomic, assign) CGFloat minYSpacing;

@end

@implementation EGMGraphDataPointsManager


- (NSArray *)generateDataPointRenderers:(NSArray *)dataPoints xAxis:(EGMGraphAxisRenderer *)xAxis yAxis:(EGMGraphAxisRenderer *)yAxis xAxisValues:(NSArray *)xAxisValues yAxisValues:(NSArray *)yAxisValues graph: (EGMGraphView *)graph {
    
    NSMutableArray *dataPointRenderers = [NSMutableArray array];
    
    for (int i = 0; i < [dataPoints count]; i++) {
        EGMGraphDataPoint *dataPoint = dataPoints[i];
        
        CGFloat dataPointScalarX = [dataPoint getXValue].scalar;
        CGFloat dataPointScalarY = [dataPoint getYValue].scalar;
        
        CGFloat dataPointRectX = [xAxis getPXPositionScalar:dataPointScalarX];
        CGFloat dataPointRectY = [yAxis getPXPositionScalar:dataPointScalarY];
        
        CGPoint dataPointPx = CGPointMake(dataPointRectX, dataPointRectY);
        
        CGPoint originPx = CGPointMake([xAxis getOrigin].x, [xAxis getOrigin].y);
        
        EGMGraphDataPointRenderer *dataPointRenderer = self.dataPointRendererGenerator(dataPointPx, dataPoint, i, originPx, graph);
        if (dataPointRenderer) { //we allow the generator to return nil - then we just dont add anything
            [dataPointRenderers addObject:dataPointRenderer];
        }
    }
    
    if (dataPointRenderers.count && ([[dataPointRenderers.firstObject class] isSubclassOfClass: [EGMGraphDataPointRectRenderer class]] || [[dataPointRenderers.firstObject class] isSubclassOfClass: [EGMGraphDataPointRectWithNoteTextRenderer class]])) {
        [[[EGMGraphRectConflictSolver alloc] init] solveConflictsForDataPointRenderers:dataPointRenderers];
    }
    
    return dataPointRenderers;
}

- (CGFloat)getScalingFactorForMaxIntersection {
    CGFloat maxIntersectionHeight = FLT_MIN;
    CGFloat maxScalingFactor = FLT_MIN;
    for (EGMGraphItemRenderer *dp1 in self.itemsRenderers) {
        for (EGMGraphItemRenderer *dp2 in self.itemsRenderers) {
            if (![dp1 isEqual: dp2]) { //TODO override isEqual in EGMGraphItemRenderer - for now instance identity check is correct
                
                CGRect dp1Rect = [dp1 getRect];
                CGRect dp1RectWithMinYSpacing = CGRectInset(dp1Rect, 0, -self.minYSpacing);
                CGRect dp2Rect = [dp2 getRect];
                CGRect dp2RectWithMinYSpacing = CGRectInset(dp2Rect, 0, -self.minYSpacing);
                
                CGRect intersection = [EGMGraphUtils intersection:dp1RectWithMinYSpacing r2:dp2RectWithMinYSpacing];
                if (!CGRectIsNull(intersection)) {
                    
                    CGFloat intersectionHeight = intersection.size.height;
                    if (intersectionHeight > maxIntersectionHeight) {
                        maxIntersectionHeight = intersectionHeight;
                        
                        CGFloat height = [dp1 getRect].size.height;
                        CGFloat minSpaceBetweenCenters = height + self.minYSpacing;
                        CGFloat currentSpacingBetweenCenters = abs(dp2.pointPx.y - dp1.pointPx.y);
                        maxScalingFactor = minSpaceBetweenCenters / currentSpacingBetweenCenters;
                        
                    }
                }
            }
        }
    }
    return maxScalingFactor;
}


- (instancetype)initWithDataPoints:(NSArray *)dataPoints dataPointRendererGenerator:(EGMGraphDataPointRenderer *(^)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraphView *))dataPointRendererGenerator minYSpacing:(CGFloat)minYSpacing {
    self = [super init];
    if (self) {
        self.dataPoints = dataPoints;
        self.dataPointRendererGenerator = dataPointRendererGenerator;
        self.minYSpacing = minYSpacing;
    }
    
    return self;
}


@end
