//
//  EGMGraphProvider.m
//  newgraph
//
//  Created by Ivan Schuetz on 20/09/14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "EGMGraphProvider.h"

#import "EGMGraphLabelModelManager.h"
#import "EGMGraphLabelRenderer.h"
#import "EGMGraphGuidelineManager.h"
#import "EGMGraphGuideRenderer.h"
#import "EGMGraphDataPointRenderer.h"
#import "EGMGraphDataPointRectRenderer.h"
#import "EGMGraphDataPointBarRenderer.h"
#import "EGMGraphDataPointsManager.h"
#import "EGMGraphLineManager.h"
#import "EGMGraphDataPointsLineManager.h"
#import "EGMGraphAxisRenderer.h"
#import "EGMGraphDataPointRectTextRenderer.h"
#import "EGMGraphDataPointRectWithNoteTextRenderer.h"
#import "EGMGraphDataPointsLineManager.h"
#import "EGMWeightDataPoint.h"
#import "EGMGraph.h"
#import "EGMGraphAxisValueNumber.h"
#import "EGMGraphAxisValueDate.h"
#import "EGMGraphAxisValue.h"
#import "EGMGraphAxisValueNumberFormatted.h"
#import "NSDateFormatter+EGMAdditions.h"
#import "EGMGraphLineRenderer.h"
#import "NSDate+EGMAddtions.h"
#import "EGMGraphDataPointLineRenderer.h"
#import "EGMGraphDataPointTargetingRenderer.h"
#import "EGMGraphDataPointsAreaManager.h"
#import "EGMGraphDataPointTextCircleRenderer.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end




/**
 Graph factory
 It creates graph with required components, for each graph type
 */
@implementation EGMGraphProvider


+ (EGMGraphDataPointRenderer *(^)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *)) generateDefaultLineGenerator {
    return ^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph *graph) {
        EGMGraphLineRenderer *lineModel = [[EGMGraphLineRenderer alloc] init];
        CGPoint p1 = CGPointMake(pointPx.x, [graph.xAxisModel getOrigin].y);
        CGPoint p2 = CGPointMake(pointPx.x, [graph.xAxisModel getOrigin].y - graph.yAxisModel.length);
        [lineModel setP1:p1 p2:p2 color:[UIColor grayColor]];
        EGMGraphDataPointLineRenderer *dataPointLineModel = [[EGMGraphDataPointLineRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint lineModel:lineModel];
        return dataPointLineModel;
    };
}

+ (EGMGraphDataPointRenderer *(^)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *)) generateDefaultTextRectGenerator:(UIColor *)bgColor {
    return ^EGMGraphDataPointRenderer * (CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph * graph) {
        EGMGraphDataPointRenderer *model = [[EGMGraphDataPointRectTextRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint rectSize:CGSizeMake(80, 40) color:bgColor cornerRadius:18 textColor:[UIColor whiteColor] textFont:[UIFont fontWithName:@"Arial" size:16]];
        return model;
    };
}

/**
 Helper to reduce boilerplate when creating a graph
 */
+ (EGMGraph *)createGraphInstanceWithDefaultSettings:(CGRect)frame {
    EGMGraph *graph = [[EGMGraph alloc] initWithFrame:frame];
    
    graph.minSegmentCountY = 5.0;
    graph.maxSegmentCountY = 20.0;
    graph.segmentSizeMultY = 500;
    graph.segmentCountY = 5.0;
    
    graph.paddingLeft = 10;
    graph.paddingTop = 50;
    graph.paddingRight = 50;
    graph.paddingBottom = 10;


    graph.spacingLabelAxisX = 10;
    graph.spacingLabelAxisY = 20;
    graph.verticalAxisXLabels = YES;
    graph.dividerLength = 20; //FIXME disabling this hides guides, this should not happen
    
    graph.labelsFont = [UIFont fontWithName:@"Arial" size:16];
    graph.labelsFontColor = [UIColor blackColor];
    graph.axisLabelsFont = [UIFont fontWithName:@"Arial" size:14];
    graph.axisLabelsFontColor = [UIColor grayColor];
    graph.guideLinesColor = [UIColor grayColor];
    
    EGMGraphGuidelineManager *guidesManagerY = [[EGMGraphGuidelineManager alloc] init];
    //    graph.guidesManagerX = guidesManagerX;
    graph.guidesManagerY = guidesManagerY;
    
    graph.segmentSizePxY = 60;

    return graph;
}

+ (EGMGraph *)getBarsChart:(NSArray *)dataPoints frame:(CGRect)frame timeRange:(NSInteger)timeRange resizeBlock:(void(^)(CGSize))resizeBlock {
    
    NSArray *daysFromTodayArr = [NSArray arrayWithObjects:
                                 [NSNumber numberWithInt: -12],
                                 [NSNumber numberWithInt: -9],
                                 [NSNumber numberWithInt: -6],
                                 [NSNumber numberWithInt: -3],
                                 [NSNumber numberWithInt: -0], nil];

    NSMutableArray *xDates = [NSMutableArray array];
    for (NSNumber *daysFromToday in daysFromTodayArr) {
        NSDate *date = [NSDate daysFromToday:[daysFromToday intValue]];
        [xDates addObject:date];
    }
    
    NSDate *firstDate = xDates[0];
    NSDate *lastDate = xDates[[xDates count] - 1];
    

    CGFloat minDateTimeStap = [firstDate timeIntervalSince1970];
    CGFloat maxDateTimeStap = [lastDate timeIntervalSince1970];
    NSMutableArray *dataPointsInRange = [NSMutableArray array];
    for (EGMGraphDataPoint *dataPoint in dataPoints) {
        CGFloat dataPointScalar = [[dataPoint getXValue] getScalar];
        if (dataPointScalar >= minDateTimeStap && dataPointScalar <= maxDateTimeStap) {
            [dataPointsInRange addObject:dataPoint];
        }
    }
    
    //add padding dates
    [xDates insertObject: [NSDate dateWithTimeInterval:-86400 sinceDate:firstDate] atIndex:0];
    [xDates addObject: [NSDate dateWithTimeInterval:86400 sinceDate:lastDate]];
    
    //generate xValues for dates
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
    [formatter setDateFormat:@"dd'.'MM'.'yyyy"];
    NSMutableArray *xValues = [NSMutableArray array];
    for (NSDate *xDate in xDates) {
        EGMGraphAxisValueDate *xValue = [[EGMGraphAxisValueDate alloc] initWithDate:xDate formatter:formatter];
        [xValues addObject:xValue];
    }
    
    // hidde padding dates
    [xValues[0] setIsHidden:YES];
    [xValues[[xValues count] - 1] setIsHidden:YES];
    
    EGMGraphDataPointsLineManager *dataPointsTrackerManager = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPoints dataPointModelGenerator:^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph * graph) {
        EGMGraphDataPointRenderer *model =  [[EGMGraphDataPointRectRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint rectSize:CGSizeMake(1, 1) color:[UIColor blackColor] cornerRadius:0];
        return model;
    } minYSpacing:10 lineColor:[UIColor blackColor] animDuration:1 animDelay:2 hasTracker:YES];
    

    EGMGraphDataPointRenderer *(^dataPointModelGenerator)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *) = ^EGMGraphDataPointRenderer * (CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph *graph) {
        EGMGraphDataPointRenderer *model = [[EGMGraphDataPointBarRenderer alloc] initWithPointPx:pointPx dataPoint: dataPoint rect:[EGMGraphDataPointBarRenderer getRectForPoint:pointPx barWidth:30 origin:originPx axis:1]];
        return model;
    };
    

    EGMGraphDataPointsManager *dataPointsManager = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPointsInRange dataPointRendererGenerator:dataPointModelGenerator minYSpacing:10];
    
    EGMGraph *graph = [self createGraphInstanceWithDefaultSettings:frame];
    graph.dataPointsManagers = [NSArray arrayWithObjects: dataPointsManager,
                                dataPointsTrackerManager,
                                nil];
    graph.axisValuesX = xValues;
    graph.maxSegmentCountY = 10;
    graph.axisXLabel = @"ylabel";
    graph.axisYLabel = @"xlabel";
    graph.resizeBlock = resizeBlock;

    graph.axisYValueGenerator = ^EGMGraphAxisValue *(CGFloat scalar) {
        EGMGraphAxisValue *axisValue = [[EGMGraphAxisValueNumberFormatted alloc] initWithNumber:scalar decimals:2 trim0:YES strFormat:@"%@"];
        return axisValue;
    };
    
    graph.dataPoints = dataPointsInRange;
    [graph configure];
    
    return graph;
}

+ (EGMGraph *)getTrackerChart:(NSArray *)dataPoints frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock {
    NSMutableArray *minutes = [NSMutableArray array];
    
    for (EGMGraphDataPoint *dataPoint in dataPoints) {
        EGMGraphAxisValue *minuteValue = [dataPoint getXValue];
        [minutes addObject:minuteValue];
    }
    
    EGMGraphDataPointsLineManager *dataPointsTrackerManager = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPoints dataPointModelGenerator:^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph * graph) {
        EGMGraphDataPointRenderer *model =  [[EGMGraphDataPointRectRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint rectSize:CGSizeMake(1, 1) color:[UIColor blackColor] cornerRadius:0];
        return model;
    } minYSpacing:10 lineColor:[UIColor redColor] animDuration:1 animDelay:0 hasTracker:YES];
    
    EGMGraph *graph = [self createGraphInstanceWithDefaultSettings:frame];
    
    graph.dataPointsManagers = [NSArray arrayWithObjects: dataPointsTrackerManager, nil];
    
    graph.dataPoints = dataPoints;
    graph.axisValuesX = minutes;
    graph.segmentSizeMultY = 50;
    graph.verticalAxisXLabels = NO;
    
    if ([minutes count] > 0) {
        [minutes[0] setIsHidden:YES];
    }
    
    graph.addPaddingSegmentIfEdge = NO;

    
    graph.axisXLabel = @"Time in minutes";
    graph.axisYLabel = @"Pulse";
    
    graph.resizeBlock = resizeBlock;
    
    graph.axisYValueGenerator = ^EGMGraphAxisValue *(CGFloat scalar) {
        EGMGraphAxisValue *axisValue = [[EGMGraphAxisValueNumberFormatted alloc] initWithNumber:scalar decimals:2 trim0:YES strFormat:@"%@"];
        return axisValue;
    };

    graph.dataPoints = dataPoints;
    [graph configure];
    
    return graph;
}



+ (EGMGraph *)getTargetChart:(NSArray *)dataPoints frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock {
    
    NSMutableArray *minutes = [NSMutableArray array];
    
    for (EGMGraphDataPoint *dataPoint in dataPoints) {
        EGMGraphAxisValue *minuteValue = [dataPoint getXValue];
        [minutes addObject:minuteValue];
    }

    
    EGMGraphDataPointRenderer *(^dataPointModelGenerator)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *) = ^EGMGraphDataPointRenderer * (CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph * graph) {
        EGMGraphDataPointRenderer *model =  [[EGMGraphDataPointRectRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint rectSize:CGSizeMake(1, 1) color:[UIColor blackColor] cornerRadius:0];
        return model;
    };
    
    EGMGraphDataPointsManager *dataPointsManager = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPoints dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:[UIColor redColor] animDuration:1 animDelay:0 hasTracker:NO];

    EGMGraphDataPointsManager *dataPointsTargetManager = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPoints dataPointRendererGenerator:^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph *graph) {
        if (index != dataPoints.count - 1) return nil;
        return [[EGMGraphDataPointTargetingRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint animDuration:2 animDelay:1];
    } minYSpacing:10];
    
    EGMGraph *graph = [self createGraphInstanceWithDefaultSettings:frame];
    graph.dataPointsManagers = [NSArray arrayWithObjects:dataPointsManager, dataPointsTargetManager, nil];
    graph.dataPoints = dataPoints;
    graph.axisValuesX = minutes;
    graph.segmentSizeMultY = 50;
    graph.verticalAxisXLabels = NO;
    
    if ([minutes count] > 0) {
        [minutes[0] setIsHidden:YES];
    }
    
    graph.addPaddingSegmentIfEdge = NO;
    
    graph.axisXLabel = @"Time in minutes";
    graph.axisYLabel = @"Pulse";

    graph.resizeBlock = resizeBlock;

    graph.axisYValueGenerator = ^EGMGraphAxisValue *(CGFloat scalar) {
        EGMGraphAxisValue *axisValue = [[EGMGraphAxisValueNumberFormatted alloc] initWithNumber:scalar decimals:2 trim0:YES strFormat:@"%@"];
        return axisValue;
    };

    graph.dataPoints = dataPoints;
    [graph configure];
    
    return graph;
}


+ (EGMGraph *)getAreasChart:(NSArray *)dataPointsArr frame:(CGRect)frame resizeBlock:(void(^)(CGSize))resizeBlock {
    NSMutableArray *minutes = [NSMutableArray array];
    
    NSArray *dataPoints = dataPointsArr[0];
    
    for (EGMGraphDataPoint *dataPoint in dataPoints) {
        EGMGraphAxisValue *minuteValue = [dataPoint getXValue];
        [minutes addObject:minuteValue];
    }
    
    EGMGraphDataPointRenderer *(^dataPointModelGenerator)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *) = ^EGMGraphDataPointRenderer * (CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph * graph) {
        EGMGraphDataPointRenderer *model =  [[EGMGraphDataPointRectRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint rectSize:CGSizeMake(1, 1) color:[UIColor blackColor] cornerRadius:0];
        return model;
    };
    
    EGMGraphDataPointRenderer *(^dataPointLineModelGenerator)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *) = ^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph *graph) {
        if (index == [dataPoints count] - 1) {
            EGMGraphLineRenderer *lineModel = [[EGMGraphLineRenderer alloc] init];
            CGPoint p1 = CGPointMake(pointPx.x, [graph.xAxisModel getOrigin].y);
            CGPoint p2 = CGPointMake(pointPx.x, [graph.xAxisModel getOrigin].y - graph.yAxisModel.length);
            [lineModel setP1:p1 p2:p2 color:[UIColor grayColor]];
            EGMGraphDataPointLineRenderer *dataPointLineModel = [[EGMGraphDataPointLineRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint lineModel:lineModel];
            return dataPointLineModel;
        }
        return nil;
    };
    
    UIColor *c1 = [UIColor colorWithRed: 0.1
                                          green: 0.1
                                           blue: 0.9
                                          alpha: 0.4];
    
    NSArray *merger0and1 = [dataPoints arrayByAddingObjectsFromArray:[((NSArray *)dataPointsArr[1]) reversedArray]];
    NSArray *merger1and2 = [dataPointsArr[1] arrayByAddingObjectsFromArray:[((NSArray *)dataPointsArr[2]) reversedArray]];
    
    EGMGraphDataPointsManager *dataPointsManager = [[EGMGraphDataPointsAreaManager alloc] initWithDataPoints:dataPoints dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:c1 animDuration:3 animDelay:0 addParentPointsHack:YES];
    EGMGraphDataPointsManager *dataPointsLinesManager = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPoints dataPointRendererGenerator:dataPointLineModelGenerator minYSpacing:10];
    
    UIColor *c2 = [UIColor colorWithRed: 0.9
                                  green: 0.1
                                   blue: 0.1
                                  alpha: 0.4];
    EGMGraphDataPointsManager *dataPointsManager2 = [[EGMGraphDataPointsAreaManager alloc] initWithDataPoints:merger0and1 dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:c2 animDuration:3 animDelay:1 addParentPointsHack:NO];
    
    UIColor *c3 = [UIColor colorWithRed: 0.1
                                  green: 0.9
                                   blue: 0.1
                                  alpha: 0.4];
    EGMGraphDataPointsManager *dataPointsManager3 = [[EGMGraphDataPointsAreaManager alloc] initWithDataPoints:merger1and2 dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:c3 animDuration:3 animDelay:2 addParentPointsHack:NO];

    EGMGraphDataPointsManager *dataPointsLineManager = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPoints dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:[UIColor blackColor] animDuration:1 animDelay:0 hasTracker:NO];
    EGMGraphDataPointsManager *dataPointsLineManager2 = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPointsArr[1] dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:[UIColor blackColor] animDuration:1 animDelay:1 hasTracker:NO];
    EGMGraphDataPointsManager *dataPointsLineManager3 = [[EGMGraphDataPointsLineManager alloc] initWithDataPoints:dataPointsArr[2] dataPointModelGenerator:dataPointModelGenerator minYSpacing:10 lineColor:[UIColor blackColor] animDuration:1 animDelay:2 hasTracker:NO];
    
    
    
    EGMGraphDataPointRenderer *(^dataPointCircleModelGenerator)(CGPoint, EGMGraphDataPoint *, NSInteger, CGPoint, EGMGraph *) = ^EGMGraphDataPointRenderer *(CGPoint pointPx, EGMGraphDataPoint *dataPoint, NSInteger index, CGPoint originPx, EGMGraph *graph) {
        EGMGraphDataPointTextCircleRenderer *dataPointCircleModel = [[EGMGraphDataPointTextCircleRenderer alloc] initWithPointPx:pointPx dataPoint:dataPoint];
        return dataPointCircleModel;
    };
    
    float itemsDelay = 0.08;
    EGMGraphDataPointsManager *dataPointsCirclesManager = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPoints dataPointRendererGenerator:dataPointCircleModelGenerator minYSpacing:10];
    dataPointsCirclesManager.delay = 0.9;
    dataPointsCirclesManager.itemsDelay = itemsDelay;

    EGMGraphDataPointsManager *dataPointsCirclesManager1 = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPointsArr[1] dataPointRendererGenerator:dataPointCircleModelGenerator minYSpacing:10];
    dataPointsCirclesManager1.delay = 1.8;
    dataPointsCirclesManager1.itemsDelay = itemsDelay;
    EGMGraphDataPointsManager *dataPointsCirclesManager2 = [[EGMGraphDataPointsManager alloc] initWithDataPoints:dataPointsArr[2] dataPointRendererGenerator:dataPointCircleModelGenerator minYSpacing:10];
    dataPointsCirclesManager2.delay = 2.6;
    dataPointsCirclesManager2.itemsDelay = itemsDelay;
    
    EGMGraph *graph = [self createGraphInstanceWithDefaultSettings:frame];
    
    graph.dataPointsManagers = [NSArray arrayWithObjects:dataPointsLinesManager,
                                dataPointsManager,
                                dataPointsManager2,
                                dataPointsManager3,
                                dataPointsLineManager, dataPointsLineManager2, dataPointsLineManager3, dataPointsCirclesManager, dataPointsCirclesManager1,dataPointsCirclesManager2, nil];
    
    graph.dataPoints = dataPoints;
    graph.axisValuesX = minutes;
    graph.segmentSizeMultY = 50;
    graph.verticalAxisXLabels = NO;
    graph.addPaddingSegmentIfEdge = NO;
    graph.spacingLabelAxisY = 30;

    if ([minutes count] > 0) {
        [minutes[0] setIsHidden:YES];
    }
    
    graph.axisXLabel = @"Time in minutes";
    graph.axisYLabel = @"Pulse";
    
    
    graph.resizeBlock = resizeBlock;
    
    graph.axisYValueGenerator = ^EGMGraphAxisValue *(CGFloat scalar) {
        EGMGraphAxisValue *axisValue = [[EGMGraphAxisValueNumberFormatted alloc] initWithNumber:scalar decimals:2 trim0:YES strFormat:@"%@"];
        return axisValue;
    };
  
    graph.dataPoints = dataPoints;
    [graph configure];
    
    return graph;
}
@end
